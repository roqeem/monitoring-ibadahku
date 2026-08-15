# Monitoring IbadahKu — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build three related software units — Firebase backend (Cloud Functions + Security Rules + audit), child-side IbadahKu family-access features, and a new Android Flutter app Monitoring IbadahKu (guardian dashboard + standard reminders + device cache) — plus supporting docs, all driven by `PRD.md`.

**Architecture:** Monorepo layout at `monitor-ibadahku` containing `backend/`, `child/`, `guardian/`, and `docs/`. Backend is contract-first: Functions expose callable endpoints that both apps consume, so child and guardian sub-apps can be developed against frozen APIs after backend stabilizes. Each sub-app owns isolated Firestore paths and is covered by rules asserting `request.auth.uid` matches the authenticated user for that app.

**Tech Stack:** Firebase (Auth, Firestore, Functions, Cloud Messaging, App Check), TypeScript (strict), Cloud Firestore Security Rules v2, Flutter 3.x (Dart), Firebase CLI Emulator Suite.

**Spec:**
- `./PRD.md` — product requirements (source of truth for features)
- `./prd_app_ibadahku.md` — existing child-app PRD (context for child-side changes)

## Global Constraints

- Firebase project namespacing: staging `monitor-ibadahku-dev`, prod `monitor-ibadahku` (created/assigned by platform admin before functions deploy).
- TypeScript 5.x + strict mode + `prettier` + `eslint` configured in `backend/`.
- Dart SDK >= 3.4; Flutter stable >= 3.22.
- Android minSdk 21; targetSdk 34; compileSdk 34.
- Firestore in Native mode (Firestore v2 rules).
- App Check enforcement MUST be enabled on `users`, `invitations`, `relationships`, `reminders`, `auditLogs` collections **after** dev testing (gated by a feature flag in functions env).
- All function entry points log via structured `console.log` with `event` + `uid`-free correlation id; never log PII or invitation token hash.
- Guardian app UI MUST be Bahasa Indonesia, neutral language only (no punitive copy); read `docs/superpowers/specs/language-guidelines.txt` if created, else follow `PRD.md` §19.2.
- No cross-account data leakage — every query in both apps asserts the authenticated `uid` participates in the relationship for the queried `childId`.

---

## Sub-plans

Because this is a multi-subsystem build with shared backend contract, it is decomposed into four sub-plans, each independently executable and testable after the backend contract stabilizes.

- **Plan A** (backend): `/docs/superpowers/plans/2026-08-15-monitoring-ibadahku-backend.md`
- **Plan B** (child IbadahKu features): `/docs/superpowers/plans/2026-08-15-monitoring-ibadahku-child.md`
- **Plan C** (guardian Flutter app): `/docs/superpowers/plans/2026-08-15-monitoring-ibadahku-guardian.md`
- **Plan D** (docs & legal): `/docs/superpowers/plans/2026-08-15-monitoring-ibadahku-docs.md`

### Execution ordering

1. Plan A first (defines schema, auth, functions, rules, FCM).
2. Plan D can run in parallel with Plan A (no code dependency).
3. Plans B and C must NOT start until Plan A's contract is verified stable by the plan owner; they proceed in parallel thereafter.
4. Cross-app integration tests (covered in Plan A's task 11 and Plan C's task 22) require both apps built and deployed to the Firebase emulator.

---

## Shared Contracts (frozen once Plan A task 3 passes)

These appear verbatim in at least one task of Plan A. Plans B and C reference them but MUST NOT redefine.

### Firestore paths

- `guardians/{guardianId}` — profile written by Guardian app; read by both.
- `children/{childId}` — profile; owned by child app.
- `invitations/{invitationId}` — `{tokenHash, guardianId, status, createdAt, expiresAt, usedAt?}`.
- `relationships/{relId}` — `{guardianId, childId, invitationId, status, consentVersion, consentedAt, revokedAt?, revokedBy?, createdAt, updatedAt}`.
- `reminders/{reminderId}` — `{guardianId, childId, relationshipId, activityId, worshipDate, status, sentAt?, failureCode?}`.
- `auditLogs/{logId}` — `{event, actorId, role, resourceIdHash, result, occurredAt, sessionIdHash}`.
- Worship data stays under the existing `IbadahKu` schema (`daily_records`, etc.) — **no writes from Guardian app or Functions**; read-only via rules.

### Callable Functions (HTTPS)

- `createInvitation(parentUid, tokenHash) → invitationId`
- `acceptInvitation(childUid, invitationId) → relationshipId`
- `revokeAccess(childUid, relationshipId) → ok`
- `stopMonitoring(guardianUid, relationshipId) → ok`
- `sendStandardReminder(payload) → reminderId` (payload = `{childId, worshipDate, activityKey, templateKey}`)
- `getFamilyDigest(guardianUid, date) → digest`

### FCM

- Topic `user-events-{uid}` used for per-user delivery, not cross-account broadcasting.

### Android deep link (child app)

`https://ibadahku.app/open/activity/{activityId}?reminderId={reminderId}` — opens IbadahKu with scroll-to focus; **NOT** a toggle action.
