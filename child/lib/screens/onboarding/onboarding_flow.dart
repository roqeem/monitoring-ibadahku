import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/worship_content.dart';
import '../../models/models.dart';
import '../../services/location_service.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';

/// Onboarding — mengumpulkan pengaturan awal sebelum halaman utama.
/// Setiap langkah dapat dilewati; semua dapat diubah di Pengaturan.
class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  final _pageCtrl = PageController();
  int _page = 0;

  final _nameCtrl = TextEditingController();
  String _gender = '';
  bool _autoLocation = true;
  String _city = 'Jakarta';
  bool _locating = false;
  String? _locError;
  LocationResult? _gps;
  CalcMethod _method = CalcMethod.kemenag;
  AsrJuristic _asr = AsrJuristic.shafii;
  ReminderKind _reminder = ReminderKind.notif;
  bool _notifGranted = false;

  static const _steps = 5;

  @override
  void dispose() {
    _pageCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    final state = context.read<AppState>();
    final city = kCities.firstWhere((c) => c.name == _city,
        orElse: () => const CityInfo('Jakarta', -6.2088, 106.8456));
    final s = state.settings.copy();
    s.cityName = _city;
    if (_autoLocation) {
      // GPS: pakai hasil deteksi; jika gagal, default Jakarta.
      s.latitude = _gps?.lat ?? -6.2088;
      s.longitude = _gps?.lon ?? 106.8456;
      s.cityName = (_gps?.cityName.isNotEmpty ?? false) ? _gps!.cityName : 'Jakarta';
    } else {
      s.latitude = city.lat;
      s.longitude = city.lon;
    }
    s.calcMethod = _method;
    s.asrMethod = _asr;
    s.notificationsPermissionGranted = _notifGranted;
    await state.updateSettings(s);
    if (_nameCtrl.text.trim().isNotEmpty || _gender.isNotEmpty) {
      await state.updateProfile(
        name: _nameCtrl.text.trim().isEmpty ? null : _nameCtrl.text.trim(),
        gender: _gender.isEmpty ? null : _gender,
      );
    }
    await state.completeOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: _page > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => _pageCtrl.previousPage(
                    duration: const Duration(milliseconds: 250), curve: Curves.easeOut),
              )
            : null,
        actions: [
          TextButton(
            onPressed: _finish,
            child: const Text('Lewati'),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageCtrl,
              onPageChanged: (i) => setState(() => _page = i),
              children: [
                _stepSalam(),
                _stepLokasi(),
                _stepMetode(),
                _stepPengingat(),
                _stepSelesai(),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var i = 0; i < _steps; i++)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: i == _page ? 22 : 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          decoration: BoxDecoration(
                            color: i == _page ? AppColors.primary : AppColors.divider,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _page == _steps - 1
                          ? _finish
                          : () => _pageCtrl.nextPage(
                              duration: const Duration(milliseconds: 250), curve: Curves.easeOut),
                      child: Text(_page == _steps - 1 ? 'Mulai' : 'Lanjut',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pageBody(String title, String subtitle, List<Widget> children) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text(title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(subtitle,
              style: TextStyle(fontSize: 13.5, height: 1.5, color: AppColors.textSecondary)),
          const SizedBox(height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _stepSalam() {
    return _pageBody(
      'Salam kenal 👋',
      'Lengkapi beberapa pengaturan awal. Semua dapat diubah nanti di menu Pengaturan.',
      [
        TextField(
          controller: _nameCtrl,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'Nama panggilan',
            hintText: 'cth: Ahmad',
            prefixIcon: Icon(Icons.person_outline),
          ),
        ),
        const SizedBox(height: 16),
        const Text('Jenis kelamin', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        ChipSelect<String>(
          options: const ['pria', 'wanita', 'lainnya'],
          selected: _gender.isEmpty ? null : _gender,
          labelOf: (g) => switch (g) {
            'pria' => 'Laki-laki',
            'wanita' => 'Perempuan',
            _ => 'Lainnya',
          },
          iconOf: (g) => switch (g) {
            'pria' => Icons.male,
            'wanita' => Icons.female,
            _ => Icons.person,
          },
          onSelected: (g) => setState(() => _gender = g),
        ),
      ],
    );
  }

  Future<void> _detectLocation() async {
    setState(() {
      _locating = true;
      _locError = null;
    });
    final gps = await LocationService.instance.detect();
    if (!mounted) return;
    setState(() {
      _locating = false;
      if (gps != null) {
        _gps = gps;
      } else {
        _locError =
            'Tidak dapat mendeteksi lokasi. Periksa GPS/layanan lokasi, lalu coba lagi.';
      }
    });
  }

  Widget _stepLokasi() {
    return _pageBody(
      'Lokasi & Jadwal Shalat',
      'Jadwal shalat dihitung dari lokasi. Pilih otomatis (GPS) atau pilih kota secara manual.',
      [
        ChipSelect<bool>(
          options: const [true, false],
          selected: _autoLocation,
          labelOf: (b) => b ? 'Lokasi otomatis (GPS)' : 'Pilih kota manual',
          iconOf: (b) => b ? Icons.my_location : Icons.location_city,
          onSelected: (b) {
            setState(() => _autoLocation = b);
            if (b) _detectLocation();
          },
        ),
        if (_autoLocation) ...[
          const SizedBox(height: 16),
          if (_locating)
            const Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 12),
                Expanded(child: Text('Mendeteksi lokasi…', style: TextStyle(fontSize: 13))),
              ],
            )
          else if (_gps != null)
            Row(
              children: [
                const Icon(Icons.my_location, size: 18, color: AppColors.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Lokasi terdeteksi: ${_gps!.cityName.isNotEmpty ? _gps!.cityName : '${_gps!.lat.toStringAsFixed(4)}, ${_gps!.lon.toStringAsFixed(4)}'}',
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ],
            )
          else if (_locError != null)
            Row(
              children: [
                const Icon(Icons.warning_amber_rounded,
                    size: 18, color: AppColors.missed),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(_locError!,
                      style: const TextStyle(fontSize: 12.5, color: AppColors.missed)),
                ),
              ],
            ),
          if (_gps == null && !_locating)
            OutlinedButton.icon(
              onPressed: _detectLocation,
              icon: const Icon(Icons.gps_fixed, size: 18),
              label: Text(_locError != null ? 'Coba lagi' : 'Deteksi lokasi (GPS)'),
            ),
        ] else ...[
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _city,
            decoration: const InputDecoration(labelText: 'Kota'),
            items: [
              for (final c in kCities)
                DropdownMenuItem(value: c.name, child: Text(c.name)),
            ],
            onChanged: (v) => setState(() => _city = v ?? _city),
          ),
        ],
        const SizedBox(height: 16),
        Text(
          'Metode perhitungan dan koreksi menit dapat disesuaikan di Pengaturan → Jadwal.',
          style: TextStyle(fontSize: 12, height: 1.5, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _stepMetode() {
    return _pageBody(
      'Metode Perhitungan',
      'Metode menentukan sudut fajar dan Isya. Default Kemenag RI untuk wilayah Indonesia.',
      [
        const Text('Metode perhitungan', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        DropdownButtonFormField<CalcMethod>(
          value: _method,
          decoration: const InputDecoration(labelText: 'Metode'),
          items: [
            for (final m in CalcMethod.values)
              DropdownMenuItem(value: m, child: Text(m.label)),
          ],
          onChanged: (v) => setState(() => _method = v ?? _method),
        ),
        const SizedBox(height: 20),
        const Text('Mazhab perhitungan Ashar', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        ChipSelect<AsrJuristic>(
          options: AsrJuristic.values,
          selected: _asr,
          labelOf: (a) => a.label,
          onSelected: (a) => setState(() => _asr = a),
        ),
      ],
    );
  }

  Widget _stepPengingat() {
    return _pageBody(
      'Pengingat Ibadah',
      'Pilih jenis pengingat default. Pengaturan per aktivitas tersedia di menu Pengaturan.',
      [
        ChipSelect<ReminderKind>(
          options: ReminderKind.values,
          selected: _reminder,
          labelOf: (r) => r.label,
          iconOf: (r) => switch (r) {
            ReminderKind.azan => Icons.notifications_active_outlined,
            ReminderKind.notif => Icons.notifications_outlined,
            ReminderKind.getar => Icons.vibration,
            ReminderKind.tanpa => Icons.notifications_off_outlined,
          },
          onSelected: (r) => setState(() => _reminder = r),
        ),
        const SizedBox(height: 20),
        SwitchListTile(
          value: _notifGranted,
          onChanged: (v) => setState(() => _notifGranted = v),
          title: const Text('Izinkan notifikasi', style: TextStyle(fontSize: 14.5)),
          subtitle: const Text('Pengingat shalat dan ibadah harian',
              style: TextStyle(fontSize: 12.5)),
          contentPadding: EdgeInsets.zero,
          activeTrackColor: AppColors.primary,
        ),
        const SizedBox(height: 8),
        Text(
          'Izin notifikasi & alarm presisi akan diminta secara nyata pada fase backend. '
          'Aplikasi tetap menampilkan peringatan bila izin belum diberikan.',
          style: TextStyle(fontSize: 12, height: 1.5, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _stepSelesai() {
    final name = _nameCtrl.text.trim().isEmpty ? 'Sahabat' : _nameCtrl.text.trim();
    return _pageBody(
      'Siap Memulai, $name 👋',
      'Ringkasan pengaturan awalmu:',
      [
        AppCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _row('Lokasi', _autoLocation ? 'Otomatis (GPS)' : _city),
              _row('Metode', _method.label),
              _row('Mazhab Ashar', _asr.label),
              _row('Pengingat', _reminder.label),
              _row('Notifikasi', _notifGranted ? 'Diizinkan' : 'Belum diizinkan'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Semua pengaturan ini dapat diubah kapan saja di menu Pengaturan.',
          style: TextStyle(fontSize: 12.5, height: 1.5, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _row(String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(k, style: TextStyle(fontSize: 13.5, color: AppColors.textSecondary)),
          const Spacer(),
          Text(v,
              style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
              textAlign: TextAlign.right),
        ],
      ),
    );
  }
}
