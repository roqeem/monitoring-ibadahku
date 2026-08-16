/// Model data inti IbadahKu.
/// Seluruh record disimpan per tanggal (waktu lokal) dan diserialisasi ke JSON.
library;

import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// Enum & label Bahasa Indonesia (bahasa netral, tanpa penilaian moral)
// ---------------------------------------------------------------------------

enum PrayerName {
  subuh('Subuh'),
  dzuhur('Dzuhur'),
  ashar('Ashar'),
  maghrib('Maghrib'),
  isya('Isya'),
  jumat('Jumat');

  final String label;
  const PrayerName(this.label);

  static PrayerName fromKey(String k) =>
      PrayerName.values.firstWhere((e) => e.name == k, orElse: () => PrayerName.subuh);
}

enum PrayerStatus {
  notDone('Belum dicatat'),
  done('Sudah dikerjakan'),
  missed('Terlewat'),
  qadha('Dicatat sebagai qadha'),
  jamaQasar('Jama/Qasar'),
  uzur('Tidak wajib karena uzur syar\'i');

  final String label;
  const PrayerStatus(this.label);

  bool get isComplete => this == done || this == qadha || this == jamaQasar;
  static PrayerStatus fromKey(String k) => PrayerStatus.values
      .firstWhere((e) => e.name == k, orElse: () => PrayerStatus.notDone);
}

enum Place {
  masjid('Masjid'),
  musala('Musala'),
  rumah('Rumah'),
  kerja('Tempat kerja'),
  lain('Tempat lainnya');

  final String label;
  const Place(this.label);
  static Place? fromKey(String? k) => k == null
      ? null
      : Place.values.where((e) => e.name == k).firstOrNull;
}

enum Congregation {
  jamaah('Berjamaah'),
  sendiri('Sendiri');

  final String label;
  const Congregation(this.label);
  static Congregation? fromKey(String? k) => k == null
      ? null
      : Congregation.values.where((e) => e.name == k).firstOrNull;
}

enum TimeCategory {
  awal('Awal waktu'),
  dalamWaktu('Masih dalam waktu'),
  akhir('Akhir waktu'),
  luarWaktu('Di luar waktu atau qadha');

  final String label;
  const TimeCategory(this.label);
  static TimeCategory? fromKey(String? k) => k == null
      ? null
      : TimeCategory.values.where((e) => e.name == k).firstOrNull;
}

enum SpecialConditionType {
  haid('Haid / Nifas'),
  musafir('Musafir'),
  sakit('Sakit');

  final String label;
  const SpecialConditionType(this.label);
  static SpecialConditionType fromKey(String k) => SpecialConditionType.values
      .firstWhere((e) => e.name == k, orElse: () => SpecialConditionType.haid);
}

enum CalcMethod {
  kemenag('Kemenag RI', 20.0, 18.0),
  mwl('Muslim World League', 18.0, 17.0),
  isna('ISNA', 15.0, 15.0),
  egypt('Egyptian General Authority', 19.5, 17.5),
  makkah('Umm Al-Qura, Makkah', 18.5, 90.0),
  karachi('University of Islamic Sciences, Karachi', 18.0, 18.0);

  final String label;
  final double fajrAngle;
  final double ishaAngleOrMin;
  const CalcMethod(this.label, this.fajrAngle, this.ishaAngleOrMin);
  static CalcMethod fromKey(String k) => CalcMethod.values
      .firstWhere((e) => e.name == k, orElse: () => CalcMethod.kemenag);
}

enum AsrJuristic {
  shafii('Syafi\'i (bayangan 1x)'),
  hanafi('Hanafi (bayangan 2x)');

  final String label;
  const AsrJuristic(this.label);
  static AsrJuristic fromKey(String k) => AsrJuristic.values
      .firstWhere((e) => e.name == k, orElse: () => AsrJuristic.shafii);
}

enum ReminderKind { azan, notif, getar, tanpa }

extension ReminderKindX on ReminderKind {
  String get label => name == 'azan'
      ? 'Suara azan'
      : name == 'notif'
          ? 'Notifikasi biasa'
          : name == 'getar'
              ? 'Getar'
              : 'Tanpa pengingat';
  static ReminderKind fromKey(String k) => ReminderKind.values
      .firstWhere((e) => e.name == k, orElse: () => ReminderKind.tanpa);
}

// ---------------------------------------------------------------------------
// Profil & pengaturan
// ---------------------------------------------------------------------------

class UserProfile {
  final String id;
  final String displayName;
  final String email;
  final String gender; // pria | wanita | lainnya
  final String loginMethod; // google | email | demo
  final DateTime createdAt;

  UserProfile({
    required this.id,
    required this.displayName,
    required this.email,
    required this.gender,
    required this.loginMethod,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'displayName': displayName,
        'email': email,
        'gender': gender,
        'loginMethod': loginMethod,
        'createdAt': createdAt.toIso8601String(),
      };

  factory UserProfile.fromJson(Map<String, dynamic> j) => UserProfile(
        id: j['id'] as String,
        displayName: j['displayName'] as String? ?? '',
        email: j['email'] as String? ?? '',
        gender: j['gender'] as String? ?? '',
        loginMethod: j['loginMethod'] as String? ?? 'email',
        createdAt: DateTime.tryParse(j['createdAt'] as String? ?? '') ?? DateTime.now(),
      );
}

class ReminderSetting {
  bool enabled;
  ReminderKind kind;
  int offsetMin; // 0,5,10,15,30 atau waktu khusus

  ReminderSetting({this.enabled = false, this.kind = ReminderKind.notif, this.offsetMin = 0});

  Map<String, dynamic> toJson() => {'enabled': enabled, 'kind': kind.name, 'offsetMin': offsetMin};

  factory ReminderSetting.fromJson(Map<String, dynamic> j) => ReminderSetting(
        enabled: j['enabled'] as bool? ?? false,
        kind: ReminderKindX.fromKey(j['kind'] as String? ?? 'notif'),
        offsetMin: j['offsetMin'] as int? ?? 0,
      );
}

class UserSettings {
  double latitude;
  double longitude;
  String cityName;
  CalcMethod calcMethod;
  AsrJuristic asrMethod;
  Map<String, int> timeAdjustments; // prayerName -> menit koreksi
  ThemeMode theme; // light | dark | system
  bool showLatin;
  bool showTranslation;
  double arabicFontSize;
  bool use24h;
  // aktivitas sunnah tambahan
  bool enableQabliyahAshar;
  bool enableQabliyahMaghrib;
  bool enableQabliyahIsya;
  bool enableFridayFeature;
  // pengingat per aktivitas: activityId -> ReminderSetting
  Map<String, ReminderSetting> reminders;
  bool notificationsPermissionGranted;

  UserSettings({
    this.latitude = -6.2088,
    this.longitude = 106.8456,
    this.cityName = 'Jakarta',
    this.calcMethod = CalcMethod.kemenag,
    this.asrMethod = AsrJuristic.shafii,
    this.timeAdjustments = const {},
    this.theme = ThemeMode.system,
    this.showLatin = true,
    this.showTranslation = true,
    this.arabicFontSize = 22,
    this.use24h = true,
    this.enableQabliyahAshar = false,
    this.enableQabliyahMaghrib = false,
    this.enableQabliyahIsya = false,
    this.enableFridayFeature = true,
    this.reminders = const {},
    this.notificationsPermissionGranted = false,
  });

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        'cityName': cityName,
        'calcMethod': calcMethod.name,
        'asrMethod': asrMethod.name,
        'timeAdjustments': timeAdjustments,
        'theme': theme.name,
        'showLatin': showLatin,
        'showTranslation': showTranslation,
        'arabicFontSize': arabicFontSize,
        'use24h': use24h,
        'enableQabliyahAshar': enableQabliyahAshar,
        'enableQabliyahMaghrib': enableQabliyahMaghrib,
        'enableQabliyahIsya': enableQabliyahIsya,
        'enableFridayFeature': enableFridayFeature,
        'reminders': reminders.map((k, v) => MapEntry(k, v.toJson())),
        'notificationsPermissionGranted': notificationsPermissionGranted,
      };

  factory UserSettings.fromJson(Map<String, dynamic> j) => UserSettings(
        latitude: (j['latitude'] as num?)?.toDouble() ?? -6.2088,
        longitude: (j['longitude'] as num?)?.toDouble() ?? 106.8456,
        cityName: j['cityName'] as String? ?? 'Jakarta',
        calcMethod: CalcMethod.fromKey(j['calcMethod'] as String? ?? 'kemenag'),
        asrMethod: AsrJuristic.fromKey(j['asrMethod'] as String? ?? 'shafii'),
        timeAdjustments: (j['timeAdjustments'] as Map?)?.map(
                (k, v) => MapEntry(k as String, (v as num).toInt())) ??
            const {},
        theme: ThemeMode.values.firstWhere(
            (e) => e.name == (j['theme'] as String? ?? 'system'),
            orElse: () => ThemeMode.system),
        showLatin: j['showLatin'] as bool? ?? true,
        showTranslation: j['showTranslation'] as bool? ?? true,
        arabicFontSize: (j['arabicFontSize'] as num?)?.toDouble() ?? 22,
        use24h: j['use24h'] as bool? ?? true,
        enableQabliyahAshar: j['enableQabliyahAshar'] as bool? ?? false,
        enableQabliyahMaghrib: j['enableQabliyahMaghrib'] as bool? ?? false,
        enableQabliyahIsya: j['enableQabliyahIsya'] as bool? ?? false,
        enableFridayFeature: j['enableFridayFeature'] as bool? ?? true,
        reminders: (j['reminders'] as Map?)?.map(
                (k, v) => MapEntry(
                    k as String,
                    ReminderSetting.fromJson(v as Map<String, dynamic>))) ??
            const {},
        notificationsPermissionGranted: j['notificationsPermissionGranted'] as bool? ?? false,
      );

  UserSettings copy() => UserSettings.fromJson(toJson());
}

// ---------------------------------------------------------------------------
// Record harian
// ---------------------------------------------------------------------------

class PrayerRecord {
  PrayerStatus status;
  Place? place;
  Congregation? congregation;
  TimeCategory? timeCategory;
  String notes;
  DateTime? completedAt;

  PrayerRecord({
    this.status = PrayerStatus.notDone,
    this.place,
    this.congregation,
    this.timeCategory,
    this.notes = '',
    this.completedAt,
  });

  Map<String, dynamic> toJson() => {
        'status': status.name,
        'place': place?.name,
        'congregation': congregation?.name,
        'timeCategory': timeCategory?.name,
        'notes': notes,
        'completedAt': completedAt?.toIso8601String(),
      };

  factory PrayerRecord.fromJson(Map<String, dynamic> j) => PrayerRecord(
        status: PrayerStatus.fromKey(j['status'] as String? ?? 'notDone'),
        place: Place.fromKey(j['place'] as String?),
        congregation: Congregation.fromKey(j['congregation'] as String?),
        timeCategory: TimeCategory.fromKey(j['timeCategory'] as String?),
        notes: j['notes'] as String? ?? '',
        completedAt: DateTime.tryParse(j['completedAt'] as String? ?? ''),
      );

  PrayerRecord copy() => PrayerRecord.fromJson(toJson());
}

class SunnahRecord {
  int rakaat;
  bool completed;
  String notes;
  DateTime? completedAt;

  SunnahRecord({this.rakaat = 0, this.completed = false, this.notes = '', this.completedAt});

  Map<String, dynamic> toJson() => {
        'rakaat': rakaat,
        'completed': completed,
        'notes': notes,
        'completedAt': completedAt?.toIso8601String(),
      };

  factory SunnahRecord.fromJson(Map<String, dynamic> j) => SunnahRecord(
        rakaat: (j['rakaat'] as num?)?.toInt() ?? 0,
        completed: j['completed'] as bool? ?? false,
        notes: j['notes'] as String? ?? '',
        completedAt: DateTime.tryParse(j['completedAt'] as String? ?? ''),
      );
      SunnahRecord copy() => SunnahRecord(
          rakaat: rakaat, completed: completed, notes: notes, completedAt: completedAt);
}

class DhikrRecord {
  int completedItems;
  int totalItems;
  bool completed;
  DateTime? completedAt;

  DhikrRecord({this.completedItems = 0, this.totalItems = 0, this.completed = false, this.completedAt});

  Map<String, dynamic> toJson() => {
        'completedItems': completedItems,
        'totalItems': totalItems,
        'completed': completed,
        'completedAt': completedAt?.toIso8601String(),
      };

  factory DhikrRecord.fromJson(Map<String, dynamic> j) => DhikrRecord(
        completedItems: (j['completedItems'] as num?)?.toInt() ?? 0,
        totalItems: (j['totalItems'] as num?)?.toInt() ?? 0,
        completed: j['completed'] as bool? ?? false,
        completedAt: DateTime.tryParse(j['completedAt'] as String? ?? ''),
      );
}

class DailyData {
  final String dateKey; // yyyy-MM-dd waktu lokal
  final Map<String, PrayerRecord> prayers; // prayerName -> record
  final Map<String, SunnahRecord> sunnahs; // sunnahType -> record
  final Map<String, DhikrRecord> dhikrs; // contentKey -> record

  DailyData({
    required this.dateKey,
    Map<String, PrayerRecord>? prayers,
    Map<String, SunnahRecord>? sunnahs,
    Map<String, DhikrRecord>? dhikrs,
  })  : prayers = prayers ?? {},
        sunnahs = sunnahs ?? {},
        dhikrs = dhikrs ?? {};

  Map<String, dynamic> toJson() => {
        'dateKey': dateKey,
        'prayers': prayers.map((k, v) => MapEntry(k, v.toJson())),
        'sunnahs': sunnahs.map((k, v) => MapEntry(k, v.toJson())),
        'dhikrs': dhikrs.map((k, v) => MapEntry(k, v.toJson())),
      };

  factory DailyData.fromJson(Map<String, dynamic> j) => DailyData(
        dateKey: j['dateKey'] as String? ?? '',
        prayers: (j['prayers'] as Map?)?.map(
                (k, v) => MapEntry(k as String, PrayerRecord.fromJson(v as Map<String, dynamic>))) ??
            {},
        sunnahs: (j['sunnahs'] as Map?)?.map(
                (k, v) => MapEntry(k as String, SunnahRecord.fromJson(v as Map<String, dynamic>))) ??
            {},
        dhikrs: (j['dhikrs'] as Map?)?.map(
                (k, v) => MapEntry(k as String, DhikrRecord.fromJson(v as Map<String, dynamic>))) ??
            {},
      );
}

class SpecialCondition {
  final String id;
  final SpecialConditionType type;
  final DateTime startDate;
  final DateTime endDate;
  final String notes;

  SpecialCondition({
    required this.id,
    required this.type,
    required this.startDate,
    required this.endDate,
    this.notes = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'notes': notes,
      };

  factory SpecialCondition.fromJson(Map<String, dynamic> j) => SpecialCondition(
        id: j['id'] as String,
        type: SpecialConditionType.fromKey(j['type'] as String? ?? 'haid'),
        startDate: DateTime.tryParse(j['startDate'] as String? ?? '') ?? DateTime.now(),
        endDate: DateTime.tryParse(j['endDate'] as String? ?? '') ?? DateTime.now(),
        notes: j['notes'] as String? ?? '',
      );
}
