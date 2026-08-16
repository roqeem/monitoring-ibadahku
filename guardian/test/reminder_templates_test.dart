import 'package:flutter_test/flutter_test.dart';
import 'package:monitoring_ibadahku/features/reminders/reminder_templates.dart';

void main() {
  test('reminder templates punya activityKey unik', () {
    final keys = kReminderTemplates.map((t) => t.activityKey).toList();
    expect(keys.toSet().length, keys.length, reason: 'duplikat activityKey');
  });

  test('templateForKey punya fallback aman', () {
    expect(templateForKey('tidak-ada').activityKey, 'subuh');
    expect(templateForKey('tahajud').label, 'Shalat Tahajud');
  });

  test('semua pesan netral (tanpa kata penghakiman)', () {
    const banned = ['malas', 'lupa terus', 'sial', 'buruk'];
    for (final t in kReminderTemplates) {
      final lower = t.message.toLowerCase();
      expect(banned.where(lower.contains), isEmpty,
          reason: 'pesan "${t.message}" mengandung kata penghakiman');
    }
  });
}
