# Monitoring IbadahKu — Guardian App (Plan C)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development or superpowers:executing-plans to implement this plan task-by-task.

**Goal:** New Android Flutter app (Bahasa Indonesia) — guardian dashboard showing family worship data read-only, with standard reminder sending and offline cache.

**Spec:** `./PRD.md` all, contract doc, `backend/firestore.rules`.

## Precondition

- Plan A contract signed off (task 11).
- Plan B running in parallel; no data-write conflict (guardian never writes worship data).

## Project scaffold (one-time)

- Create `guardian/android/`, `guardian/ios/`, `guardian/lib/`, `guardian/pubspec.yaml` package `com.ibadahku.guardian`.
- Use `flutter create -t app` then overwrite `lib/main.dart`.

## Global Constraints

- Android minSdk 21, targetSdk 34, compileSdk 34.
- Bahasa Indonesia only in MVP UI copy.
- Offline cache via `shared_preferences` typed + Firestore offline persistence fallback.
- FCM permission requested at onboarding.

## Files

- Create `guardian/lib/main.dart`
- Create `guardian/lib/auth/auth_gate.dart`
- Create `guardian/lib/auth/login_page.dart`
- Create `guardian/lib/onboarding/onboarding_flow.dart`
- Create `guardian/lib/home/home_page.dart`
- Create `guardian/lib/family/child_tile.dart`
- Create `guardian/lib/family/child_detail_screen.dart`
- Create `guardian/lib/history/history_screen.dart`
- Create `guardian/lib/statistics/statistics_screen.dart`
- Create `guardian/lib/reminders/send_reminder_action.dart`
- Create `guardian/lib/reminders/reminder_repository.dart`
- Create `guardian/lib/reminders/reminders_history_screen.dart`
- Create `guardian/lib/notifications/notification_service.dart`
- Create `guardian/lib/offline/cache_manager.dart`
- Create `guardian/lib/settings/settings_page.dart`
- Create `guardian/test/unit/...`
- Create `guardian/test/widget/...`

## Tasks

### Task 1: App + Auth scaffold

- [ ] `main.dart` boots `MaterialApp` with `auth_gate.dart`.
- [ ] `auth_gate.dart` uses `FirebaseAuth.instance.authStateChanges()`; unauthenticated → `login_page.dart`.
- [ ] `login_page.dart` offers Google + email; no IbadahKu account auto-linking.
- [ ] Test: widget test login button renders.

### Task 2: Onboarding wali

- [ ] Collect `displayName`, `declaredRelationship`, notification consent.
- [ ] Calls Callable `createInvitation` only when user taps "Tambah anak" from onboarding → stored in `guardian/` profile; invitation created server-side.
- [ ] Test: onboarding form valid only when displayName filled.

### Task 3: Beranda multi-anak

- [ ] `home_page.dart` calls `getFamilyDigest({guardianId, date=now})`.
- [ ] Renders a card per child with status icons and last-updated.
- [ ] Uses neutral copy ("Belum tercatat" not "gagal").
- [ ] Test: empty list shows empty-state string.

### Task 4: Detail anak — today snapshot

- [ ] `child_detail_screen.dart` tabs: Hari Ini, Riwayat, Statistik, Pengingat.
- [ ] Reads worship doc via Firestore; guards with `guardianId` filter client-side (rules enforce anyway).
- [ ] Read-only — no edit icons shown.
- [ ] Test: status list shows correct icons.

### Task 5: Riwayat anak

- [ ] `history_screen.dart` queries `daily_records` for date range; supports 7-day, 30-day, month, custom range.
- [ ] Filters for prayer type, place, etc.
- [ ] Test: selecting date opens detail (mock Firestore).

### Task 6: Statistik anak

- [ ] `statistics_screen.dart` builds bar/donut via `fl_chart`.
- [ ] Filters per PRD §9.8.
- [ ] Shows `child_id` label, never compares children.
- [ ] Test: chart renders expected bars for fixture data.

### Task 7: Detail catatan pribadi

- [ ] Read field `notes` from prayer/dhikr record; show with `Data pribadi yang dibagikan`.
- [ ] No copy to clipboard.
- [ ] Test: note visible but cannot be selected.

### Task 8: Kirim pengingat standar

- [ ] `send_reminder_action.dart` calls `sendStandardReminder` with rate limit awareness.
- [ ] Uses PRD §9.9 template key mapping.
- [ ] Disables button when rate-limited and shows next-allowed time from `reminders` query.
- [ ] Test: second reminder mocked → returns rate_limited.

### Task 9: Riwayat pengingat

- [ ] `reminders_history_screen.dart` lists sent reminders per child.
- [ ] Test: empty shows "Belum ada pengingat".

### Task 10: Notifikasi + deep link

- [ ] `notification_service.dart` requests POST_NOTIFICATIONS; subscribes to topic `user-events-{uid}`.
- [ ] Handles tap → opens activity deep link in IbadahKu via `flutter_launch_url` if installed else fallback to web auth screen.
- [ ] Test: notification data parsed without crash.

### Task 11: Cache offline

- [ ] `cache_manager.dart` — typed cache of daily snapshot keyed by `(childId, date)`.
- [ ] Cache shows "Data terakhir diperbarui" + timestamp.
- [ ] On `relationship_revoked`, cache for that child wiped.
- [ ] Test: revoke event triggers wipe (unit).

### Task 12: Pengaturan & akun

- [ ] `settings_page.dart` groups: akun, notifikasi, keluarga, data.
- [ ] "Berhenti pantau anak" → calls `stopMonitoring`.
- [ ] "Hapus akun" → Auth delete + callable to wipe guardian doc + relationships.

### Task 13: Penghapusan akun

- [ ] Confirm + re-auth.
- [ ] Calls backend `cleanupOnUserDelete` equivalent (client invokes callable that soft-deletes guardian record).
- [ ] Worship data remains.

### Task 14: Pengujian UI real device

- [ ] Run app on Android 11+, 13+, 14.
- [ ] Test dark + light theme toggle from system.
- [ ] Font scale 1.5 passes accessibility contrast.
- [ ] Test deep link open to correct activity.

### Task 15: Aksesibilitas & kontras

- [ ] All icons have `semanticLabel`.
- [ ] Text contrast ≥ 4.5:1.
- [ ] Test: `talkBack` reads every actionable element.

## Definition of Done

- [ ] App builds APK with no crash on first open after login.
- [ ] At least 70% unit coverage on reminder logic (run `flutter test --coverage`).
- [ ] No cross-account data visible in offline cache after logout.
- [ ] App size < 25 MB APK.
