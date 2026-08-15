import { onCall, HttpsError } from 'firebase-functions/v2/https';
import * as admin from 'firebase-admin';
import {
  Relationship,
  RelationshipStatus,
  Reminder,
  ReminderStatus,
  relationshipsPath,
  remindersPath,
} from './schema';
import { writeAudit, hashId } from './audit';
import { getMessaging } from 'firebase-admin/messaging';

const db = admin.firestore();

export interface SendReminderRequest {
  childId: string;
  worshipDate: string;
  activityKey: string;
  templateKey: string;
}

// Rate limit constants
const REMINDER_COOLDOWN_MINUTES = 60 * 6; // 6 hours per child+guardian+activity+date
const GUARDIAN_DAILY_CAP = 10; // max per 24h per guardian

/**
 * Sends a standard (non-Personalised) reminder to a child for a specific
 * worship activity on a specific date.
 */
export const sendStandardReminder = onCall<SendReminderRequest>(
  { region: 'asia-southeast2' },
  async (request) => {
    const authUser = request.auth;
    if (!authUser) {
      throw new HttpsError('unauthenticated', 'Authentication required.');
    }
    const guardianId = authUser.uid;
    const { childId, worshipDate, activityKey, templateKey } = request.data as SendReminderRequest;

    // Validate child is in active relationship with guardian
    const activeRels = await db
      .collection('relationships')
      .where('guardianId', '==', guardianId)
      .where('childId', '==', childId)
      .where('status', '==', RelationshipStatus.Active)
      .get();

    if (activeRels.empty) {
      throw new HttpsError('permission-denied', 'No active family relationship for this child.');
    }

    const rel = activeRels.docs[0].data() as Relationship;

    // Check 6-hour cooldown for same child+guardian+activity+date
    const recentCutoff = admin.firestore.Timestamp.fromMillis(
      Date.now() - REMINDER_COOLDOWN_MINUTES * 60_000
    );
    const recent = await db
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

    // Check 24h daily cap for guardian
    const dayCutoff = admin.firestore.Timestamp.fromMillis(
      Date.now() - 24 * 3600_000
    );
    const dailyCount = await db
      .collection('reminders')
      .where('guardianId', '==', guardianId)
      .where('requestedAt', '>=', dayCutoff)
      .get();

    if (dailyCount.size >= GUARDIAN_DAILY_CAP) {
      throw new HttpsError('resource-exhausted', 'Daily reminder limit reached.');
    }

    // Create reminder
    const reminderRef = db.collection('reminders').doc();
    const now = admin.firestore.FieldValue.serverTimestamp() as admin.firestore.Timestamp;
    const nowDate = admin.firestore.Timestamp.fromDate(new Date());

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

    await db.doc(remindersPath(reminderRef.id)).set(reminder);

    // Send FCM to child's topic
    try {
      const messaging = getMessaging();
      await messaging.send({
        topic: `user-events-${childId}`,
        data: {
          activityId: activityKey,
          reminderId: reminderRef.id,
          templateKey,
          // No PII body — notification built client-side
        },
      });
    } catch (err) {
      await db.doc(remindersPath(reminderRef.id)).update({
        status: ReminderStatus.Failed,
        failureCode: 'fcm_error',
      });
    }

    await writeAudit(db, 'reminder_sent', {
      actorId: guardianId,
      role: 'guardian',
      resourceId: reminderRef.id,
      result: 'success',
    });

    return { status: 'sent', reminderId: reminderRef.id };
  }
);
