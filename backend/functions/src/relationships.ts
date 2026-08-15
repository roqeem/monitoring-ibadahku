import { onCall, HttpsError } from 'firebase-functions/v2/https';
// firebase-functions v7 exports onUserDeleted at runtime in v2/identity
// but omits it from type definitions; cast through untyped binding.
/* eslint-disable @typescript-eslint/no-var-requires */
const identityMod = require('firebase-functions/v2/identity') as {
  onUserDeleted: (
    opts: { region?: string },
    handler: (event: { data?: { uid: string } }) => Promise<unknown> | unknown
  ) => unknown;
};
const onUserDeleted = identityMod.onUserDeleted;
import { setGlobalOptions } from 'firebase-functions/v2';
import * as admin from 'firebase-admin';
import {
  Relationship,
  RelationshipStatus,
  Invitation,
  InvitationStatus,
  relationshipsPath,
  invitationsPath,
  auditLogsPath,
  RelationshipStatus as RS,
  InvitationStatus as IS,
  CURRENT_CONSENT_VERSION,
} from './schema';
import { writeAudit, hashId } from './audit';

const db = admin.firestore();

export interface AcceptInvitationRequest {
  invitationId: string;
  childId: string;
}

export interface RelationshipActionRequest {
  relationshipId: string;
}

/**
 * Accepts an invitation on behalf of the child's IbadahKu account.
 * Validates consent explicitly — child must be the recipient.
 * The child ID in the request MUST match the authenticated UID.
 */
export const acceptInvitation = onCall<AcceptInvitationRequest>(
  { region: 'asia-southeast2' },
  async (request) => {
    const authUser = request.auth;
    if (!authUser) {
      throw new HttpsError('unauthenticated', 'Authentication required.');
    }

    const { invitationId, childId } = request.data as AcceptInvitationRequest;
    const callerUid = authUser.uid;

    // The caller must be the child accepting — verified by UID match.
    if (callerUid !== childId) {
      throw new HttpsError(
        'permission-denied',
        'Caller UID must match the child accepting the invitation.'
      );
    }

    return await db.runTransaction(async (tx) => {
      const invitationRef = db.doc(invitationsPath(invitationId));
      const invitationSnap = await tx.get(invitationRef);

      if (!invitationSnap.exists) {
        throw new HttpsError('not-found', 'Invitation not found.');
      }

      const invitation = invitationSnap.data() as Invitation & { guardianId: string };

      if (invitation.status !== IS.Pending) {
        throw new HttpsError(
          'failed-precondition',
          `Invitation status is '${invitation.status}', cannot be accepted.`
        );
      }

      const expiresAt = invitation.expiresAt.toDate();
      const now = new Date();
      if (now > expiresAt) {
        tx.update(invitationRef, { status: IS.Expired });
        throw new HttpsError('failed-precondition', 'Invitation has expired.');
      }

      const relRef = db.collection('relationships').doc();
      const serverTs = admin.firestore.FieldValue.serverTimestamp() as admin.firestore.Timestamp;
      const serverDate = admin.firestore.Timestamp.fromDate(now);

      const relationship: Relationship = {
        relationshipId: relRef.id,
        guardianId: invitation.guardianId,
        childId,
        invitationId,
        status: RS.Active,
        consentVersion: CURRENT_CONSENT_VERSION,
        consentedAt: serverDate,
        revokedAt: null,
        revokedBy: null,
        createdAt: serverDate,
        updatedAt: serverDate,
      };

      tx.set(relRef, relationship);
      tx.update(invitationRef, { status: IS.Accepted, usedAt: serverTs });

      const auditRef = db.collection(auditLogsPath('x')).doc();
      tx.set(
        auditRef,
        {
          event: 'relationship_created',
          actorIdHash: hashId(childId),
          role: 'child',
          resourceType: 'relationship',
          resourceIdHash: hashId(relRef.id),
          result: 'success',
          occurredAt: serverTs,
        },
        { merge: false }
      );

      return { relationshipId: relRef.id };
    });
  }
);

/**
 * Child revokes access for a specific guardian.
 */
export const revokeAccess = onCall<RelationshipActionRequest>(
  { region: 'asia-southeast2' },
  async (request) => {
    const authUser = request.auth;
    if (!authUser) {
      throw new HttpsError('unauthenticated', 'Authentication required.');
    }
    const childId = authUser.uid;
    const { relationshipId } = request.data as RelationshipActionRequest;

    return await db.runTransaction(async (tx) => {
      const relRef = db.doc(relationshipsPath(relationshipId));
      const relSnap = await tx.get(relRef);

      if (!relSnap.exists) {
        throw new HttpsError('not-found', 'Relationship not found.');
      }

      const rel = relSnap.data() as Relationship;

      if (rel.childId !== childId) {
        throw new HttpsError('permission-denied', 'Only the child can revoke access.');
      }

      if (rel.status !== RS.Active) {
        throw new HttpsError(
          'failed-precondition',
          `Relationship status is '${rel.status}', cannot be modified.`
        );
      }

      const now = admin.firestore.Timestamp.now();
      tx.update(relRef, {
        status: RS.Revoked,
        revokedAt: now,
        revokedBy: childId,
        updatedAt: now,
      });

      const auditRef = db.collection(auditLogsPath('x')).doc();
      tx.set(
        auditRef,
        {
          event: 'relationship_revoked',
          actorIdHash: hashId(childId),
          role: 'child',
          resourceType: 'relationship',
          resourceIdHash: hashId(relationshipId),
          result: 'success',
          occurredAt: now,
        },
        { merge: false }
      );

      return { ok: true };
    });
  }
);

/**
 * Guardian stops monitoring a child (no effect on child data).
 */
export const stopMonitoring = onCall<RelationshipActionRequest>(
  { region: 'asia-southeast2' },
  async (request) => {
    const authUser = request.auth;
    if (!authUser) {
      throw new HttpsError('unauthenticated', 'Authentication required.');
    }
    const guardianId = authUser.uid;
    const { relationshipId } = request.data as RelationshipActionRequest;

    return await db.runTransaction(async (tx) => {
      const relRef = db.doc(relationshipsPath(relationshipId));
      const relSnap = await tx.get(relRef);

      if (!relSnap.exists) {
        throw new HttpsError('not-found', 'Relationship not found.');
      }

      const rel = relSnap.data() as Relationship;

      if (rel.guardianId !== guardianId) {
        throw new HttpsError('permission-denied', 'Only the guardian can stop monitoring.');
      }

      const now = admin.firestore.Timestamp.now();
      tx.update(relRef, {
        status: RS.Stopped,
        revokedAt: now,
        revokedBy: guardianId,
        updatedAt: now,
      });

      const auditRef = db.collection(auditLogsPath('x')).doc();
      tx.set(
        auditRef,
        {
          event: 'relationship_stopped',
          actorIdHash: hashId(guardianId),
          role: 'guardian',
          resourceType: 'relationship',
          resourceIdHash: hashId(relationshipId),
          result: 'success',
          occurredAt: now,
        },
        { merge: false }
      );

      return { ok: true };
    });
  }
);

/**
 * Auth trigger: when a user account is deleted, soft-disable their
 * relationships so they no longer count as active, without touching worship data.
 */
export const onUserDeletedTrigger = onUserDeleted({ region: 'asia-southeast2' }, async (event) => {
    const uid = event.data?.uid;
    if (!uid) {
      return undefined;
    }
    const now = admin.firestore.Timestamp.now();

    const guardianRels = await db
      .collection('relationships')
      .where('guardianId', '==', uid)
      .where('status', '==', RS.Active)
      .get();

    const childRels = await db
      .collection('relationships')
      .where('childId', '==', uid)
      .where('status', '==', RS.Active)
      .get();

    const batch = db.batch();
    guardianRels.forEach((doc) => {
      batch.update(doc.ref, {
        status: RS.UserDeleted,
        revokedAt: now,
        revokedBy: uid,
        updatedAt: now,
      });
    });

    childRels.forEach((doc) => {
      batch.update(doc.ref, {
        status: RS.UserDeleted,
        revokedAt: now,
        revokedBy: uid,
        updatedAt: now,
      });
    });

    await batch.commit();

    await writeAudit(db, 'user_deleted', {
      actorId: hashId(uid),
      role: 'system',
      result: 'success',
    });

    return undefined;
  });
