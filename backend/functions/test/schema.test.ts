import * as assert from 'assert';
import {
  guardiansPath,
  childrenPath,
  invitationsPath,
  relationshipsPath,
  remindersPath,
  auditLogsPath,
  InvitationStatus,
  RelationshipStatus,
  ReminderStatus,
  assertActorMatches,
  CURRENT_CONSENT_VERSION,
} from '../src/schema';

describe('schema.ts', () => {
  it('builds consistent Firestore paths', () => {
    assert.strictEqual(guardiansPath('g1'), 'guardians/g1');
    assert.strictEqual(childrenPath('c1'), 'children/c1');
    assert.strictEqual(invitationsPath('i1'), 'invitations/i1');
    assert.strictEqual(relationshipsPath('r1'), 'relationships/r1');
    assert.strictEqual(remindersPath('rem1'), 'reminders/rem1');
    assert.strictEqual(auditLogsPath('log1'), 'auditLogs/log1');
  });

  it('exports expected enum values', () => {
    assert.strictEqual(InvitationStatus.Pending, 'pending');
    assert.strictEqual(RelationshipStatus.Active, 'active');
    assert.strictEqual(ReminderStatus.Sent, 'sent');
  });

  it('assertActorMatches passes for matching ids', () => {
    assert.doesNotThrow(() => assertActorMatches('userA', 'userA'));
  });

  it('assertActorMatches throws for mismatch', () => {
    assert.throws(() => assertActorMatches('userA', 'userB'), /permission-denied/);
  });

  it('exposes current consent version', () => {
    assert.strictEqual(typeof CURRENT_CONSENT_VERSION, 'string');
    assert.ok(CURRENT_CONSENT_VERSION.length > 0);
  });
});
