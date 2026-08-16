import 'package:flutter_test/flutter_test.dart';

import 'package:ibadahku/models/models.dart';
import 'package:ibadahku/state/app_state.dart';

void main() {
  test('statsFor tidak crash saat range mencakup Jumat dengan data jumat', () {
    final state = AppState();
    // enableFridayFeature default true.
    expect(state.settings.enableFridayFeature, isTrue);

    final friday = DateTime(2026, 8, 7);
    expect(friday.weekday, DateTime.friday);

    state.day(friday).prayers['jumat'] = PrayerRecord(
      status: PrayerStatus.done,
      congregation: Congregation.jamaah,
      timeCategory: TimeCategory.awal,
      place: Place.masjid,
      completedAt: DateTime(2026, 8, 7, 12, 0),
    );

    final stats = state.statsFor(DateTime(2026, 8, 3), DateTime(2026, 8, 9));

    expect(stats['fardhuDone'], 1);
    final perPrayer = stats['perPrayer'] as Map<String, Map<String, int>>;
    expect(perPrayer['jumat']!['done'], 1);
  });
}
