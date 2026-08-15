import * as functions from 'firebase-functions/v2/https';
import { onCall } from 'firebase-functions/v2/https';
import { initializeApp, getApps } from 'firebase-admin/app';
import { getFirestore, Timestamp, FieldValue, Firestore } from 'firebase-admin/firestore';
import {
  Invitation,
  InvitationStatus,
  invitationsPath,
  guardiansPath,
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

const INVITATION_TTL_HOURS = 24;

export interface InvitationRequest {
  tokenPlain: string;
  durationHours?: number;
}

/** Pure logic — testable directly against Firestore emulator. */
export async function createInvitationLogic(
  data: InvitationRequest,
  guardianId: string,
  database: Firestore = getDb()
): Promise<{ invitationId: string; expiresAt: string }> {
  const guardianSnap = await database.doc(guardiansPath(guardianId)).get();
  if (!guardianSnap.exists) {
    throw new functions.HttpsError(
      'permission-denied',
      'Only on-boarded guardians may create invitations.'
    );
  }

  const { tokenPlain, durationHours } = data;
  if (!tokenPlain || !tokenPlain.trim()) {
    throw new functions.HttpsError('invalid-argument', 'tokenPlain is required.');
  }

  const crypto = await import('crypto');
  const tokenHash = crypto.createHash('sha256').update(tokenPlain.trim()).digest('hex');

  const ttl = durationHours ?? INVITATION_TTL_HOURS;
  const expiresAt = Timestamp.fromMillis(Date.now() + ttl * 3600_000);

  const invitationRef = database.collection('invitations').doc();
  const invitation: Invitation = {
    tokenHash,
    guardianId,
    childId: null,
    status: InvitationStatus.Pending,
    createdAt: FieldValue.serverTimestamp() as unknown as Invitation['createdAt'],
    expiresAt,
    usedAt: null,
  };

  await database.doc(invitationsPath(invitationRef.id)).set(invitation);

  await writeAudit(database, 'invitation_created', {
    actorId: guardianId,
    role: 'guardian',
    resourceId: invitationRef.id,
    result: 'success',
  });

  return { invitationId: invitationRef.id, expiresAt: expiresAt.toDate().toISOString() };
}

export const createInvitation = onCall<InvitationRequest>(
  { region: 'asia-southeast2', secrets: [] },
  async (request) => {
    const auth = request.auth;
    if (!auth) {
      throw new functions.HttpsError('unauthenticated', 'Authentication required.');
    }
    return createInvitationLogic(request.data, auth.uid);
  }
);
