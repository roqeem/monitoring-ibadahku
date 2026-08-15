import { onCall, HttpsError } from 'firebase-functions/v2/https';
import { initializeApp, getApps } from 'firebase-admin/app';
import { getFirestore, Timestamp, FieldValue, Firestore } from 'firebase-admin/firestore';
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

export interface AcceptInvitationRequest {
  invitationId: string;
  childId: string;
}

export interface RelationshipActionRequest {
  relationshipId: string;
}

export async function acceptInvitationLogic(
  data: AcceptInvitationRequest,
  callerUid: string,
  database: Firestore = getDb()
): Promise<{ relationshipId: string }> {
  const { invitationId, childId } = data;

  if (callerUid !== childId) {
    throw new HttpsError(
      'permission-denied',
      'Caller UID must match the child accepting the invitation.'
    );
  }

  return await database.runTransaction(async (tx) => {
    const invitationRef = database.doc(invitationsPath(invitationId));
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

    const relRef = database.collection('relationships').doc();
    const serverTs = FieldValue.serverTimestamp() as Timestamp;
    const serverDate = Timestamp.fromDate(now);

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

    const auditRef = database.collection('auditLogs').doc();
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

export async function revokeAccessLogic(
  data: RelationshipActionRequest,
  callerUid: string,
  database: Firestore = getDb()
): Promise<{ ok: true }> {
  const childId = callerUid;
  const { relationshipId } = data;

  return await database.runTransaction(async (tx) => {
    const relRef = database.doc(relationshipsPath(relationshipId));
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

    const now = Timestamp.now();
    tx.update(relRef, {
      status: RS.Revoked,
      revokedAt: now,
      revokedBy: childId,
      updatedAt: now,
    });

    const auditRef = database.collection('auditLogs').doc();
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

    return { ok: true as const };
  });
}

export async function stopMonitoringLogic(
  data: RelationshipActionRequest,
  callerUid: string,
  database: Firestore = getDb()
): Promise<{ ok: true }> {
  const guardianId = callerUid;
  const { relationshipId } = data;

  return await database.runTransaction(async (tx) => {
    const relRef = database.doc(relationshipsPath(relationshipId));
    const relSnap = await tx.get(relRef);

    if (!relSnap.exists) {
      throw new HttpsError('not-found', 'Relationship not found.');
    }

    const rel = relSnap.data() as Relationship;

    if (rel.guardianId !== guardianId) {
      throw new HttpsError('permission-denied', 'Only the guardian can stop monitoring.');
    }

    const now = Timestamp.now();
    tx.update(relRef, {
      status: RS.Stopped,
      revokedAt: now,
      revokedBy: guardianId,
      updatedAt: now,
    });

    const auditRef = database.collection('auditLogs').doc();
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

    return { ok: true as const };
  });
}

export const acceptInvitation = onCall<AcceptInvitationRequest>(
  { region: 'asia-southeast2' },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError('unauthenticated', 'Authentication required.');
    }
    return acceptInvitationLogic(request.data, request.auth.uid);
  }
);

export const revokeAccess = onCall<RelationshipActionRequest>(
  { region: 'asia-southeast2' },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError('unauthenticated', 'Authentication required.');
    }
    return revokeAccessLogic(request.data, request.auth.uid);
  }
);

export const stopMonitoring = onCall<RelationshipActionRequest>(
  { region: 'asia-southeast2' },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError('unauthenticated', 'Authentication required.');
    }
    return stopMonitoringLogic(request.data, request.auth.uid);
  }
);

// Auth trigger: lazy dynamic import because v7 omits types
let onUserDeletedPromise: Promise<any> | null = null;
async function getOnUserDeleted(): Promise<any> {
  if (!onUserDeletedPromise) {
    onUserDeletedPromise = import('firebase-functions/v2/identity').then((m: any) => m.onUserDeleted);
  }
  return onUserDeletedPromise;
}

export const onUserDeletedTrigger = (async () => {
  const onUserDeleted = await getOnUserDeleted();
  return onUserDeleted({ region: 'asia-southeast2' }, async (event: { data?: { uid: string } }) => {
    const uid = event.data?.uid;
    if (!uid) return;
    const now = Timestamp.now();
    const database = getDb();
    const guardianRels = await database.collection('relationships').where('guardianId', '==', uid).where('status', '==', RS.Active).get();
    const childRels = await database.collection('relationships').where('childId', '==', uid).where('status', '==', RS.Active).get();
    const batch = database.batch();
    guardianRels.forEach((doc) => batch.update(doc.ref, { status: RS.UserDeleted, revokedAt: now, revokedBy: uid, updatedAt: now }));
    childRels.forEach((doc) => batch.update(doc.ref, { status: RS.UserDeleted, revokedAt: now, revokedBy: uid, updatedAt: now }));
    await batch.commit();
    await writeAudit(database, 'user_deleted', { actorId: hashId(uid), role: 'system', result: 'success' });
  });
})();
