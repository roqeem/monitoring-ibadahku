/// Penjadwalan pengingat ibadah (Fase 5).
///
/// Menggunakan `flutter_local_notifications` + `timezone` untuk alarm
/// presisi berbasis jadwal shalat. Jadwal dihitung ulang setiap kali
/// pengaturan berubah (lokasi, koreksi waktu, metode, dsb.) dan saat
/// aplikasi dibuka. Notifikasi terjadwal bertahan setelah perangkat
/// restart (plugin mendaftarkan receiver BOOT_COMPLETED).
library;

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../models/models.dart';
import '../data/prayer_times.dart';
import 'azan_player.dart';

/// Aktivitas yang mendukung pengingat (id -> sumber waktu).
///
/// `base` = nama waktu dari [PrayerTimesResult], `deltaMin` = pergeseran
/// menit setelah waktu dasar (untuk dzikir petang & sebelum tidur).
class ReminderTimeRef {
  final String base;
  final int deltaMin;
  const ReminderTimeRef(this.base, [this.deltaMin = 0]);
}

const Map<String, ReminderTimeRef> kReminderTimeRefs = {
  'tahajud': ReminderTimeRef('sepertigaMalam'),
  'witir': ReminderTimeRef('sepertigaMalam'),
  'subuh': ReminderTimeRef('subuh'),
  'dhuha': ReminderTimeRef('dhuha'),
  'dzuhur': ReminderTimeRef('dzuhur'),
  'ashar': ReminderTimeRef('ashar'),
  'dzikir_petang': ReminderTimeRef('ashar', 30),
  'maghrib': ReminderTimeRef('maghrib'),
  'isya': ReminderTimeRef('isya'),
  'sebelum_tidur': ReminderTimeRef('isya', 90),
};

class ReminderService {
  ReminderService._();
  static final ReminderService instance = ReminderService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  final AzanPlayer azan = AzanPlayer();

  bool _initialized = false;
  static const int _scheduleDays = 14;

  /// Batas hari penjadwalan ke depan.
  static const int scheduleDays = _scheduleDays;

  bool get initialized => _initialized;

  Future<void> init() async {
    if (_initialized) return;
    tzdata.initializeTimeZones();
    try {
      final name = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(name.identifier));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
    }

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings =
        InitializationSettings(android: androidInit, iOS: DarwinInitializationSettings());
    await _plugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: _onTap,
    );
    _initialized = true;
  }

  Future<void> _onTap(NotificationResponse res) async {
    // Aksi "Mainkan azan" atau tap notifikasi azan -> putar azan.
    if (res.payload == null) return;
    try {
      final p = jsonDecode(res.payload!) as Map<String, dynamic>;
      if (p['kind'] == 'azan') await azan.play();
    } catch (_) {}
  }

  /// Periksa apakah notifikasi aktif (izin + toggle sistem).
  Future<bool> notificationsEnabled() async {
    try {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      return await android?.areNotificationsEnabled() ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Minta izin notifikasi (Android 13+).
  Future<bool> requestPermission() async {
    try {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      return await android?.requestNotificationsPermission() ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Minta izin alarm presisi. Android 12+ memerlukannya untuk
  /// `exactAllowWhileIdle`. Jika ditolak, jadwal tetap dibuat dengan mode
  /// tidak presisi sebagai fallback. Tidak ada API periksa status; request
  /// saat izin sudah ada tidak memunculkan dialog.
  Future<bool> ensureExactAlarm() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return false;
    try {
      return await android.requestExactAlarmsPermission() ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Detail peluncuran dari notifikasi (untuk cold start azan).
  Future<NotificationAppLaunchDetails?> launchDetails() async {
    try {
      return await _plugin.getNotificationAppLaunchDetails();
    } catch (_) {
      return null;
    }
  }

  /// Batalkan semua pengingat.
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  /// Susun ulang seluruh pengingat untuk [settings] berdasarkan jadwal
  /// shalat [prayerTimesFn], untuk [days] hari ke depan.
  Future<void> rescheduleAll({
    required UserSettings settings,
    required PrayerTimesResult Function(DateTime) prayerTimesFn,
    int days = _scheduleDays,
  }) async {
    if (!_initialized) await init();
    await cancelAll();

    if (!settings.notificationsPermissionGranted) return;

    final now = DateTime.now();
    for (var d = 0; d < days; d++) {
      final date = DateTime(now.year, now.month, now.day).add(Duration(days: d));
      final pt = prayerTimesFn(date);
      for (final entry in settings.reminders.entries) {
        final activityId = entry.key;
        final r = entry.value;
        if (!r.enabled || r.kind == ReminderKind.tanpa) continue;
        final ref = kReminderTimeRefs[activityId];
        if (ref == null) continue;

        final base = _timeFor(pt, ref.base);
        if (base == null) continue;
        final trigger = base.add(Duration(minutes: ref.deltaMin - r.offsetMin));
        if (!trigger.isAfter(now)) continue;

        await _schedule(activityId, r, trigger, date);
      }
    }
  }

  DateTime? _timeFor(PrayerTimesResult pt, String base) => switch (base) {
        'subuh' => pt.subuh,
        'dhuha' => pt.dhuha,
        'dzuhur' => pt.dzuhur,
        'ashar' => pt.ashar,
        'maghrib' => pt.maghrib,
        'isya' => pt.isya,
        'sepertigaMalam' => pt.sepertigaMalam,
        _ => null,
      };

  Future<void> _schedule(String activityId, ReminderSetting r, DateTime trigger,
      DateTime date) async {
    final id = _notificationId(activityId, date);
    final title = _titleFor(activityId);
    final body = r.offsetMin == 0
        ? 'Sudah masuk waktunya.'
        : '${r.offsetMin} menit lagi.';

    final exact = await ensureExactAlarm();

    AndroidNotificationDetails android;
    switch (r.kind) {
      case ReminderKind.azan:
        android = AndroidNotificationDetails(
          'ibadahku_reminders',
          'Pengingat ibadah',
          channelDescription: 'Pengingat jadwal ibadah harian',
          importance: Importance.max,
          priority: Priority.max,
          category: AndroidNotificationCategory.alarm,
          playSound: false,
          fullScreenIntent: true,
          actions: [
            AndroidNotificationAction(
              'play_azan',
              'Mainkan azan',
              showsUserInterface: false,
            ),
          ],
        );
      case ReminderKind.getar:
        android = AndroidNotificationDetails(
          'ibadahku_reminders',
          'Pengingat ibadah',
          channelDescription: 'Pengingat jadwal ibadah harian',
          importance: Importance.high,
          priority: Priority.high,
          playSound: false,
          vibrationPattern: Int64List.fromList([0, 400, 200, 400]),
        );
      default:
        android = AndroidNotificationDetails(
          'ibadahku_reminders',
          'Pengingat ibadah',
          channelDescription: 'Pengingat jadwal ibadah harian',
          importance: Importance.high,
          priority: Priority.high,
        );
    }

    final details = NotificationDetails(android: android);
    final payload = jsonEncode({'activityId': activityId, 'kind': r.kind.name});

    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(trigger, tz.local),
      notificationDetails: details,
      androidScheduleMode: exact
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexactAllowWhileIdle,
      payload: payload,
    );
  }

  int _notificationId(String activityId, DateTime date) {
    // id stabil per aktivitas+hari agar tidak dobel saat reschedule.
    final dayNum =
        date.difference(DateTime(date.year)).inDays + date.month * 40;
    return (activityId.hashCode & 0xFFFF) + dayNum * 31;
  }

  String _titleFor(String activityId) => switch (activityId) {
        'tahajud' => 'Shalat Tahajud',
        'witir' => 'Shalat Witir',
        'subuh' => 'Shalat Subuh',
        'dhuha' => 'Shalat Dhuha',
        'dzuhur' => 'Shalat Dzuhur',
        'ashar' => 'Shalat Ashar',
        'dzikir_petang' => 'Dzikir petang',
        'maghrib' => 'Shalat Maghrib',
        'isya' => 'Shalat Isya',
        'sebelum_tidur' => 'Doa & dzikir sebelum tidur',
        _ => 'Ibadah',
      };
}
