/// Perhitungan jadwal shalat — dibungkus dari paket `adhan_dart`
/// (implementasi akurat berbasis "Astronomical Algorithms" Jean Meeus,
/// dikembangkan dari batoulapps/Adhan yang dipakai banyak aplikasi).
///
/// Frontend-first: hasil dihitung lokal dari koordinat + tanggal. Koreksi
/// menit per shalat dapat diterapkan dari Pengaturan.
library;

import 'package:adhan_dart/adhan_dart.dart' as adhan;

import '../models/models.dart';

class PrayerTimesResult {
  final DateTime subuh;
  final DateTime terbit;
  final DateTime dhuha;
  final DateTime dzuhur;
  final DateTime ashar;
  final DateTime maghrib;
  final DateTime isya;
  final DateTime sepertigaMalam;

  const PrayerTimesResult({
    required this.subuh,
    required this.terbit,
    required this.dhuha,
    required this.dzuhur,
    required this.ashar,
    required this.maghrib,
    required this.isya,
    required this.sepertigaMalam,
  });

  DateTime? forPrayer(String name) {
    switch (name) {
      case 'subuh':
        return subuh;
      case 'dzuhur':
        return dzuhur;
      case 'ashar':
        return ashar;
      case 'maghrib':
        return maghrib;
      case 'isya':
        return isya;
      case 'jumat':
        return dzuhur;
    }
    return null;
  }

  static const List<(String, String)> kOrder = [
    ('subuh', 'Subuh'),
    ('terbit', 'Terbit'),
    ('dhuha', 'Dhuha'),
    ('dzuhur', 'Dzuhur'),
    ('ashar', 'Ashar'),
    ('maghrib', 'Maghrib'),
    ('isya', 'Isya'),
    ('sepertigaMalam', 'Sepertiga Malam'),
  ];
}

class PrayerTimes {
  /// Hitung jadwal untuk [date] di [lat]/[lon] dengan [method], juristik
  /// Ashar [asrJuristic], dan koreksi [adjustments] (prayerName -> menit).
  static PrayerTimesResult calculate(
    DateTime date, {
    required double lat,
    required double lon,
    CalcMethod method = CalcMethod.kemenag,
    AsrJuristic asrJuristic = AsrJuristic.shafii,
    Map<String, int> adjustments = const {},
  }) {
    // ishaAngleOrMin >= 50 berarti menit setelah maghrib (mis. Makkah 90),
    // bukan sudut.
    final ishaInterval = method.ishaAngleOrMin >= 50
        ? method.ishaAngleOrMin.round()
        : 0;

    final params = adhan.CalculationParameters(
      method: adhan.CalculationMethod.other,
      fajrAngle: method.fajrAngle,
      ishaAngle: ishaInterval > 0 ? 18 : method.ishaAngleOrMin,
      ishaInterval: ishaInterval,
      madhab: asrJuristic == AsrJuristic.hanafi
          ? adhan.Madhab.hanafi
          : adhan.Madhab.shafi,
      adjustments: {
        adhan.Prayer.fajr: adjustments['subuh'] ?? 0,
        adhan.Prayer.dhuhr: adjustments['dzuhur'] ?? 0,
        adhan.Prayer.asr: adjustments['ashar'] ?? 0,
        adhan.Prayer.maghrib: adjustments['maghrib'] ?? 0,
        adhan.Prayer.isha: adjustments['isya'] ?? 0,
      },
    );

    final pt = adhan.PrayerTimes(
      date: date,
      coordinates: adhan.Coordinates(lat, lon),
      calculationParameters: params,
    );
    final sunnah = adhan.SunnahTimes(pt);

    // adhan_dart mengembalikan DateTime UTC -> konversi ke waktu lokal.
    DateTime local(DateTime u) => u.toLocal();

    return PrayerTimesResult(
      subuh: local(pt.fajr),
      terbit: local(pt.sunrise),
      dhuha: local(pt.sunrise).add(const Duration(minutes: 15)),
      dzuhur: local(pt.dhuhr),
      ashar: local(pt.asr),
      maghrib: local(pt.maghrib),
      isya: local(pt.isha),
      sepertigaMalam: local(sunnah.lastThirdOfTheNight),
    );
  }
}
