import * as assert from 'assert';
import { initializeApp } from 'firebase-admin/app';
import { getFirestore, Timestamp } from 'firebase-admin/firestore';
import { test, describe, before, beforeEach } from 'node:test';

// Import the logic functions directly
import { createInvitationLogic } from '../../src/invitations.js';
import { acceptInvitationLogic, revokeAccessLogic } from '../../src/relationships.js';

// Point to emulators
process.env.FIRESTORE_EMULATOR_HOST = 'localhost:8080';

describe('Family Monitoring Logic (Direct Admin SDK)', () => {
  let db: ReturnType<typeof getFirestore>;
  const guardianUid = 'test-guardian-1';
  const childUid = 'test-child-1';

  before(async () => {
    try {
      initializeApp({ projectId: 'monitor-ibadahku-dev' });
    } catch {}
    db = getFirestore();
  });

  beforeEach(async () => {
    // Clear data
    const collections = ['invitations', 'relationships', 'reminders', 'daily_records', 'children', 'guardians'];
    for (const col of collections) {
      const snap = await db.collection(col).get();
      if (snap.empty) continue;
      const batch = db.batch();
      snap.docs.forEach(doc => batch.delete(doc.ref));
      await batch.commit();
    }
    
    // Setup guardian
    await db.doc(`guardians/${guardianUid}`).set({
      displayName: 'Test Guardian',
      email: 'g@example.com',
      createdAt: Timestamp.now(),
    });
  });

  test('should complete full family flow using direct logic calls', async () => {
    // 1. Create invitation
    const invite = await createInvitationLogic(
      { tokenPlain: 'secret-code' },
      guardianUid,
      db
    );
    assert.ok(invite.invitationId);

    // 2. Accept invitation
    const rel = await acceptInvitationLogic(
      { invitationId: invite.invitationId, childId: childUid },
      childUid,
      db
    );
    assert.ok(rel.relationshipId);

    // 3. Verify in DB
    const relSnap = await db.doc(`relationships/${rel.relationshipId}`).get();
    assert.strictEqual(relSnap.data()?.status, 'active');

    // 4. Revoke access
    const revoke = await revokeAccessLogic(
      { relationshipId: rel.relationshipId },
      childUid,
      db
    );
    assert.strictEqual(revoke.ok, true);
  });
});