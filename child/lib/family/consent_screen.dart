import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_service.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import 'family_access_screen.dart';

/// Layar persetujuan akses keluarga untuk seorang anak.
/// Menampilkan detail apa yang dapat diakses wali dan memungkinkan
/// pengguna untuk menyetujui atau menolak suatu undangan.
class ConsentScreen extends StatefulWidget {
  final String uid;
  const ConsentScreen({super.key, required this.uid});

  @override
  State<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends State<ConsentScreen> {
  bool _agree = false;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final uid = widget.uid;
    final fb = FirebaseService.instance;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Akses Keluarga'),
        actions: [
          TextButton.icon(
            onPressed: uid.isNotEmpty ? _navigateToFamilyAccess : null,
            icon: const Icon(Icons.visibility_outlined, size: 18),
            label: const Text('Lihat Akses'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        children: [
          Container(
            width: 64,
            height: 64,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16)),
            child: const Icon(Icons.group_add, color: AppColors.accent, size: 32),
          ),
          const SizedBox(height: 16),
          const Text('Wali menginginkan akses penuh',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          const Text(
            'Izin ini memungkinkan wali melihat riwayat ibadah, '
            'catatan pribadi, lokasi terakhir, dan mengatur pengingat.',
            style: TextStyle(fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 16),
          _buildAccessItem(Icons.bar_chart, 'Riwayat ibadah harian'),
          _buildAccessItem(Icons.location_on, 'Lokasi terakhir (opsional)'),
          _buildAccessItem(Icons.notifications, 'Pengingat dari wali'),
          const SizedBox(height: 12),
          SwitchListTile(
            value: _agree,
            onChanged: (v) => setState(() => _agree = v),
            title: Text('Saya setuju dengan akses di atas',
                style: TextStyle(
                    fontSize: 13,
                    color: _agree ? AppColors.primary : AppColors.textSecondary)),
            activeTrackColor: AppColors.primary,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14)),
              onPressed: (!_agree || _loading || !fb.available) ? null : _accept,
              child: _loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Berikan Akses',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700)),
            ),
          ),
          if (!fb.available)
            const Padding(
              padding: EdgeInsets.only(top: 16),
              child: Text(
                'Firebase tidak tersambung. Hubungkan akun terlebih dahulu.',
                style: TextStyle(color: Color(0xFFB3564A), fontSize: 12.5)),
            ),
        ],
      ),
    );
  }

  Widget _buildAccessItem(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Text(label,
              style: TextStyle(fontSize: 13.5, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Future<void> _accept() async {
    setState(() => _loading = true);
    final state = context.read<AppState>();
    try {
      await FirebaseService.instance.saveUserData(state.user!.id, {
        'consentGivenAt': DateTime.now().toIso8601String(),
        'consentVersion': '1.0',
      });
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Akses diberikan')));
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gagal memberi akses')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _navigateToFamilyAccess() {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => FamilyAccessScreen(uid: widget.uid)));
  }
}
