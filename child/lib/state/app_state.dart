/// State pusat aplikasi (ChangeNotifier).
///
/// Data lokal di SharedPreferences; bila Firebase aktif, disinkronkan ke
/// cloud (pull saat login, push tiap perubahan).
library;

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/local_store.dart';
import '../data/prayer_times.dart';
import '../data/worship_content.dart';
import '../models/models.dart';
import '../services/firebase_service.dart';
import '../services/reminder_service.dart';

// ---------------------------------------------------------------------------
// Model timeline
// ---------------------------------------------------------------------------

enum ActivityStatus { pending, partial, done, missed, uzur }

extension ActivityStatusX on ActivityStatus {
  String get label => switch (this) {
        ActivityStatus.pending => 'Belum dicatat',
        ActivityStatus.partial => 'Sebagian',
        ActivityStatus.done => 'Selesai',
        ActivityStatus.missed => 'Terlewat',
        ActivityStatus.uzur => 'Tidak wajib',
      };
}

enum ActivityKind { fardhu, sunnah, dhikr }

class ActivityItem {
  final String id;
  final ActivityKind kind;
  final String title;
  final String subtitle;
  final ActivityStatus status;
  final String? prayerName;
  final String? sunnahType;
  final String? dhikrContentId;
  final String? dhikrBlock;

  const ActivityItem({
    required this.id,
    required this.kind,
    required this.title,
    required this.subtitle,
    required this.status,
    this.prayerName,
    this.sunnahType,
    this.dhikrContentId,
    this.dhikrBlock,
  });
}

class TimelineSection {
  final String id;
  final String title;
  final String timeLabel;
  final List<ActivityItem> items;
  const TimelineSection({
    required this.id,
    required this.title,
    required this.timeLabel,
    required this.items,
  });
}

// ---------------------------------------------------------------------------
// AppState
// ---------------------------------------------------------------------------

class AppState extends ChangeNotifier {
  final LocalStore store = LocalStore();
  bool loaded = false;

  UserProfile? user;
  UserSettings settings = UserSettings();
  Map<String, DailyData> days = {};
  List<SpecialCondition> conditions = [];
  DateTime _currentDate = DateUtils.dateOnly(DateTime.now());
  DateTime get currentDate => _currentDate;
  set currentDate(DateTime d) {
    _currentDate = DateUtils.dateOnly(d);
    notifyListeners();
  }

  DateTime? lastSyncAt;
  bool syncing = false;

  // -- init ----------------------------------------------------------------
  Future<void> init() async {
    user = await store.loadUser();
    settings = await store.loadSettings();
    days = await store.loadDays();
    conditions = await store.loadConditions();
    await rescheduleReminders();
    loaded = true;
    notifyListeners();
  }

  Future<void> _persistDays() async {
    await store.saveDays(days);
    unawaited(_pushCloud());
  }

  Future<void> _persistSettings() async {
    await store.saveSettings(settings);
    unawaited(_pushCloud());
  }

  // -- sinkronisasi cloud ---------------------------------------------------

  /// Push state lokal ke Firestore (fire-and-forget).
  Future<void> _pushCloud() async {
    final fb = FirebaseService.instance;
    final u = user;
    if (!fb.available || u == null || u.loginMethod == 'demo') return;
    try {
      // Simpan profil ke `children/{cid}` (dibaca guardian)
      await fb.saveChildProfile(u.id, {
        'displayName': u.displayName,
        'email': u.email,
        'photoUrl': null,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      // Push ke `users/{uid}` (sinkronisasi lokal antar-device)
      await fb.saveUserData(u.id, {
        'settings': settings.toJson(),
        'days': days.map((k, v) => MapEntry(k, v.toJson())),
        'updatedAt': DateTime.now().toIso8601String(),
      });

      // Push `daily_records/{childId}_{date}` per tanggal (dibaca guardian)
      for (final entry in days.entries) {
        final key = entry.key;
        final record = entry.value;
        if (record.prayers.isEmpty &&
            record.sunnahs.isEmpty &&
            record.dhikrs.isEmpty) continue;
        await fb.saveDailyRecord(u.id, key, _toCloudRecord(u.id, key, record));
      }
    } catch (_) {} // offline: biarkan lokal, push berikutnya.
  }

  /// Pull data cloud saat login; menimpa lokal bila ada (restore device baru).
  Future<void> _pullCloud() async {
    final fb = FirebaseService.instance;
    final u = user;
    if (!fb.available || u == null || u.loginMethod == 'demo') return;
    try {
      final data = await fb.loadUserData(u.id);
      if (data == null || !data.containsKey('settings')) return;
      settings =
          UserSettings.fromJson(data['settings'] as Map<String, dynamic>);
      days = (data['days'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(
                  k, DailyData.fromJson(v as Map<String, dynamic>))) ??
          {};
      await _persistSettings();
      await store.saveDays(days);
      await rescheduleReminders();
      notifyListeners();
    } catch (_) {}
  }

  // -- auth -----------------------------------------------------------------
  Future<void> login(UserProfile u) async {
    user = u;
    await store.saveUser(u);
    // Subscribe ke topik FCM family reminders
    final fb = FirebaseService.instance;
    if (fb.available && u.loginMethod != 'demo') {
      unawaited(fb.subscribeToFamilyTopic(u.id));
    }
    await _pullCloud(); // restore data cloud bila ada
    notifyListeners();
  }

  Future<void> logout() async {
    final fb = FirebaseService.instance;
    final uid = user?.id;
    if (uid != null && fb.available) {
      unawaited(fb.unsubscribeFromFamilyTopic(uid));
    }
    if (fb.available) await fb.signOut();
    user = null;
    await store.clearUser();
    await store.saveOnboarding(false);
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    await store.saveOnboarding(true);
    notifyListeners();
  }

  bool get onboardingDone => user != null;

  Future<void> updateProfile({String? name, String? gender}) async {
    if (user == null) return;
    user = UserProfile(
      id: user!.id,
      displayName: name ?? user!.displayName,
      email: user!.email,
      gender: gender ?? user!.gender,
      loginMethod: user!.loginMethod,
      createdAt: user!.createdAt,
    );
    await store.saveUser(user!);
    notifyListeners();
  }

  Future<void> deleteAccount() async {
    await store.wipeAll();
    user = null;
    days = {};
    conditions = [];
    settings = UserSettings();
    notifyListeners();
  }

  // -- settings -------------------------------------------------------------
  Future<void> updateSettings(UserSettings s) async {
    settings = s;
    await _persistSettings();
    await rescheduleReminders();
    notifyListeners();
  }

  // -- helpers tanggal ------------------------------------------------------
  static String dateKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  static DateTime dateFromKey(String k) {
    final p = k.split('-');
    return DateTime(int.parse(p[0]), int.parse(p[1]), int.parse(p[2]));
  }

  static DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  PrayerTimesResult prayerTimes(DateTime d) => PrayerTimes.calculate(
        d,
        lat: settings.latitude,
        lon: settings.longitude,
        method: settings.calcMethod,
        asrJuristic: settings.asrMethod,
        adjustments: settings.timeAdjustments,
      );

  DailyData day(DateTime d) {
    final k = dateKey(d);
    return days.putIfAbsent(k, () => DailyData(dateKey: k));
  }

  bool isFuture(DateTime d) => d.isAfter(dateOnly(DateTime.now()));

  // -- kondisi khusus --------------------------------------------------------
  List<SpecialCondition> conditionsOn(DateTime d) {
    final target = dateOnly(d);
    return conditions
        .where((c) =>
            !target.isBefore(dateOnly(c.startDate)) &&
            !target.isAfter(dateOnly(c.endDate)))
        .toList();
  }

  bool hasCondition(DateTime d, SpecialConditionType type) =>
      conditionsOn(d).any((c) => c.type == type);

  Future<void> addCondition(SpecialCondition c) async {
    conditions.add(c);
    await store.saveConditions(conditions);
    notifyListeners();
  }

  Future<void> removeCondition(String id) async {
    conditions.removeWhere((c) => c.id == id);
    await store.saveConditions(conditions);
    notifyListeners();
  }

  // -- record shalat ----------------------------------------------------------
  PrayerRecord prayer(DateTime d, String name) =>
      day(d).prayers[name] ?? PrayerRecord();

  Future<void> setPrayer(
      DateTime d, String name, PrayerRecord record) async {
    day(d).prayers[name] = record;
    await _persistDays();
    notifyListeners();
  }

  // -- record sunnah ---------------------------------------------------------
  SunnahRecord sunnah(DateTime d, String type) =>
      day(d).sunnahs[type] ?? SunnahRecord();

  Future<void> setSunnah(DateTime d, String type, SunnahRecord r) async {
    day(d).sunnahs[type] = r;
    await _persistDays();
    notifyListeners();
  }

  // -- record dzikir/doa ------------------------------------------------------
  String _dhikrKey(String contentId, String? block) =>
      block == null ? contentId : '$contentId|$block';

  DhikrRecord dhikr(DateTime d, String contentId, {String? block}) =>
      day(d).dhikrs[_dhikrKey(contentId, block)] ?? DhikrRecord();

  Future<void> _saveDhikr(
      DateTime d, String contentId, String? block, DhikrRecord r) async {
    day(d).dhikrs[_dhikrKey(contentId, block)] = r;
    await _persistDays();
    notifyListeners();
  }

  Future<void> toggleDhikrItem(DateTime d, String contentId,
      {String? block, required String itemId, required bool checked}) async {
    final seq = sequenceById(contentId);
    final rec = dhikr(d, contentId, block: block);
    var count = rec.completedItems;
    final wasChecked = count >= seq.items.indexWhere((i) => i.id == itemId) + 1;
    if (checked && !wasChecked) count++;
    if (!checked && wasChecked) count--;
    count = count.clamp(0, seq.items.length);
    final rec2 = DhikrRecord(
      completedItems: count,
      totalItems: seq.items.length,
      completed: count >= seq.items.length,
      completedAt: DateTime.now(),
    );
    await _saveDhikr(d, contentId, block, rec2);
  }

  Future<void> setDhikrAll(DateTime d, String contentId,
      {String? block, required bool done}) async {
    final seq = sequenceById(contentId);
    final rec = DhikrRecord(
      completedItems: done ? seq.items.length : 0,
      totalItems: seq.items.length,
      completed: done,
      completedAt: done ? DateTime.now() : null,
    );
    await _saveDhikr(d, contentId, block, rec);
  }

  // -- timeline ---------------------------------------------------------------
  List<TimelineSection> timeline(DateTime d) {
    final pt = prayerTimes(d);
    final isFriday = d.weekday == DateTime.friday;
    final friday = settings.enableFridayFeature && isFriday;
    final haid = hasCondition(d, SpecialConditionType.haid);

    String fmt(DateTime t) => DateFormat(settings.use24h ? 'HH:mm' : 'h:mm a')
        .format(t.toLocal());

    List<ActivityItem> items = [];

    ActivityItem fardhu(String name, String title, {String? subtitle}) {
      final r = prayer(d, name);
      final status = switch (r.status) {
        PrayerStatus.done || PrayerStatus.qadha ||
            PrayerStatus.jamaQasar =>
          ActivityStatus.done,
        PrayerStatus.uzur => ActivityStatus.uzur,
        PrayerStatus.missed => ActivityStatus.missed,
        PrayerStatus.notDone => ActivityStatus.pending,
      };
      final sub = r.status == PrayerStatus.notDone
          ? (subtitle ?? 'Belum dicatat')
          : r.status.label;
      return ActivityItem(
        id: 'prayer:$name',
        kind: ActivityKind.fardhu,
        title: title,
        subtitle: haid && r.status == PrayerStatus.notDone ? 'Belum dicatat' : sub,
        status: status,
        prayerName: name,
      );
    }

    ActivityItem sunnahItem(String type, String title, String subtitle) {
      final r = sunnah(d, type);
      final status = r.completed
          ? ActivityStatus.done
          : (r.rakaat > 0 ? ActivityStatus.partial : ActivityStatus.pending);
      return ActivityItem(
        id: 'sunnah:$type',
        kind: ActivityKind.sunnah,
        title: title,
        subtitle: r.completed
            ? '${r.rakaat} rakaat'
            : (r.rakaat > 0 ? '${r.rakaat} rakaat · belum ditandai selesai' : subtitle),
        status: status,
        sunnahType: type,
      );
    }

    ActivityItem dhikrItem(String contentId, String title, {String? block}) {
      final seq = sequenceById(contentId);
      final r = dhikr(d, contentId, block: block);
      final status = r.completed
          ? ActivityStatus.done
          : (r.completedItems > 0 ? ActivityStatus.partial : ActivityStatus.pending);
      final sub = r.completed
          ? '${r.completedItems} dari ${r.totalItems} selesai'
          : (r.completedItems > 0
              ? '${r.completedItems} dari ${r.totalItems}'
              : '${seq.items.length} bacaan');
      return ActivityItem(
        id: 'dhikr:$contentId${block == null ? '' : '|$block'}',
        kind: ActivityKind.dhikr,
        title: title,
        subtitle: sub,
        status: status,
        dhikrContentId: contentId,
        dhikrBlock: block,
      );
    }

    final sections = <TimelineSection>[];

    // A. Sepertiga malam
    items = [
      dhikrItem('doa_bangun_tidur', 'Doa Bangun Tidur'),
      sunnahItem('tahajud', 'Shalat Tahajud', '2–100 rakaat (genap)'),
      sunnahItem('witir', 'Shalat Witir', '1–99 rakaat (ganjil)'),
    ];
    sections.add(TimelineSection(
        id: 'sepertiga_malam',
        title: 'Sepertiga Malam',
        timeLabel: fmt(pt.sepertigaMalam),
        items: items));

    // B. Subuh
    items = [
      sunnahItem('qabliyah_subuh', 'Qabliyah Subuh', '2 rakaat sebelum Subuh'),
      fardhu('subuh', 'Shalat Subuh', subtitle: '2 rakaat'),
      dhikrItem('dzikir_setelah_shalat', 'Dzikir Setelah Shalat', block: 'subuh'),
      dhikrItem('dzikir_pagi', 'Dzikir Pagi'),
    ];
    sections.add(TimelineSection(
        id: 'subuh', title: 'Subuh', timeLabel: fmt(pt.subuh), items: items));

    // C. Pagi (Dhuha)
    items = [sunnahItem('dhuha', 'Shalat Dhuha', '2–100 rakaat (genap)')];
    sections.add(TimelineSection(
        id: 'pagi', title: 'Pagi', timeLabel: fmt(pt.dhuha), items: items));

    // D. Dzuhur / Jumat
    items = [];
    if (friday) {
      items.addAll([
        sunnahItem('jumat_mandi', 'Mandi Jumat', 'Sunnah mandi hari Jumat'),
        sunnahItem('jumat_kahfi', 'Membaca Surah Al-Kahfi', 'Bacaan sunnah hari Jumat'),
        sunnahItem('jumat_datang_awal', 'Datang Lebih Awal', 'Ke masjid sebelum khutbah'),
        fardhu('jumat', 'Shalat Jumat', subtitle: 'Pengganti Dzuhur'),
        sunnahItem('jumat_sedekah', 'Sedekah Jumat', 'Bersedekah di hari Jumat'),
        sunnahItem('jumat_shalawat', 'Memperbanyak Shalawat', 'Shalawat kepada Nabi ﷺ'),
      ]);
    } else {
      items.addAll([
        sunnahItem('qabliyah_dzuhur', 'Qabliyah Dzuhur', '4 rakaat sebelum Dzuhur'),
        fardhu('dzuhur', 'Shalat Dzuhur', subtitle: '4 rakaat'),
        sunnahItem('badiyah_dzuhur', 'Ba\'diyah Dzuhur', '2 rakaat setelah Dzuhur'),
      ]);
    }
    items.add(dhikrItem('dzikir_setelah_shalat', 'Dzikir Setelah Shalat', block: 'dzuhur'));
    sections.add(TimelineSection(
        id: 'dzuhur',
        title: friday ? 'Jumat' : 'Dzuhur',
        timeLabel: fmt(pt.dzuhur),
        items: items));

    // E. Ashar
    items = [];
    if (settings.enableQabliyahAshar) {
      items.add(sunnahItem('qabliyah_ashar', 'Qabliyah Ashar', '4 rakaat sebelum Ashar (tambahan)'));
    }
    items.addAll([
      fardhu('ashar', 'Shalat Ashar', subtitle: '4 rakaat'),
      dhikrItem('dzikir_setelah_shalat', 'Dzikir Setelah Shalat', block: 'ashar'),
      dhikrItem('dzikir_petang', 'Dzikir Petang'),
    ]);
    sections.add(TimelineSection(
        id: 'ashar', title: 'Ashar', timeLabel: fmt(pt.ashar), items: items));

    // F. Maghrib
    items = [];
    if (settings.enableQabliyahMaghrib) {
      items.add(sunnahItem('qabliyah_maghrib', 'Qabliyah Maghrib', '2 rakaat sebelum Maghrib (tambahan)'));
    }
    items.addAll([
      fardhu('maghrib', 'Shalat Maghrib', subtitle: '3 rakaat'),
      sunnahItem('badiyah_maghrib', 'Ba\'diyah Maghrib', '2 rakaat setelah Maghrib'),
      dhikrItem('dzikir_setelah_shalat', 'Dzikir Setelah Shalat', block: 'maghrib'),
    ]);
    sections.add(TimelineSection(
        id: 'maghrib', title: 'Maghrib', timeLabel: fmt(pt.maghrib), items: items));

    // G. Isya
    items = [];
    if (settings.enableQabliyahIsya) {
      items.add(sunnahItem('qabliyah_isya', 'Qabliyah Isya', '2 rakaat sebelum Isya (tambahan)'));
    }
    items.addAll([
      fardhu('isya', 'Shalat Isya', subtitle: '4 rakaat'),
      sunnahItem('badiyah_isya', 'Ba\'diyah Isya', '2 rakaat setelah Isya'),
      dhikrItem('dzikir_setelah_shalat', 'Dzikir Setelah Shalat', block: 'isya'),
    ]);
    sections.add(TimelineSection(
        id: 'isya', title: 'Isya', timeLabel: fmt(pt.isya), items: items));

    // H. Sebelum tidur
    items = [
      sunnahItem('baca_quran_100', 'Baca Al-Qur\'an minimal 100 ayat',
          'Pahala shalat semalam penuh'),
      sunnahItem('wudhu_sebelum_tidur', 'Berwudhu sebelum tidur',
          'Tidur dalam keadaan suci'),
      dhikrItem('dzikir_sebelum_tidur', 'Dzikir Sebelum Tidur'),
      dhikrItem('doa_sebelum_tidur', 'Doa Sebelum Tidur'),
    ];
    sections.add(TimelineSection(
        id: 'sebelum_tidur',
        title: 'Sebelum Tidur',
        timeLabel: 'Malam',
        items: items));

    return sections;
  }

  /// (selesai, total) untuk satu tanggal. Status uzur dihitung selesai
  /// karena tidak wajib. Kondisi haid/nifas tidak dianggap terlewat.
  (int, int) progressOf(DateTime d) {
    int done = 0, total = 0;
    for (final s in timeline(d)) {
      for (final it in s.items) {
        total++;
        if (it.status == ActivityStatus.done || it.status == ActivityStatus.uzur) {
          done++;
        }
      }
    }
    return (done, total);
  }

  // -------------------------------------------------------------------------
  // Statistik
  // -------------------------------------------------------------------------

  Iterable<DateTime> eachDay(DateTime start, DateTime end) sync* {
    var d = dateOnly(start);
    final last = dateOnly(end);
    while (!d.isAfter(last)) {
      yield d;
      d = d.add(const Duration(days: 1));
    }
  }

  Map<String, dynamic> statsFor(DateTime start, DateTime end) {
    int fardhuDone = 0, fardhuJamaah = 0, fardhuSendiri = 0;
    int fardhuAwal = 0, fardhuAkhir = 0, fardhuQadha = 0, fardhuMissed = 0;
    int fardhuMasjid = 0, fardhuRumah = 0, fardhuUzur = 0;
    int tahajud = 0, witir = 0, dhuha = 0, rawatib = 0;
    int dzikirPagi = 0, dzikirPetang = 0, doaSebelumTidur = 0;
    int doaBangun = 0, dzikirSetelah = 0, dzikirSebelumTidur = 0;
    int totalTercatat = 0;

    final perPrayer = <String, Map<String, int>>{
      for (final n in (settings.enableFridayFeature
              ? [...kFardhuOrder, 'jumat']
              : kFardhuOrder))
        n: {
          'done': 0, 'jamaah': 0, 'sendiri': 0, 'awal': 0, 'akhir': 0,
          'qadha': 0, 'missed': 0, 'masjid': 0, 'rumah': 0, 'uzur': 0,
        },
    };

    for (final d in eachDay(start, end)) {
      final haid = hasCondition(d, SpecialConditionType.haid);

      // fardhu
      final fardhuNames = settings.enableFridayFeature && d.weekday == DateTime.friday
          ? ['jumat']
          : kFardhuOrder;
      for (final name in fardhuNames) {
        final r = prayer(d, name);
        if (r.status == PrayerStatus.done || r.status == PrayerStatus.qadha ||
            r.status == PrayerStatus.jamaQasar) {
          fardhuDone++;
          totalTercatat++;
          if (r.status == PrayerStatus.qadha || r.status == PrayerStatus.jamaQasar) {
            fardhuQadha++;
          }
          if (r.congregation == Congregation.jamaah) fardhuJamaah++;
          if (r.congregation == Congregation.sendiri) fardhuSendiri++;
          if (r.timeCategory == TimeCategory.awal) fardhuAwal++;
          if (r.timeCategory == TimeCategory.akhir) fardhuAkhir++;
          if (r.place == Place.masjid) fardhuMasjid++;
          if (r.place == Place.rumah) fardhuRumah++;
          final m = perPrayer[name]!;
          m['done'] = m['done']! + 1;
          if (r.status == PrayerStatus.qadha || r.status == PrayerStatus.jamaQasar) {
            m['qadha'] = m['qadha']! + 1;
          }
          if (r.congregation == Congregation.jamaah) m['jamaah'] = m['jamaah']! + 1;
          if (r.congregation == Congregation.sendiri) m['sendiri'] = m['sendiri']! + 1;
          if (r.timeCategory == TimeCategory.awal) m['awal'] = m['awal']! + 1;
          if (r.timeCategory == TimeCategory.akhir) m['akhir'] = m['akhir']! + 1;
          if (r.place == Place.masjid) m['masjid'] = m['masjid']! + 1;
          if (r.place == Place.rumah) m['rumah'] = m['rumah']! + 1;
        } else if (r.status == PrayerStatus.uzur) {
          fardhuUzur++;
          perPrayer[name]!['uzur'] = perPrayer[name]!['uzur']! + 1;
        } else if (r.status == PrayerStatus.missed && !haid) {
          fardhuMissed++;
          perPrayer[name]!['missed'] = perPrayer[name]!['missed']! + 1;
        }
      }

      // sunnah
      final s = day(d).sunnahs;
      for (final e in s.entries) {
        if (!e.value.completed) continue;
        final t = e.key;
        totalTercatat++;
        if (t == 'tahajud') tahajud++;
        if (t == 'witir') witir++;
        if (t == 'dhuha') dhuha++;
        if (t.startsWith('qabliyah_') || t.startsWith('badiyah_')) rawatib++;
      }

      // dzikir & doa
      final dh = day(d).dhikrs;
      for (final e in dh.entries) {
        if (!e.value.completed) continue;
        final t = e.key.split('|').first;
        totalTercatat++;
        if (t == 'dzikir_pagi') dzikirPagi++;
        if (t == 'dzikir_petang') dzikirPetang++;
        if (t == 'dzikir_sebelum_tidur') dzikirSebelumTidur++;
        if (t == 'doa_sebelum_tidur') doaSebelumTidur++;
        if (t == 'doa_bangun_tidur') doaBangun++;
        if (t == 'dzikir_setelah_shalat') dzikirSetelah++;
      }
    }

    return {
      'fardhuDone': fardhuDone,
      'fardhuJamaah': fardhuJamaah,
      'fardhuSendiri': fardhuSendiri,
      'fardhuAwal': fardhuAwal,
      'fardhuAkhir': fardhuAkhir,
      'fardhuQadha': fardhuQadha,
      'fardhuMissed': fardhuMissed,
      'fardhuMasjid': fardhuMasjid,
      'fardhuRumah': fardhuRumah,
      'fardhuUzur': fardhuUzur,
      'tahajud': tahajud,
      'witir': witir,
      'dhuha': dhuha,
      'rawatib': rawatib,
      'dzikirPagi': dzikirPagi,
      'dzikirPetang': dzikirPetang,
      'doaSebelumTidur': doaSebelumTidur,
      'doaBangun': doaBangun,
      'dzikirSetelah': dzikirSetelah,
      'dzikirSebelumTidur': dzikirSebelumTidur,
      'totalTercatat': totalTercatat,
      'perPrayer': perPrayer,
    };
  }

  /// Data line chart konsistensi harian: (tanggal, jumlah aktivitas selesai).
  List<(DateTime, int)> dailyConsistency(DateTime start, DateTime end) {
    final out = <(DateTime, int)>[];
    for (final d in eachDay(start, end)) {
      final (done, _) = progressOf(d);
      out.add((d, done));
    }
    return out;
  }

  /// Ringkasan per tanggal untuk kalender konsistensi.
  Map<String, int> calendarSummary(DateTime month) {
    final first = DateTime(month.year, month.month, 1);
    final last = DateTime(month.year, month.month + 1, 0);
    final out = <String, int>{};
    for (final d in eachDay(first, last)) {
      final (done, total) = progressOf(d);
      int level = 0; // 0 kosong, 1 sebagian, 2 lengkap, 3 kondisi khusus
      if (conditionsOn(d).any((c) => c.type == SpecialConditionType.haid)) {
        level = 3;
      } else if (total > 0 && done == total) {
        level = 2;
      } else if (done > 0) {
        level = 1;
      }
      out[dateKey(d)] = level;
    }
    return out;
  }

  // -- pengingat --------------------------------------------------------------
  ReminderSetting reminderFor(String activityId) =>
      settings.reminders[activityId] ?? ReminderSetting();

  Future<void> setReminder(String activityId, ReminderSetting r) async {
    final s = settings.copy();
    s.reminders[activityId] = r;
    settings = s;
    await _persistSettings();
    await rescheduleReminders();
    notifyListeners();
  }

  /// Susun ulang seluruh pengingat berdasarkan settings saat ini.
  /// Dipanggil saat init, ganti pengaturan, dan selesai onboarding.
  Future<void> rescheduleReminders() async {
    try {
      await ReminderService.instance.rescheduleAll(
        settings: settings,
        prayerTimesFn: prayerTimes,
      );
    } catch (e) {
      debugPrint('rescheduleReminders gagal: $e');
    }
  }

  // -- sinkronisasi (simulasi) -------------------------------------------------
  Future<void> syncNow() async {
    if (syncing) return;
    syncing = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 900));
    syncing = false;
    lastSyncAt = DateTime.now();
    notifyListeners();
  }

  String get syncStatusLabel {
    if (syncing) return 'Sedang sinkronisasi…';
    if (lastSyncAt == null) return 'Belum pernah sinkron';
    final f = DateFormat('d MMM yyyy, HH:mm');
    return 'Terakhir sinkron: ${f.format(lastSyncAt!)} (simulasi lokal)';
  }

  // -- data -------------------------------------------------------------------
  Future<void> clearRiwayat() async {
    days = {};
    await _persistDays();
    notifyListeners();
  }

  Future<void> clearLocalData() async {
    days = {};
    conditions = [];
    await store.saveDays(days);
    await store.saveConditions(conditions);
    notifyListeners();
  }

  /// Seeder demo: isi beberapa hari terakhir dengan data contoh agar
  /// halaman statistik & riwayat langsung terlihat.
  void seedDemoData() {
    final now = dateOnly(DateTime.now());
    final rnd = math.Random(7);
    for (var back = 0; back < 10; back++) {
      final d = now.subtract(Duration(days: back));
      final isFriday = d.weekday == DateTime.friday;
      final names = settings.enableFridayFeature && isFriday
          ? ['jumat']
          : kFardhuOrder;
      for (final n in names) {
        final skip = rnd.nextInt(10) < 2;
        if (skip) continue;
        day(d).prayers[n] = PrayerRecord(
          status: rnd.nextInt(10) < 7 ? PrayerStatus.done : PrayerStatus.jamaQasar,
          place: Place.values[rnd.nextInt(Place.values.length)],
          congregation: rnd.nextInt(10) < 6
              ? Congregation.jamaah
              : Congregation.sendiri,
          timeCategory: TimeCategory.values[rnd.nextInt(3)],
          completedAt: d.add(Duration(hours: 4 + rnd.nextInt(12))),
        );
      }
      if (rnd.nextInt(10) < 5) {
        day(d).sunnahs['tahajud'] =
            SunnahRecord(rakaat: 2, completed: true, completedAt: d.add(const Duration(hours: 3)));
      }
      if (rnd.nextInt(10) < 4) {
        day(d).sunnahs['witir'] =
            SunnahRecord(rakaat: 3, completed: true, completedAt: d.add(const Duration(hours: 4)));
      }
      if (rnd.nextInt(10) < 6) {
        day(d).sunnahs['dhuha'] =
            SunnahRecord(rakaat: 4, completed: true, completedAt: d.add(const Duration(hours: 8)));
      }
      if (rnd.nextInt(10) < 7) {
        for (final t in ['qabliyah_subuh', 'qabliyah_dzuhur', 'badiyah_dzuhur', 'badiyah_maghrib', 'badiyah_isya']) {
          if (rnd.nextInt(10) < 6) {
            day(d).sunnahs[t] = SunnahRecord(rakaat: 2, completed: true);
          }
        }
      }
      final dhikrTypes = ['dzikir_pagi', 'dzikir_petang', 'dzikir_sebelum_tidur', 'doa_sebelum_tidur'];
      for (final t in dhikrTypes) {
        if (rnd.nextInt(10) < 6) {
          final seq = sequenceById(t);
          day(d).dhikrs[t] =
              DhikrRecord(completedItems: seq.items.length, totalItems: seq.items.length, completed: true);
        }
      }
      for (final b in kFardhuOrder) {
        if (rnd.nextInt(10) < 7) {
          final seq = sequenceById('dzikir_setelah_shalat');
          day(d).dhikrs['dzikir_setelah_shalat|$b'] = DhikrRecord(
              completedItems: seq.items.length, totalItems: seq.items.length, completed: true);
        }
      }
    }
    _persistDays();
    notifyListeners();
  }

  // -- cloud record mapping --------------------------------------------------

  /// Convert DailyData to Firestore document readable by getFamilyDigest.
  /// backend reads: prayers (map status), sunnah (map completed), dhikr (map completed), doa (map completed)
  Map<String, dynamic> _toCloudRecord(String childId, String dateKey, DailyData d) {
    final prayers = <String, Map<String, String>>{};
    for (final e in d.prayers.entries) {
      prayers[e.key] = {'status': _prayerStatusLabel(e.value.status)};
    }
    final sunnahMap = <String, Map<String, bool>>{};
    for (final e in d.sunnahs.entries) {
      sunnahMap[e.key] = {'completed': e.value.completed};
    }
    final dhikrMap = <String, Map<String, bool>>{};
    for (final e in d.dhikrs.entries) {
      dhikrMap[e.key] = {'completed': e.value.completed};
    }
    return {
      'childId': childId,
      'dateKey': dateKey,
      'worshipDate': dateKey,
      'prayers': prayers,
      'sunnah': sunnahMap,
      'dhikr': dhikrMap,
      'doa': <String, Map<String, bool>>{},
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  String _prayerStatusLabel(PrayerStatus s) => switch (s) {
        PrayerStatus.done => 'Tercatat',
        PrayerStatus.qadha => 'Qadha',
        PrayerStatus.jamaQasar => 'Jama/Qasar',
        PrayerStatus.notDone => 'Belum dikerjakan',
        PrayerStatus.missed => 'Terlewat',
        PrayerStatus.uzur => 'Tidak wajib',
      };
}
