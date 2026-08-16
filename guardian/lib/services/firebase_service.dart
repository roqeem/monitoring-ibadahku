import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/models.dart';

class FirebaseService {
  FirebaseService._();
  static final instance = FirebaseService._();

  bool _available = false;
  bool get available => _available;

  Future<void> init() async {
    try {
      await Firebase.initializeApp();
      _available = true;
    } catch (_) {
      _available = false;
    }
  }

  Future<UserProfile?> signInWithGoogle() async {
    final acct = await GoogleSignIn().signIn();
    if (acct == null) return null;
    final auth = await acct.authentication;
    final cred = GoogleAuthProvider.credential(
      accessToken: auth.accessToken,
      idToken: auth.idToken,
    );
    final user = await FirebaseAuth.instance.signInWithCredential(cred);
    return _profile(user.user);
  }

  Future<void> signOut() async {
    if (!_available) return;
    await GoogleSignIn().signOut();
    await FirebaseAuth.instance.signOut();
  }

  UserProfile? _profile(User? u) {
    if (u == null) return null;
    return UserProfile(
      id: u.uid,
      displayName: (u.displayName?.trim().isNotEmpty ?? false)
          ? u.displayName!.trim()
          : (u.email?.split('@').first ?? 'Orang Tua'),
      email: u.email ?? '',
      loginMethod: 'google',
      createdAt: u.metadata.creationTime ?? DateTime.now(),
    );
  }
}
