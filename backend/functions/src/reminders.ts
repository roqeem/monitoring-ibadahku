import { onCall, HttpsError } from 'firebase-functions/v2/https';
import { initializeApp, getApps } from 'firebase-admin/app';
import { getFirestore, Timestamp, FieldValue, Firestore } from 'firebase-admin/firestore';
import { getMessaging } from 'firebase-admin/messaging';
import {
  Relationship,
  RelationshipStatus,
  Reminder,
  ReminderStatus,
  relationshipsPath,
  remindersPath,
} from './schema.js';
import { writeAudit, hashId } from './audit.js';

let db: Firestore;
function getDb(): Firestore {
  if (!db) {
    if (getApps().length === 0) initializeApp();
    db = getFirestore();
  }
  return db;
}

export interface SendReminderRequest {
  childId: string;
  worshipDate: string;
  activityKey: string;
  templateKey: string;
}

const REMINDER_COOLDOWN_MINUTES = 60 * 6;
const GUARDIAN_DAILY_CAP = 10;

export async function sendStandardReminderLogic(
  data: SendReminderRequest,
  guardianId: string,
  database: Firestore = getDb()
): Promise<{ status: string; reminderId: string | null }> {
  const { childId, worshipDate, activityKey, templateKey } = data;

  const activeRels = await database
    .collection('relationships')
    .where('guardianId', '==', guardianId)
    .where('childId', '==', childId)
    .where('status', '==', RelationshipStatus.Active)
    .get();

  if (activeRels.empty) {
    throw new HttpsError('permission-denied', 'No active family relationship for this child.');
  }

  const rel = activeRels.docs[0].data() as Relationship;

  const recentCutoff = Timestamp.fromMillis(Date.now() - REMINDER_COOLDOWN_MINUTES * 60_000);
  const recent = await database
    .collection('reminders')
    .where('guardianId', '==', guardianId)
    .where('childId', '==', childId)
    .where('activityKey', '==', activityKey)
    .where('worshipDate', '==', worshipDate)
    .where('requestedAt', '>=', recentCutoff)
    .get();

  if (!recent.empty) {
    return { status: 'rate_limited', reminderId: null };
  }

  const dayCutoff = Timestamp.fromMillis(Date.now() - 24 * 3600_000);
  const dailyCount = await database
    .collection('reminders')
    .where('guardianId', '==', guardianId)
    .where('requestedAt', '>=', dayCutoff)
    .get();

  if (dailyCount.size >= GUARDIAN_DAILY_CAP) {
    throw new HttpsError('resource-exhausted', 'Daily reminder limit reached.');
  }

  const reminderRef = database.collection('reminders').doc();
  const nowDate = Timestamp.fromDate(new Date());

  const reminder: Reminder = {
    reminderId: reminderRef.id,
    guardianId,
    childId,
    relationshipId: rel.relationshipId,
    activityId: activityKey,
    worshipDate,
    status: ReminderStatus.Sent,
    failureCode: null,
    requestedAt: nowDate,
    sentAt: nowDate,
  };

  await database.doc(remindersPath(reminderRef.id)).set(reminder);

  try {
    const messaging = getMessaging();
    await messaging.send({
      topic: `user-events-${childId}`,
      data: { activityId: activityKey, reminderId: reminderRef.id, templateKey },
    });
  } catch {
    await database.doc(remindersPath(reminderRef.id)).update({
      status: ReminderStatus.Failed,
      failureCode: 'fcm_error',
    });
  }

  await writeAudit(database, 'reminder_sent', {
    actorId: guardianId,
    role: 'guardian',
    resourceId: reminderRef.id,
    result: 'success',
  });

  return { status: 'sent', reminderId: reminderRef.id };
}

export const sendStandardReminder = onCall<SendReminderRequest>(
  { region: 'asia-southeast2' },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError('unauthenticated', 'Authentication required.');
    }
    return sendStandardReminderLogic(request.data, request.auth.uid);
  }
);