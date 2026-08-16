import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/firebase_service.dart';

import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';

/// Login — Firebase bila tersedia, fallback simulasi lokal bila belum.
/// Mode demo memungkinkan menjelajah seluruh aplikasi tanpa akun.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  bool _registerMode = false;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _login(BuildContext context,
      {String? email, String? password, String method = 'email'}) async {
    final state = context.read<AppState>();
    final fb = FirebaseService.instance;
    setState(() {
      _busy = true;
      _error = null;
    });
    await Future.delayed(const Duration(milliseconds: 300));

    try {
      if (method == 'email') {
        final e = (_registerMode ? email ?? _emailCtrl.text : _emailCtrl.text).trim();
        final p = _registerMode ? password ?? _passCtrl.text : _passCtrl.text;
        if (!e.contains('@') || e.length < 5) {
          _fail('Masukkan alamat email yang valid.');
          return;
        }
        if (p.length < 6) {
          _fail('Kata sandi minimal 6 karakter.');
          return;
        }
        final displayName = _registerMode
            ? (_nameCtrl.text.trim().isEmpty ? e.split('@').first : _nameCtrl.text.trim())
            : e.split('@').first;
        if (fb.available) {
          final u = await fb.signInWithEmail(e, p,
              register: _registerMode, displayName: displayName);
          if (u != null) await state.login(u);
        } else {
          await state.login(UserProfile(
                id: 'user_${e.hashCode}',
                displayName: displayName,
                email: e,
                gender: '',
                loginMethod: 'email',
                createdAt: DateTime.now(),
              ));
        }
      } else if (method == 'google') {
        if (fb.available) {
          final u = await fb.signInWithGoogle();
          if (u == null) return; // dibatalkan
          await state.login(u);
        } else {
          // Fallback: Firebase belum aktif (json belum terpasang).
          await state.login(UserProfile(
                id: 'user_google_${DateTime.now().millisecondsSinceEpoch}',
                displayName: 'Pengguna IbadahKu',
                email: 'pengguna@ibadahku.id',
                gender: '',
                loginMethod: 'google',
                createdAt: DateTime.now(),
              ));
        }
      } else {
        // demo tanpa akun
        await state.login(UserProfile(
              id: 'demo_user',
              displayName: 'Mode Demo',
              email: 'demo@ibadahku.id',
              gender: '',
              loginMethod: 'demo',
              createdAt: DateTime.now(),
            ));
      }
    } on FirebaseAuthException catch (e) {
      _fail(_fbError(e));
    } catch (e) {
      _fail('Gagal masuk. Periksa koneksi internet dan coba lagi.');
    }
    if (mounted) setState(() => _busy = false);
  }

  void _fail(String msg) {
    if (mounted) {
      setState(() {
        _busy = false;
        _error = msg;
      });
    }
  }

  String _fbError(FirebaseAuthException e) => switch (e.code) {
        'invalid-credential' => 'Email atau kata sandi salah.',
        'wrong-password' => 'Kata sandi salah.',
        'user-not-found' => 'Akun dengan email ini tidak ditemukan.',
        'email-already-in-use' => 'Email sudah terdaftar. Masuk saja.',
        'weak-password' => 'Kata sandi terlalu lemah (minimal 6 karakter).',
        'invalid-email' => 'Alamat email tidak valid.',
        'network-request-failed' => 'Tidak ada koneksi internet.',
        _ => 'Gagal masuk: ${e.message ?? e.code}',
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.nights_stay_rounded, color: Colors.white, size: 36),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'IbadahKu',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context).colorScheme.onSurface),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Catat ibadah harianmu dengan tenang.\nTanpa penilaian, tanpa perbandingan.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13.5, height: 1.5, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 28),

                  if (_registerMode) ...[
                    TextField(
                      controller: _nameCtrl,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Nama panggilan',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  TextField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.mail_outline),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _passCtrl,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Kata sandi',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: _registerMode
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.info_outline, size: 18),
                              onPressed: () => _showForgot(context),
                            ),
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 10),
                    Text(_error!,
                        style: const TextStyle(color: Color(0xFFB3564A), fontSize: 13)),
                  ],
                  const SizedBox(height: 16),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _busy ? null : () => _login(context),
                    child: _busy
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text(_registerMode ? 'Buat Akun' : 'Masuk',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => setState(() {
                      _registerMode = !_registerMode;
                      _error = null;
                    }),
                    child: Text(
                      _registerMode ? 'Sudah punya akun? Masuk' : 'Belum punya akun? Daftar',
                      style: const TextStyle(color: AppColors.primaryLight),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text('atau',
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ),
                    const Expanded(child: Divider()),
                  ]),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      side: const BorderSide(color: AppColors.divider),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _busy ? null : () => _login(context, method: 'google'),
                    icon: const Text('G', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF4285F4))),
                    label: const Text('Masuk dengan Google'),
                  ),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: _busy ? null : () => _login(context, method: 'demo'),
                    icon: const Icon(Icons.explore_outlined, size: 18),
                    label: const Text('Coba tanpa akun (Mode Demo)'),
                    style: TextButton.styleFrom(foregroundColor: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Versi antarmuka awal: autentikasi & cloud masih simulasi lokal. '
                    'Login Google dan sinkronisasi Firebase menyusul pada fase backend.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11.5, height: 1.5, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showForgot(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Lupa Kata Sandi'),
        content: const Text(
            'Fitur reset kata sandi tersedia pada fase backend (email verifikasi Firebase). '
            'Pada versi antarmuka awal, ketuk "Coba tanpa akun" untuk menjelajahi aplikasi.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Tutup')),
        ],
      ),
    );
  }
}
