import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/worship_content.dart';
import '../../family/consent_screen.dart';
import '../../family/family_access_screen.dart';
import '../../models/models.dart';
import '../../services/location_service.dart';
import '../../services/reminder_service.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';

/// Halaman Pengaturan — akun, tampilan, jadwal, pengingat, ibadah, data.
class PengaturanScreen extends StatelessWidget {
  const PengaturanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final user = state.user;

    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          // -----------------------------------------------------------------
          // Akun
          // -----------------------------------------------------------------
          SectionHeader(title: 'Akun'),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.doneSoft,
                    child: Text(
                      user?.displayName.isNotEmpty == true
                          ? user!.displayName[0].toUpperCase()
                          : 'I',
                      style: const TextStyle(
                          color: AppColors.done, fontWeight: FontWeight.w800),
                    ),
                  ),
                  title: Text(user?.displayName ?? '—',
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text(
                      '${user?.email ?? ''}\n${_loginLabel(user?.loginMethod)}'),
                  isThreeLine: true,
                  trailing: const Icon(Icons.edit_outlined, size: 20),
                  onTap: () => showSheet(context, _ProfileSheet()),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: const Icon(Icons.logout, color: AppColors.textSecondary),
                  title: const Text('Keluar'),
                  onTap: () => ConfirmDialog(
                    title: 'Keluar dari akun',
                    message: 'Data tetap tersimpan di perangkat ini. '
                        'Login kembali untuk memulihkan data.',
                    confirmLabel: 'Keluar',
                    onConfirm: () => context.read<AppState>().logout(),
                  ).show(context),
                ),
              ],
            ),
          ),

          // -----------------------------------------------------------------
          // Tampilan
          // -----------------------------------------------------------------
          SectionHeader(title: 'Tampilan'),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.palette_outlined),
                  title: const Text('Tema'),
                  trailing: DropdownButton<ThemeMode>(
                    value: state.settings.theme,
                    underline: const SizedBox.shrink(),
                    items: const [
                      DropdownMenuItem(value: ThemeMode.system, child: Text('Ikuti sistem')),
                      DropdownMenuItem(value: ThemeMode.light, child: Text('Terang')),
                      DropdownMenuItem(value: ThemeMode.dark, child: Text('Gelap')),
                    ],
                    onChanged: (t) {
                      if (t == null) return;
                      final s = state.settings.copy();
                      s.theme = t;
                      state.updateSettings(s);
                    },
                  ),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: const Icon(Icons.text_fields),
                  title: const Text('Ukuran teks Arab'),
                  subtitle: Text('${state.settings.arabicFontSize.round()} pt'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () {
                          final s = state.settings.copy();
                          s.arabicFontSize =
                              (s.arabicFontSize - 2).clamp(16, 40);
                          state.updateSettings(s);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () {
                          final s = state.settings.copy();
                          s.arabicFontSize =
                              (s.arabicFontSize + 2).clamp(16, 40);
                          state.updateSettings(s);
                        },
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                SwitchListTile(
                  value: state.settings.showLatin,
                  onChanged: (v) {
                    final s = state.settings.copy();
                    s.showLatin = v;
                    state.updateSettings(s);
                  },
                  title: const Text('Tampilkan transliterasi Latin'),
                  activeTrackColor: AppColors.primary,
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                SwitchListTile(
                  value: state.settings.showTranslation,
                  onChanged: (v) {
                    final s = state.settings.copy();
                    s.showTranslation = v;
                    state.updateSettings(s);
                  },
                  title: const Text('Tampilkan arti Bahasa Indonesia'),
                  activeTrackColor: AppColors.primary,
                ),
              ],
            ),
          ),

          // -----------------------------------------------------------------
          // Jadwal
          // -----------------------------------------------------------------
          SectionHeader(title: 'Jadwal'),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.location_on_outlined),
                  title: const Text('Lokasi'),
                  subtitle: Text(
                      '${state.settings.cityName}\n'
                      '${state.settings.latitude.toStringAsFixed(4)}, '
                      '${state.settings.longitude.toStringAsFixed(4)}'),
                  isThreeLine: true,
                  trailing: const Icon(Icons.chevron_right, size: 20),
                  onTap: () => _pickCity(context, state),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: const Icon(Icons.calculate_outlined),
                  title: const Text('Metode perhitungan'),
                  subtitle: Text(state.settings.calcMethod.label),
                  trailing: const Icon(Icons.chevron_right, size: 20),
                  onTap: () => _pickMethod(context, state),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: const Icon(Icons.account_balance_outlined),
                  title: const Text('Mazhab perhitungan Ashar'),
                  subtitle: Text(state.settings.asrMethod.label),
                  trailing: const Icon(Icons.chevron_right, size: 20),
                  onTap: () => _pickAsr(context, state),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: const Icon(Icons.tune),
                  title: const Text('Koreksi waktu shalat'),
                  subtitle: Text(_adjSummary(state.settings.timeAdjustments)),
                  trailing: const Icon(Icons.chevron_right, size: 20),
                  onTap: () => _pickAdjustments(context, state),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: const Icon(Icons.schedule_outlined),
                  title: const Text('Format waktu'),
                  trailing: DropdownButton<String>(
                    value: state.settings.use24h ? '24' : '12',
                    underline: const SizedBox.shrink(),
                    items: const [
                      DropdownMenuItem(value: '24', child: Text('24 jam')),
                      DropdownMenuItem(value: '12', child: Text('12 jam')),
                    ],
                    onChanged: (v) {
                      final s = state.settings.copy();
                      s.use24h = v == '24';
                      state.updateSettings(s);
                    },
                  ),
                ),
              ],
            ),
          ),

          // -----------------------------------------------------------------
          // Pengingat
          // -----------------------------------------------------------------
          SectionHeader(title: 'Pengingat'),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Notifikasi dijadwalkan presisi (alarm) berdasarkan jadwal '
                        'shalat & koreksi waktu. Bertahan setelah restart perangkat; '
                        'diperbarui otomatis saat pengaturan berubah.',
                        style: TextStyle(
                            fontSize: 11.5,
                            height: 1.5,
                            color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.alarm, size: 16, color: AppColors.textSecondary),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              state.settings.notificationsPermissionGranted
                                  ? 'Izin notifikasi aktif'
                                  : 'Izin notifikasi belum diberikan',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                          TextButton(
                            onPressed: state.settings.notificationsPermissionGranted
                                ? null
                                : () async {
                                    final granted = await ReminderService
                                        .instance
                                        .requestPermission();
                                    if (!context.mounted) return;
                                    if (granted) {
                                      final s = state.settings.copy();
                                      s.notificationsPermissionGranted = true;
                                      state.updateSettings(s);
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                'Izin ditolak. Aktifkan lewat Pengaturan sistem Android.')),
                                      );
                                    }
                                  },
                            child: const Text('Minta izin'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.notifications_outlined),
                  title: const Text('Pengingat per aktivitas'),
                  subtitle: const Text('Suara azan, notifikasi, getar, atau tanpa'),
                  trailing: const Icon(Icons.chevron_right, size: 20),
                  onTap: () => showSheet(context, _ReminderListSheet(), isScrollControlled: true),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Text(
                    'Aktivitas tersedia: Tahajud, Witir, Subuh, Dhuha, Dzuhur, '
                    'Ashar, Dzikir petang, Maghrib, Isya, dan sebelum tidur. '
                    'Jenis azan memutar audio azan saat notifikasi dibuka.',
                    style: TextStyle(fontSize: 11.5, height: 1.5, color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),

          // -----------------------------------------------------------------
          // Ibadah
          // -----------------------------------------------------------------
          SectionHeader(title: 'Ibadah'),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _ToggleTile(
                  value: state.settings.enableQabliyahAshar,
                  title: 'Qabliyah Ashar (4 rakaat)',
                  subtitle: 'Aktivitas sunnah tambahan sebelum Ashar',
                  icon: Icons.arrow_back,
                  onChanged: (v) {
                    final s = state.settings.copy();
                    s.enableQabliyahAshar = v;
                    state.updateSettings(s);
                  },
                ),
                _ToggleTile(
                  value: state.settings.enableQabliyahMaghrib,
                  title: 'Qabliyah Maghrib (2 rakaat)',
                  subtitle: 'Aktivitas sunnah tambahan sebelum Maghrib',
                  icon: Icons.arrow_back,
                  onChanged: (v) {
                    final s = state.settings.copy();
                    s.enableQabliyahMaghrib = v;
                    state.updateSettings(s);
                  },
                ),
                _ToggleTile(
                  value: state.settings.enableQabliyahIsya,
                  title: 'Qabliyah Isya (2 rakaat)',
                  subtitle: 'Aktivitas sunnah tambahan sebelum Isya',
                  icon: Icons.arrow_back,
                  onChanged: (v) {
                    final s = state.settings.copy();
                    s.enableQabliyahIsya = v;
                    state.updateSettings(s);
                  },
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                _ToggleTile(
                  value: state.settings.enableFridayFeature,
                  title: 'Fitur Jumat',
                  subtitle: 'Mandi Jumat, Al-Kahfi, sedekah, dan lainnya',
                  icon: Icons.event,
                  onChanged: (v) {
                    final s = state.settings.copy();
                    s.enableFridayFeature = v;
                    state.updateSettings(s);
                  },
                ),
              ],
            ),
          ),

          // -----------------------------------------------------------------
          // Kondisi khusus
          // -----------------------------------------------------------------
          SectionHeader(title: 'Kondisi Khusus'),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (final c in state.conditions)
                  ListTile(
                    leading: Icon(
                      switch (c.type) {
                        SpecialConditionType.haid => Icons.medical_services_outlined,
                        SpecialConditionType.musafir => Icons.luggage_outlined,
                        SpecialConditionType.sakit => Icons.sick_outlined,
                      },
                      color: AppColors.uzur,
                    ),
                    title: Text(c.type.label,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(
                        '${formatDateShort(c.startDate)} – ${formatDateShort(c.endDate)}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20),
                      onPressed: () => context.read<AppState>().removeCondition(c.id),
                    ),
                  ),
                if (state.conditions.isNotEmpty) const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.add, color: AppColors.primary),
                  title: const Text('Tambah kondisi khusus'),
                  subtitle: const Text('Haid/Nifas, Musafir, atau Sakit'),
                  onTap: () => showSheet(context, _ConditionSheet()),
                ),
              ],
            ),
          ),

          SectionHeader(title: 'Akses Keluarga'),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.family_restroom, color: AppColors.primary),
                  title: Text('Akses Keluarga', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text('Kelola akses wali/pengawasan ibadah',
                      style: TextStyle(color: AppColors.textSecondary)),
                  trailing: Icon(Icons.chevron_right, size: 20),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => ConsentScreen(uid: state.user!.id))),
                ),
              ],
            ),
          ),

          // -----------------------------------------------------------------
          // Data
          // -----------------------------------------------------------------
          SectionHeader(title: 'Data & Sinkronisasi'),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  leading: Icon(
                    state.syncing ? Icons.sync : Icons.cloud_done_outlined,
                    color: state.syncing ? AppColors.accent : AppColors.done,
                  ),
                  title: Text(state.syncing ? 'Sedang sinkronisasi…' : 'Sinkronisasi'),
                  subtitle: Text(state.syncStatusLabel),
                  trailing: FilledButton.tonal(
                    onPressed: state.syncing ? null : () => context.read<AppState>().syncNow(),
                    child: const Text('Sinkron'),
                  ),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: const Icon(Icons.delete_sweep_outlined),
                  title: const Text('Hapus seluruh riwayat'),
                  subtitle: const Text('Menghapus semua catatan ibadah'),
                  onTap: () => ConfirmDialog(
                    title: 'Hapus seluruh riwayat?',
                    message: 'Seluruh catatan ibadah akan dihapus permanen dari perangkat ini.',
                    confirmLabel: 'Hapus',
                    confirmColor: const Color(0xFFB3564A),
                    onConfirm: () => context.read<AppState>().clearRiwayat(),
                  ).show(context),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: const Icon(Icons.storage_outlined),
                  title: const Text('Hapus data lokal'),
                  subtitle: const Text('Riwayat dan kondisi khusus'),
                  onTap: () => ConfirmDialog(
                    title: 'Hapus data lokal?',
                    message: 'Riwayat dan kondisi khusus di perangkat ini akan dihapus.',
                    confirmLabel: 'Hapus',
                    confirmColor: const Color(0xFFB3564A),
                    onConfirm: () => context.read<AppState>().clearLocalData(),
                  ).show(context),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: const Icon(Icons.delete_forever_outlined,
                      color: Color(0xFFB3564A)),
                  title: const Text('Hapus akun',
                      style: TextStyle(color: Color(0xFFB3564A))),
                  subtitle: const Text('Menghapus akun dan seluruh data terkait'),
                  onTap: () => ConfirmDialog(
                    title: 'Hapus akun?',
                    message: 'Akun dan seluruh data ibadah akan dihapus. Tindakan ini tidak dapat dibatalkan.',
                    confirmLabel: 'Hapus Akun',
                    confirmColor: const Color(0xFFB3564A),
                    onConfirm: () => context.read<AppState>().deleteAccount(),
                  ).show(context),
                ),
              ],
            ),
          ),

          // -----------------------------------------------------------------
          // Tentang
          // -----------------------------------------------------------------
          SectionHeader(title: 'Tentang'),
          AppCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('IbadahKu v0.1.0 (antarmuka awal)',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text(
                  'Aplikasi pencatatan ibadah pribadi. Tanpa skor, tanpa perbandingan, '
                  'tanpa penilaian moral.\n\n'
                  'Konten doa & dzikir menggunakan teks standar dengan referensi hadis. '
                  'Sesuai PRD, seluruh konten agama wajib ditinjau oleh pihak yang '
                  'memahami ilmu agama sebelum rilis publik.\n\n'
                  'Autentikasi, sinkronisasi cloud (Firebase), dan notifikasi nyata '
                  'akan menyusul pada fase backend.',
                  style: TextStyle(fontSize: 12.5, height: 1.6, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 12),
                FilledButton.tonal(
                  onPressed: () => context.read<AppState>().seedDemoData(),
                  child: const Text('Muat data contoh untuk pratinjau'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  String _loginLabel(String? m) => switch (m) {
        'google' => 'Masuk dengan Google',
        'demo' => 'Mode demo (tanpa akun)',
        _ => 'Email & kata sandi',
      };

  String _adjSummary(Map<String, int> adj) {
    if (adj.isEmpty) return 'Tidak ada koreksi';
    final parts = adj.entries
        .where((e) => e.value != 0)
        .map((e) => '${e.key}: ${e.value > 0 ? '+' : ''}${e.value} mnt')
        .toList();
    return parts.isEmpty ? 'Tidak ada koreksi' : parts.join(', ');
  }

  void _pickCity(BuildContext context, AppState state) {
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetCtx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
              child: Text('Lokasi',
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
            ),
            ListTile(
              leading: const Icon(Icons.my_location),
              title: const Text('Gunakan lokasi saat ini (GPS)'),
              subtitle: const Text('Deteksi otomatis via GPS & geocoder'),
              onTap: () async {
                Navigator.pop(sheetCtx);
                _useGpsLocation(context, state);
              },
            ),
            const Divider(height: 1, indent: 16, endIndent: 16),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 10),
              child: Text('Pilih kota',
                  style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final c in kCities)
                    ListTile(
                      dense: true,
                      title: Text(c.name),
                      trailing: state.settings.cityName == c.name
                          ? const Icon(Icons.check, size: 18)
                          : null,
                      onTap: () {
                        final s = state.settings.copy();
                        s.cityName = c.name;
                        s.latitude = c.lat;
                        s.longitude = c.lon;
                        state.updateSettings(s);
                        Navigator.pop(sheetCtx);
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _useGpsLocation(BuildContext context, AppState state) async {
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      const SnackBar(
        content: Text('Mendeteksi lokasi…'),
        duration: Duration(seconds: 20),
      ),
    );
    final gps = await LocationService.instance.detect();
    if (!context.mounted) return;
    messenger.hideCurrentSnackBar();
    if (gps == null) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
              'Tidak dapat mendeteksi lokasi. Periksa GPS/layanan lokasi dan izin.')),
      );
      return;
    }
    final s = state.settings.copy();
    s.latitude = gps.lat;
    s.longitude = gps.lon;
    s.cityName = gps.cityName.isNotEmpty ? gps.cityName : state.settings.cityName;
    await state.updateSettings(s);
    messenger.showSnackBar(
      SnackBar(content: Text('Lokasi diperbarui: ${s.cityName}')),
    );
  }

  void _pickMethod(BuildContext context, AppState state) {
    showDialog<void>(
      context: context,
      builder: (_) => SimpleDialog(
        title: const Text('Metode perhitungan'),
        children: [
          for (final m in CalcMethod.values)
            SimpleDialogOption(
              onPressed: () {
                final s = state.settings.copy();
                s.calcMethod = m;
                state.updateSettings(s);
                Navigator.pop(context);
              },
              child: Text(m.label),
            ),
        ],
      ),
    );
  }

  void _pickAsr(BuildContext context, AppState state) {
    showDialog<void>(
      context: context,
      builder: (_) => SimpleDialog(
        title: const Text('Mazhab perhitungan Ashar'),
        children: [
          for (final a in AsrJuristic.values)
            SimpleDialogOption(
              onPressed: () {
                final s = state.settings.copy();
                s.asrMethod = a;
                state.updateSettings(s);
                Navigator.pop(context);
              },
              child: Text(a.label),
            ),
        ],
      ),
    );
  }

  void _pickAdjustments(BuildContext context, AppState state) {
    showSheet(
      context,
      _AdjustmentsSheet(adjustments: state.settings.timeAdjustments),
    );
  }
}

// ---------------------------------------------------------------------------
// Tile toggle
// ---------------------------------------------------------------------------

class _ToggleTile extends StatelessWidget {
  final bool value;
  final String title;
  final String subtitle;
  final IconData icon;
  final ValueChanged<bool> onChanged;
  const _ToggleTile({
    required this.value,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      secondary: Icon(icon, color: AppColors.primary),
      title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      activeTrackColor: AppColors.primary,
    );
  }
}

// ---------------------------------------------------------------------------
// Profil
// ---------------------------------------------------------------------------

class _ProfileSheet extends StatefulWidget {
  @override
  State<_ProfileSheet> createState() => _ProfileSheetState();
}

class _ProfileSheetState extends State<_ProfileSheet> {
  late final TextEditingController _name;
  late String _gender;

  @override
  void initState() {
    super.initState();
    final u = context.read<AppState>().user;
    _name = TextEditingController(text: u?.displayName ?? '');
    _gender = u?.gender ?? '';
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Profil',
                  style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            TextField(
              controller: _name,
              decoration: const InputDecoration(
                  labelText: 'Nama panggilan',
                  prefixIcon: Icon(Icons.person_outline)),
            ),
            const SizedBox(height: 16),
            const Text('Jenis kelamin', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            ChipSelect<String>(
              options: const ['', 'pria', 'wanita', 'lainnya'],
              selected: _gender,
              labelOf: (g) => g.isEmpty
                  ? 'Tidak ingin mengisi'
                  : switch (g) {
                      'pria' => 'Laki-laki',
                      'wanita' => 'Perempuan',
                      _ => 'Lainnya',
                    },
              onSelected: (g) => setState(() => _gender = g),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.primaryLight
                        : AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14)),
                onPressed: () async {
                  await context.read<AppState>().updateProfile(
                        name: _name.text.trim().isEmpty ? null : _name.text.trim(),
                        gender: _gender.isEmpty ? null : _gender,
                      );
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text('Simpan'),
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Koreksi waktu
// ---------------------------------------------------------------------------

class _AdjustmentsSheet extends StatefulWidget {
  final Map<String, int> adjustments;
  const _AdjustmentsSheet({required this.adjustments});

  @override
  State<_AdjustmentsSheet> createState() => _AdjustmentsSheetState();
}

class _AdjustmentsSheetState extends State<_AdjustmentsSheet> {
  late Map<String, TextEditingController> _ctrls;

  @override
  void initState() {
    super.initState();
    _ctrls = {
      for (final n in kFardhuOrder)
        n: TextEditingController(
            text: (widget.adjustments[n] ?? 0).toString()),
    };
  }

  @override
  void dispose() {
    for (final c in _ctrls.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Koreksi Waktu Shalat',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(
              'Koreksi dalam menit, positif = maju, negatif = mundur.',
              style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            for (final n in kFardhuOrder)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: TextField(
                  controller: _ctrls[n],
                  keyboardType: TextInputType.numberWithOptions(signed: true),
                  decoration: InputDecoration(
                    labelText: PrayerName.fromKey(n).label,
                    prefixIcon: const Icon(Icons.access_time, size: 20),
                    suffixText: 'menit',
                  ),
                ),
              ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14)),
                onPressed: () {
                  final adj = <String, int>{};
                  for (final n in kFardhuOrder) {
                    final v = int.tryParse(_ctrls[n]!.text.trim());
                    if (v != null && v != 0) adj[n] = v;
                  }
                  final s = context.read<AppState>().settings.copy();
                  s.timeAdjustments = adj;
                  context.read<AppState>().updateSettings(s);
                  Navigator.pop(context);
                },
                child: const Text('Simpan koreksi'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Pengingat per aktivitas
// ---------------------------------------------------------------------------

class _ReminderListSheet extends StatelessWidget {
  const _ReminderListSheet();

  static const _activities = [
    ('tahajud', 'Tahajud'),
    ('witir', 'Witir'),
    ('subuh', 'Subuh'),
    ('dhuha', 'Dhuha'),
    ('dzuhur', 'Dzuhur'),
    ('ashar', 'Ashar'),
    ('dzikir_petang', 'Dzikir petang'),
    ('maghrib', 'Maghrib'),
    ('isya', 'Isya'),
    ('sebelum_tidur', 'Doa & dzikir sebelum tidur'),
  ];

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      builder: (context, ctrl) => SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Pengingat per Aktivitas',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                  Text(
                    'Setiap aktivitas dapat memiliki jenis & waktu pengingat berbeda.',
                    style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                controller: ctrl,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                itemCount: _activities.length,
                itemBuilder: (context, i) {
                  final (id, label) = _activities[i];
                  final r = state.reminderFor(id);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: AppCard(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(label,
                                    style: const TextStyle(
                                        fontSize: 13.5, fontWeight: FontWeight.w700)),
                                Text(
                                  r.enabled
                                      ? '${r.kind.label} · ${r.offsetMin == 0 ? 'tepat waktu' : '${r.offsetMin} mnt sebelumnya'}'
                                      : 'Tanpa pengingat',
                                  style: TextStyle(
                                      fontSize: 11.5, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: r.enabled,
                            activeTrackColor: AppColors.primary,
                            onChanged: (v) {
                              final s = state.settings.copy();
                              s.reminders[id] = ReminderSetting(
                                  enabled: v, kind: r.kind, offsetMin: r.offsetMin);
                              state.updateSettings(s);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.tune, size: 20),
                            onPressed: () => showSheet(
                                context, _ReminderEditSheet(activityId: id)),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReminderEditSheet extends StatefulWidget {
  final String activityId;
  const _ReminderEditSheet({required this.activityId});

  @override
  State<_ReminderEditSheet> createState() => _ReminderEditSheetState();
}

class _ReminderEditSheetState extends State<_ReminderEditSheet> {
  late ReminderSetting _r;

  @override
  void initState() {
    super.initState();
    _r = context.read<AppState>().reminderFor(widget.activityId);
  }

  @override
  Widget build(BuildContext context) {
    final state = context.read<AppState>();
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pengaturan pengingat — ${widget.activityId}',
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            const Text('Jenis pengingat', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            ChipSelect<ReminderKind>(
              options: ReminderKind.values,
              selected: _r.kind,
              labelOf: (k) => k.label,
              onSelected: (k) => setState(() => _r.kind = k),
            ),
            const SizedBox(height: 20),
            const Text('Waktu pengingat', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            ChipSelect<int>(
              options: const [0, 5, 10, 15, 30],
              selected: _r.offsetMin,
              labelOf: (m) => m == 0 ? 'Tepat waktu' : '$m mnt sebelumnya',
              onSelected: (m) => setState(() => _r.offsetMin = m),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.primaryLight
                        : AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14)),
                onPressed: () {
                  state.setReminder(
                      widget.activityId,
                      ReminderSetting(
                          enabled: _r.enabled, kind: _r.kind, offsetMin: _r.offsetMin));
                  Navigator.pop(context);
                },
                child: const Text('Simpan'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Kondisi khusus
// ---------------------------------------------------------------------------

class _ConditionSheet extends StatefulWidget {
  @override
  State<_ConditionSheet> createState() => _ConditionSheetState();
}

class _ConditionSheetState extends State<_ConditionSheet> {
  SpecialConditionType _type = SpecialConditionType.haid;
  DateTime _start = DateTime.now();
  DateTime _end = DateTime.now().add(const Duration(days: 6));
  final _notesCtrl = TextEditingController();

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tambah Kondisi Khusus',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            ChipSelect<SpecialConditionType>(
              options: SpecialConditionType.values,
              selected: _type,
              labelOf: (t) => t.label,
              onSelected: (t) => setState(() => _type = t),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _DateField(
                    label: 'Mulai',
                    value: _start,
                    onTap: () async {
                      final p = await showDatePicker(
                        context: context,
                        initialDate: _start,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (p != null) setState(() => _start = p);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DateField(
                    label: 'Selesai',
                    value: _end,
                    onTap: () async {
                      final p = await showDatePicker(
                        context: context,
                        initialDate: _end,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (p != null) setState(() => _end = p);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notesCtrl,
              maxLines: 2,
              decoration: const InputDecoration(
                  labelText: 'Catatan (opsional)',
                  prefixIcon: Icon(Icons.notes, size: 20)),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14)),
                onPressed: () {
                  context.read<AppState>().addCondition(SpecialCondition(
                        id: 'cond_${DateTime.now().millisecondsSinceEpoch}',
                        type: _type,
                        startDate: AppState.dateOnly(_start),
                        endDate: AppState.dateOnly(_end),
                        notes: _notesCtrl.text.trim(),
                      ));
                  Navigator.pop(context);
                },
                child: const Text('Simpan kondisi'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final DateTime value;
  final VoidCallback onTap;
  const _DateField({required this.label, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
            labelText: label, prefixIcon: const Icon(Icons.calendar_today_outlined, size: 20)),
        child: Text(formatDateShort(value),
            style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
