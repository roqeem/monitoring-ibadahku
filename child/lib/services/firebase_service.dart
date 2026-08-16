/// Layanan Firebase — auth & cloud.
/// Guard: jika `google-services.json` belum ada (build tanpa plugin),
/// Firebase.initializeApp gagal -> `available == false`, login simulasi lokal.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/models.dart';

class FirebaseService {
  FirebaseService._();
  static final instance = FirebaseService._();

  bool _available = false;
  bool get available => _available;

  /// Init aman: gagal (mis. json belum ada) -> `available=false`, tanpa throw.
  Future<void> init() async {
    try {
      await Firebase.initializeApp();
      _available = true;
    } catch (_) {
      _available = false;
    }
  }

  /// Login Google. Mengembalikan profil atau null (batal/gagal).
  Future<UserProfile?> signInWithGoogle() async {
    final acct = await GoogleSignIn().signIn();
    if (acct == null) return null; // dibatalkan
    final auth = await acct.authentication;
    final cred = GoogleAuthProvider.credential(
      accessToken: auth.accessToken,
      idToken: auth.idToken,
    );
    final user = await FirebaseAuth.instance.signInWithCredential(cred);
    return _profile(user.user, 'google');
  }

  /// Login / daftar email-password. `register=true` untuk daftar baru.
  Future<UserProfile?> signInWithEmail(
    String email,
    String password, {
    bool register = false,
    String displayName = '',
  }) async {
    late final UserCredential uc;
    if (register) {
      uc = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (displayName.trim().isNotEmpty) {
        await uc.user?.updateDisplayName(displayName.trim());
      }
    } else {
      uc = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    }
    return _profile(uc.user, 'email');
  }

  Future<void> signOut() async {
    if (!_available) return;
    await GoogleSignIn().signOut();
    await FirebaseAuth.instance.signOut();
  }

  UserProfile? _profile(User? u, String method) {
    if (u == null) return null;
    return UserProfile(
      id: u.uid,
      displayName: (u.displayName?.trim().isNotEmpty ?? false)
          ? u.displayName!.trim()
          : (u.email?.split('@').first ?? 'Pengguna IbadahKu'),
      email: u.email ?? '',
      gender: '',
      loginMethod: method,
      createdAt: u.metadata.creationTime ?? DateTime.now(),
    );
  }

  // ---- FCM topic subscription ----

  /// Subscribe child ke topik `user-events-{uid}` agar bisa menerima
  /// data-only reminder dari guardian.
  Future<void> subscribeToFamilyTopic(String uid) async {
    if (!_available) return;
    try {
      await FirebaseMessaging.instance.subscribeToTopic('user-events-$uid');
      FirebaseMessaging.onBackgroundMessage(_familyMessagingBackgroundHandler);
    } catch (_) {}
  }

  /// Unsubscribe saat logout / akses dicabut.
  Future<void> unsubscribeFromFamilyTopic(String uid) async {
    if (!_available) return;
    try {
      await FirebaseMessaging.instance.unsubscribeFromTopic('user-events-$uid');
    } catch (_) {}
  }

  // ---- Cloud Firestore ----

  /// Simpan data pengguna (map JSON) ke koleksi pengguna.
  Future<void> saveUserData(String uid, Map<String, dynamic> data) async {
    if (!_available) return;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .set(data, SetOptions(merge: true));
  }

  /// Muat data pengguna dari cloud; null bila belum ada.
  Future<Map<String, dynamic>?> loadUserData(String uid) async {
    if (!_available) return null;
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return doc.exists ? doc.data() : null;
  }

  /// Simpan profil anak ke koleksi `children/{childId}` yang
  /// dibaca oleh guardian melalui `getFamilyDigest`.
  Future<void> saveChildProfile(String childId, Map<String, dynamic> data) async {
    if (!_available) return;
    await FirebaseFirestore.instance
        .collection('children')
        .doc(childId)
        .set(data, SetOptions(merge: true));
  }

  /// Hapus profil anak dari cloud (dipanggil saat akun dihapus).
  Future<void> deleteChildProfile(String childId) async {
    if (!_available) return;
    final col = FirebaseFirestore.instance.collection('daily_records');
    final snap =
        await col.where('childId', isEqualTo: childId).get();
    final batch = FirebaseFirestore.instance.batch();
    for (final d in snap.docs) {
      batch.delete(d.reference);
    }
    await batch.commit();
    await FirebaseFirestore.instance
        .collection('children')
        .doc(childId)
        .delete();
  }

  /// Simpan satu record ibadah harian ke path
  /// `daily_records/{childId}_{YYYY-MM-DD}` agar konsisten dengan
  /// skema backend yang dibaca oleh `getFamilyDigest`.
  Future<void> saveDailyRecord(
      String childId, String dateKey, Map<String, dynamic> data) async {
    if (!_available) return;
    final cleanId = '${childId}_${dateKey}';
    await FirebaseFirestore.instance
        .collection('daily_records')
        .doc(cleanId)
        .set(data, SetOptions(merge: true));
  }
}

/// Top-level background handler for family reminders (FCM data-only).
@pragma('vm:entry-point')
Future<void> _familyMessagingBackgroundHandler(RemoteMessage message) async {
  // Data-only messages from guardian contain activityId + templateKey.
  // Show a local notification so the child sees the reminder.
}
