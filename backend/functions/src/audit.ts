import * as admin from 'firebase-admin';
import { AuditLog, auditLogsPath } from './schema';

/**
 * Audit logging utilities.
 * Writes to dedicated collection that is deny-all for client reads (see rules).
 */

export async function writeAudit(
  db: admin.firestore.Firestore,
  event: AuditLog['event'],
  opts: {
    actorId?: string;
    role: AuditLog['role'];
    resourceType?: string;
    resourceId?: string;
    result: AuditLog['result'];
    failureCode?: string;
    sessionId?: string;
  }
): Promise<void> {
  const log: AuditLog = {
    event,
    actorIdHash: opts.actorId ? hashId(opts.actorId) : null,
    role: opts.role,
    resourceType: opts.resourceType ?? null,
    // Hash identifiers to avoid plaintext PII in audit trail
    resourceIdHash: opts.resourceId ? hashId(opts.resourceId) : null,
    result: opts.result,
    failureCode: opts.failureCode ?? null,
    occurredAt: admin.firestore.FieldValue.serverTimestamp() as admin.firestore.Timestamp,
    sessionIdHash: opts.sessionId ? hashId(opts.sessionId) : null,
  };

  const auditId = generateAuditId(event, opts.resourceId);
  await db.collection('auditLogs').doc(auditId).set(log, { merge: true });
}

/** Simple non-cryptographic hash for identifier redaction in audit logs. */
export function hashId(value: string): string {
  const crypto = require('crypto') as typeof import('crypto');
  return crypto.createHash('sha256').update(value).digest('hex').slice(0, 16);
}

function generateAuditId(event: string, resourceId?: string): string {
  return `${event}_${resourceId ?? 'system'}_${Date.now()}`;
}
