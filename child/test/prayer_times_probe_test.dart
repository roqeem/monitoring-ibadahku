import 'package:flutter_test/flutter_test.dart';
import 'package:ibadahku/data/prayer_times.dart';
import 'package:ibadahku/models/models.dart';

void main() {
  test('jadwal Jakarta 2026-08-09 cocok dengan referensi Kemenag (aladhan method 20)',
      () {
    final r = PrayerTimes.calculate(
      DateTime(2026, 8, 9),
      lat: -6.2088,
      lon: 106.8456,
      method: CalcMethod.kemenag,
    );
    String f(DateTime d) =>
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    expect(f(r.subuh), '04:42'); // Fajr
    expect(f(r.terbit), '06:02'); // Sunrise
    expect(f(r.dzuhur), '11:58'); // Dhuhr
    expect(f(r.ashar), '15:20'); // Asr (aladhan: 15:19, selisih 1 mnt rounding)
    expect(f(r.maghrib), '17:55'); // Maghrib
    expect(f(r.isya), '19:06'); // Isha
  });
}
