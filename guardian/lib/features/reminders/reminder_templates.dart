/// Template pengingat standar — netral, tanpa penilaian moral (PRD §9.9).
/// Menentukan aktivitas yang didukung + pesan standar yang akan ditampilkan
/// di aplikasi IbadahKu anak. `activityKey` harus konsisten dengan keys
/// yang ditulis child app ke `daily_records` (`prayers`, `sunnahs`, `dhikrs`).
library;

class ReminderTemplate {
  final String activityKey;
  final String label;
  final String message;

  const ReminderTemplate({
    required this.activityKey,
    required this.label,
    required this.message,
  });
}

/// Daftar aktivitas yang mendukung pengingat (PRD §9.9).
const List<ReminderTemplate> kReminderTemplates = [
  ReminderTemplate(
    activityKey: 'subuh',
    label: 'Shalat Subuh',
    message: 'Pengingat lembut untuk mencatat Shalat Subuh di IbadahKu.',
  ),
  ReminderTemplate(
    activityKey: 'dzuhur',
    label: 'Shalat Dzuhur',
    message: 'Pengingat lembut untuk mencatat Shalat Dzuhur di IbadahKu.',
  ),
  ReminderTemplate(
    activityKey: 'ashar',
    label: 'Shalat Ashar',
    message: 'Pengingat lembut untuk mencatat Shalat Ashar di IbadahKu.',
  ),
  ReminderTemplate(
    activityKey: 'maghrib',
    label: 'Shalat Maghrib',
    message: 'Pengingat lembut untuk mencatat Shalat Maghrib di IbadahKu.',
  ),
  ReminderTemplate(
    activityKey: 'isya',
    label: 'Shalat Isya',
    message: 'Pengingat lembut untuk mencatat Shalat Isya di IbadahKu.',
  ),
  ReminderTemplate(
    activityKey: 'tahajud',
    label: 'Shalat Tahajud',
    message: 'Saat sempat, silakan periksa aktivitas Tahajud di IbadahKu.',
  ),
  ReminderTemplate(
    activityKey: 'witir',
    label: 'Shalat Witir',
    message: 'Saat sempat, silakan periksa aktivitas Witir di IbadahKu.',
  ),
  ReminderTemplate(
    activityKey: 'dhuha',
    label: 'Shalat Dhuha',
    message: 'Saat sempat, silakan periksa aktivitas Dhuha di IbadahKu.',
  ),
  ReminderTemplate(
    activityKey: 'rawatib',
    label: 'Shalat Rawatib',
    message: 'Saat sempat, silakan periksa aktivitas Rawatib di IbadahKu.',
  ),
  ReminderTemplate(
    activityKey: 'dzikir_pagi',
    label: 'Dzikir Pagi',
    message: 'Saat sempat, silakan periksa aktivitas Dzikir Pagi di IbadahKu.',
  ),
  ReminderTemplate(
    activityKey: 'dzikir_petang',
    label: 'Dzikir Petang',
    message: 'Saat sempat, silakan periksa aktivitas Dzikir Petang di IbadahKu.',
  ),
  ReminderTemplate(
    activityKey: 'dzikir_setelah_shalat',
    label: 'Dzikir Setelah Shalat',
    message: 'Saat sempat, silakan periksa aktivitas Dzikir Setelah Shalat di IbadahKu.',
  ),
  ReminderTemplate(
    activityKey: 'doa_tidur',
    label: 'Doa & Dzikir Sebelum Tidur',
    message: 'Saat sempat, silakan periksa Doa & Dzikir Sebelum Tidur di IbadahKu.',
  ),
];

ReminderTemplate templateForKey(String key) => kReminderTemplates.firstWhere(
      (t) => t.activityKey == key,
      orElse: () => kReminderTemplates.first,
    );
