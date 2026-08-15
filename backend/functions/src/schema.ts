import * as admin from 'firebase-admin';

/**
 * Shared schema and Firestore path builders.
 * All modules MUST reference paths defined here to guarantee
 * naming/structure consistency and single source of truth.
 */

// ---- Firestore collection path builders ----

export const guardiansPath = (guardianId: string) => `guardians/${guardianId}`;
export const childrenPath = (childId: string) => `children/${childId}`;
export const invitationsPath = (invitationId: string) => `invitations/${invitationId}`;
export const relationshipsPath = (relationshipId: string) =>
  `relationships/${relationshipId}`;
export const remindersPath = (reminderId: string) => `reminders/${reminderId}`;
export const auditLogsPath = (logId: string) => `auditLogs/${logId}`;

// ---- Enums ----

export enum InvitationStatus {
  Pending = 'pending',
  Accepted = 'accepted',
  Rejected = 'rejected',
  Cancelled = 'cancelled',
  Expired = 'expired',
}

export enum RelationshipStatus {
  Active = 'active',
  Revoked = 'revoked',
  Stopped = 'stopped',
  UserDeleted = 'user_deleted',
}

export enum ReminderStatus {
  Sent = 'sent',
  RateLimited = 'rate_limited',
  Failed = 'failed',
}

// ---- Document Interfaces ----

export interface Invitation {
  tokenHash: string;
  guardianId: string;
  childId?: string | null;
  status: InvitationStatus;
  createdAt: admin.firestore.Timestamp;
  expiresAt: admin.firestore.Timestamp;
  usedAt?: admin.firestore.Timestamp | null;
}

export interface Relationship {
  relationshipId: string;
  guardianId: string;
  childId: string;
  invitationId: string;
  status: RelationshipStatus;
  consentVersion: string;
  consentedAt: admin.firestore.Timestamp;
  revokedAt?: admin.firestore.Timestamp | null;
  revokedBy?: string | null;
  createdAt: admin.firestore.Timestamp;
  updatedAt: admin.firestore.Timestamp;
}

export interface Reminder {
  reminderId: string;
  guardianId: string;
  childId: string;
  relationshipId: string;
  activityId: string;
  worshipDate: string; // YYYY-MM-DD UTC
  status: ReminderStatus;
  failureCode?: string | null;
  requestedAt: admin.firestore.Timestamp;
  sentAt?: admin.firestore.Timestamp | null;
}

export interface AuditLog {
  event: string;
  actorId?: string | null;
  role: 'guardian' | 'child' | 'system';
  resourceType?: string | null;
  resourceIdHash?: string | null;
  result: 'success' | 'failure';
  failureCode?: string | null;
  occurredAt: admin.firestore.Timestamp;
  sessionIdHash?: string | null;
}

export interface ChildSummary {
  childId: string;
  displayName?: string | null;
  photoUrl?: string | null;
  worshipDate: string;
  completed: number;
  pending: number;
  skipped: number;
  lastUpdated: admin.firestore.Timestamp;
}

// ---- Helpers ----

/**
 * Throws when the calling principal is not permitted to own the relationship.
 */
export function assertActorMatches(actorUid: string, ownerUid: string): void {
  if (actorUid !== ownerUid) {
    throw new Error('permission-denied');
  }
}

/**
 * Consent version currently served by the apps. Bump when text changes.
 */
export const CURRENT_CONSENT_VERSION = '1.0.0';
