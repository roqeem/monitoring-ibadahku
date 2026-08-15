# Monitoring IbadahKu — Backend Implementation Plan (Plan A)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development or superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Firebase backend (Auth triggers, Cloud Functions, Security Rules, audit, FCM) that defines the family-relationship schema and safe APIs used by child and guardian apps.

**Spec:** `../2026-08-15-monitoring-ibadahku.md` (contract section), `./PRD.md` §6 §9 §11 §12 §13 §14 §16.

## Global Constraints (repeat)

- TypeScript 5.x strict
- Firebase CLI emulators used for all tests
- App Check enforcement behind env flag `ENFORCE_APP_CHECK=true`
- Structured logging, no PII
- Staging env var: `GCLOUD_PROJECT=monitor-ibadahku-dev`

## Files

- Create `backend/functions/src/index.ts`
- Create `backend/functions/src/invitations.ts`
- Create `backend/functions/src/relationships.ts`
- Create `backend/functions/src/reminders.ts`
- Create `backend/functions/src/audit.ts`
- Create `backend/functions/src/digest.ts`
- Create `backend/functions/test/invitations.test.ts`
- Create `backend/functions/test/relationships.test.ts`
- Create `backend/functions/test/reminders.test.ts`
- Create `backend/firestore.rules`
- Create `backend/.env.yaml`
- Create `backend/.gitignore`

## Tasks

### Task 1: Scaffold Firebase Functions project

**Files:** Create `backend/functions/package.json`, `tsconfig.json`, `.eslintrc.json`, `backend/.firebaserc`.

- [ ] Create directory skeleton.
- [ ] `package.json` with deps `firebase-admin@^12`, `firebase-functions@^4`, `firebase-functions-test@^3`, dev `typescript@^5`, `@types/firebase-functions`, `ts-node`, `sinon`, `mocha`, `@firebase/rules-unit-testing`, `prettier`, `eslint`.
- [ ] `tsconfig.json` with `"strict": true`, `"target": "es2022"`, `"moduleResolution": "node16"`.
- [ ] `.firebaserc` with `projects: { staging: monitor-ibadahku-dev, prod: monitor-ibadahku }`.

### Task 2: Define shared types and Firestore paths module

**Files:** Create `backend/functions/src/schema.ts`.

Exposes exact path templates and TypeScript interfaces used across all modules.

- [ ] Path constants (`invitationsPath`, `relationshipsPath`, etc.).
- [ ] Interfaces `Invitation`, `Relationship`, `Reminder`, `AuditLog`, `WorshipDigest`.
- [ ] Enum `InvitationStatus`, `RelationshipStatus`, `ReminderStatus`.
- [ ] `assertGuardianMatches(whoIs, rel)` throw helper.

### Task 3: Invitations callable + token issuance

**Files:** Create `backend/functions/src/invitations.ts`; test in `test/invitations.test.ts`.

Function `createInvitation(guardianId, tokenPlain)`:
1. Hashes `tokenPlain` with `crypto.createHash('sha256')`.
2. Writes doc to `invitations/{id}` with status `pending`, expiry in 24h.
3. Returns `{invitationId}`.
4. Audit logs `invitation_created`.

- [ ] Test: fails when caller != guardianId.
- [ ] Test: token is hashed in DB.
- [ ] Test: expiry set +3h past 24h.
- [ ] Test: `invitation_created` audit entry exists.

### Task 4: Relationship acceptance — the consent gate

**Files:** Create `backend/functions/src/relationships.ts`.

Function `acceptInvitation(childId, invitationId)`:
1. Reads invitation atomically in a transaction.
2. Rejects if status != `pending` or expired.
3. Writes `relationships/{relId}` with both `guardianId`, `childId`, `consentedAt`, `consentVersion`.
4. Sets invitation `status='accepted'`, `usedAt`.
5. Returns `{relationshipId}`.
6. Audit: `relationship_created`.
7. Deletes any stale cache doc used by child app.

- [ ] Test: only child who owns invitation scope can call.
- [ ] Test: cannot re-accept used invitation.
- [ ] Test: expired invitation rejected.
- [ ] Test: `relationship_created` audit entry.

### Task 5: Revocation and stop-monitoring

**Files:** Modify `relationships.ts`.

Functions:
- `revokeAccess(childId, relationshipId)` → sets `status='revoked'`, `revokedAt`, `revokedBy=child`.
- `stopMonitoring(guardianId, relationshipId)` → sets `status='stopped'`, `revokedAt=now`, `revokedBy=guardian`.
- Both publish `{type:'relationship_revoked', relId}` to Firestore via doc write for FCM trigger.

- [ ] Test: child can revoke own relationship.
- [ ] Test: guardian can stop own monitoring.
- [ ] Test: unrelated actor rejected.
- [ ] Test: audit `relationship_revoked`.

### Task 6: Reminder template & send callable

**Files:** Create `backend/functions/src/reminders.ts`.

Function `sendStandardReminder({guardianId, childId, worshipDate, activityKey, templateKey})`:
1. Validates relationship active in transaction.
2. Checks rate limit: one reminder for child+guardian+activity+date allowed; else return `{status:'rate_limited'}`.
3. Writes `reminders/{id}` with status `sent`.
4. Publishes FCM message to topic `user-events-{childId}` with data `activityId`,`reminderId`,`templateKey` (no PII body — notification built client-side).

- [ ] Test: rejects when relationship not active.
- [ ] Test: second reminder within window → rate limited.
- [ ] Test: successful write to reminders + status `sent`.
- [ ] Test: no PII in payload.

### Task 7: Family digest callable

**Files:** Create `backend/functions/src/digest.ts`.

Function `getFamilyDigest({guardianId, date})`:
- Reads active relationships.
- For each child, pulls worship records for date from existing `daily_records`.
- Returns summary counts + raw record ids; child does NOT compute — returns data, not UI formatting.
- Enforces rate limit (1 call/min per caller).

- [ ] Test: returns empty list when no children.
- [ ] Test: only returns children with active relationship.
- [ ] Test: does not error if child record missing.

### Task 8: Auth triggers for cleanup and onboarding

**Files:** Add to `relationships.ts`.

Callable `trigger: onDelete(user)` in `functions/`:
- Soft-delete `guardians/{uid}` row when account deleted.
- Revoke all `relationships/{relId}` where uid in `{guardianId|childId}` via batch update to status `user_deleted`.
- Keep worship data untouched.
- Audit `user_deleted`.

- [ ] Test: deleting user revokes all relationships.
- [ ] Test: worship records preserved after cleanup.

### Task 9: Security Rules

**Files:** Create `backend/firestore.rules`.

- `guardians/{g}` — read: request.auth.uid == g. write: same; cannot update child-owned worship.
- `children/{c}` — read by active relationship guardian; read: `exists(relationships/... active)`. write: read-only; guardians cannot write worship collections.
- `invitations/{i}` — read: status==accepted only by guardian+child involved. write: only on create by guardian; update only functions.
- `relationships/{r}` — read by both parties. write: functions only.
- `reminders/{r}` — read by both parties; write: functions only; guardian cannot change past reminders.
- `auditLogs/{a}` — read: deny all from client (functions write only).
- Add `// TODO(app-check)` comments; full enforcement via env flag.

- [ ] Test: child cannot be read by unrelated guardian via direct doc path.
- [ ] Test: guardian cannot write worship doc.
- [ ] Test: expired invitation not readable.

### Task 10: Local emulator integration

- [ ] `.env.yaml` created with staging config.
- [ ] `firebase init functions` ran without prompt.
- [ ] `npm run serve` emulator spins with rules + functions + Firestore.
- [ ] All `mocha` tests pass via `npm test` against emulator suite.

### Task 11: Cross-app integration smoke test

**Files:** Create `backend/test/integration/contract.test.ts`.

Spins up emulators, creates two users (guardian + child), runs end-to-end:
create invitation → wait → accept → read digest → send reminder → revoke → assert guardian denied.

- [ ] PASS against emulator suite.
