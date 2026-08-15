import * as functions from 'firebase-functions/v2/https';
import * as admin from 'firebase-admin';
import { onCall } from 'firebase-functions/v2/https';
import { onDocumentWritten } from 'firebase-functions/v2/firestore';
import {
  Invitation,
  InvitationStatus,
  invitationsPath,
  guardiansPath,
  CURRENT_CONSENT_VERSION,
} from './schema';
import { writeAudit, hashId } from './audit';

/**
 * Creates a family monitoring invitation.
 * Guardian provides an already-generated secret token (plain) which was
 * shared out-of-band to the child. Only the hash of that token is stored.
 * The token plain itself is never logged.
 */

const INVITATION_TTL_HOURS = 24;

export const createInvitation = onCall<InvitationRequest>(
  {
    region: 'asia-southeast2',
    secrets: [],
  },
  async (request) => {
    const auth = request.auth;
    if (!auth) {
      throw new functions.HttpsError('unauthenticated', 'Authentication required.');
    }

    const guardianId = auth.uid;

    // Validate that caller actually has a guardian profile (created during onboarding).
    const db = admin.firestore();
    const guardianSnap = await db.doc(guardiansPath(guardianId)).get();
    if (!guardianSnap.exists) {
      throw new functions.HttpsError(
        'permission-denied',
        'Only on-boarded guardians may create invitations.'
      );
    }

    const { tokenPlain, durationHours } = request.data as InvitationRequest;
    if (!tokenPlain || !tokenPlain.trim()) {
      throw new functions.HttpsError('invalid-argument', 'tokenPlain is required.');
    }

    // Hash token — plain is discarded after hashing
    const crypto = await import('crypto');
    const tokenHash = crypto.createHash('sha256').update(tokenPlain.trim()).digest('hex');

    const now = admin.firestore.FieldValue.serverTimestamp() as admin.firestore.Timestamp;
    const ttl = durationHours ?? INVITATION_TTL_HOURS;
    const expiresAt = admin.firestore.Timestamp.fromMillis(
      Date.now() + ttl * 3600_000
    );

    const invitationRef = db.collection('invitations').doc();
    const invitation: Invitation = {
      tokenHash,
      guardianId,
      childId: null,
      status: InvitationStatus.Pending,
      createdAt: now as Invitation['createdAt'],
      expiresAt,
      usedAt: null,
    };

    await db.doc(invitationsPath(invitationRef.id)).set(invitation);

    await writeAudit(db, 'invitation_created', {
      actorId: guardianId,
      role: 'guardian',
      resourceId: invitationRef.id,
      result: 'success',
    });

    return { invitationId: invitationRef.id, expiresAt: expiresAt.toDate().toISOString() };
  }
);

interface InvitationRequest {
  tokenPlain: string;
  durationHours?: number;
}
