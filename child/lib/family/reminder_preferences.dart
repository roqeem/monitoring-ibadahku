import 'package:cloud_firestore/cloud_firestore.dart';

/// Pengelola preferensi pengingat per aktivitas untuk seorang anak.
class ReminderPreferences {
  final FirebaseFirestore _db;
  final String _uid;

  ReminderPreferences(this._db, this._uid);

  /// Cek apakah pengguna telah memutuskan untuk *mute* semua 
  /// pengingat dari satu wali berdasarkan activityKey.
  Future<bool> isMuted(String guardianId, String activityKey) async {
    final snap = await _db
        .collection('children/$_uid/reminderExceptions/$guardianId')
        .doc(activityKey)
        .get();
    return snap.data()?['muted'] == true;
  }

  /// Simpan preferensi mute/unmute untuk aktivitas tertentu.
  Future<void> setMuted(String guardianId, String activityKey, bool value) {
    return _db
        .collection('children/$_uid/reminderExceptions/$guardianId')
        .doc(activityKey)
        .set({'muted': value}, SetOptions(merge: true));
  }
}