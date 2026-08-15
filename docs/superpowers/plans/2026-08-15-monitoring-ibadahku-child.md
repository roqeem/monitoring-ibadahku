# Monitoring IbadahKu — Child App Features (Plan B)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development or superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add family-access features to the existing IbadahKu (Flutter) app so children can view invitations, grant/revoke consent, manage guardians, and open reminder deep links — without modifying worship data.

**Spec:** `./PRD.md` §10 (child dependencies), parent contract doc, `./prd_app_ibadahku.md` §8.4/16 §16 (privacy).

## Precondition

Plan A must have **frozen the contract** (sub-plan list, task 11 signed off).

## Files

Assumes the existing IbadahKu Flutter project lives at `../ibadahku-app` (sibling). If not present, scaffold minimal Flutter project here at `child/` with package `com.ibadahku.child`.

- Create/modify under child app:
  - `lib/family/consent_screen.dart`
  - `lib/family/invitations_repository.dart`
  - `lib/family/relationships_repository.dart`
  - `lib/family/deep_link_handler.dart`
  - `lib/family/reminder_preferences.dart`
  - `lib/family/audit_log.dart` (optional local view)
  - Add route `/family/access` and `/family/invite/{code}`.
  - Add deep link handler for `https://ibadahku.app/open/activity/{activityId}?reminderId={reminderId}`.

## Tasks

### Task 1: Add dependency on parent Firebase project

- [ ] Ensure app flavor `dev` points to `monitor-ibadahku-dev`; `prod` to `monitor-ibadahku`.
- [ ] `firebase.json` includes `google-services.json` for both projects.

### Task 2: Consent + invitation scanner

- [ ] `consent_screen.dart` displays: guardian name/photo, declared relationship, consent version, readable permission text (`full_worship_read` maps to human language), `Setujui`/`Tolak` buttons.
- [ ] Scanner uses `mobile_scanner` to read `tokenPlain` QR or paste code.
- [ ] Calls `createInvitation` then `acceptInvitation` in that order (client gets `relationshipId`).
- [ ] Handles expiry + already-used states shown from Function error codes.
- [ ] Test: UI shows correct text when user taps `Setujui`.

### Task 3: Relationship management

- [ ] `relationships_repository.dart` lists `relationships` where user == childId and status `active`.
- [ ] Revoke button calls `revokeAccess` → optimistic UI then server confirm.
- [ ] List shows guardian name + declared role + since date.
- [ ] Test: revoking hides relationship locally after server OK.

### Task 4: Reminder mute preference

- [ ] `reminder_preferences.dart` writes a client-only doc `children/{cid}/reminderExceptions/{guardianId}/{activityKey}` with boolean `muted`.
- [ ] Guardian app must respect this if possible (optional for MVP; otherwise child rejects locally).
- [ ] Test: muting persists across app restart.

### Task 5: Deep link handling

- [ ] `deep_link_handler.dart` resolves `activityId` + `reminderId`.
- [ ] Scrolls `Hari Ini` / `Riwayat` timeline to the activity card; no toggle.
- [ ] Falls back to `Belum tercatat` card if not found.
- [ ] Test with mock deep link data; assertion that scroll target found.

### Task 6: Family hub entry point

- [ ] In IbadahKu `Pengaturan` add row "Akses Keluarga" → opens /family/access list.
- [ ] Shows guardians count, pending invites, last consent update.
- [ ] Test: tapping navigates without auth error.

### Task 7: Offline resilience

- [ ] Repository caches relationships via `shared_preferences` typed cache.
- [ ] Cache TTL 24h; silent refresh when online.
- [ ] Test: offline still shows last known guardians list.

## Definition of Done

- [ ] `acceptInvitation` end-to-end flow shown in integration test with emulator.
- [ ] No worship data write path added from child-side family code.
- [ ] Consent text reviewed for neutrality (use `PRD.md` neutral language list).
- [ ] Deep link opens correct activity on real Android device.
