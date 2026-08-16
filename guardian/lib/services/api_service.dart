import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_functions/firebase_functions.dart';
import '../models/models.dart';

/// Layanan API untuk memanggil callable Firebase Functions
/// dari aplikasi Monitoring IbadahKu (orang tua).
class ApiService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Buat undangan monitoring untuk seorang anak.
  /// [tokenPlain] adalah kode acak yang akan dibagikan kepada anak.
  Future<String> createInvitation(String tokenPlain) async {
    final func = FirebaseFunctions.instance.httpsCallable('createInvitation');
    final result = await func.call({'tokenPlain': tokenPlain});
    final data = result.data as Map<String, dynamic>;
    final id = data['invitationId'] as String;
    // Simpan token agar orang tua bisa membagikannya
    await _db.collection('invitation_tokens').doc(id).set({
      'tokenPlain': tokenPlain,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    return id;
  }

  /// Dapatkan token undangan yang sudah pernah dibuat orang tua.
  Future<String?> getInvitationToken(String invitationId) async {
    final doc =
        await _db.collection('invitation_tokens').doc(invitationId).get();
    if (!doc.exists) return null;
    return doc.data()?['tokenPlain'] as String?;
  }

  /// Kirim reminder standar ke anak.
  Future<void> sendStandardReminder(
    String childId,
    String worshipDate,
    String activityKey,
    String templateKey,
  ) async {
    final func =
        FirebaseFunctions.instance.httpsCallable('sendStandardReminder');
    await func.call({
      'childId': childId,
      'worshipDate': worshipDate,
      'activityKey': activityKey,
      'templateKey': templateKey,
    });
  }

  /// Dapatkan ringkasan ibadah keluarga untuk tanggal tertentu.
  Future<List<ChildSummary>> getFamilyDigest(String date) async {
    final func = FirebaseFunctions.instance.httpsCallable('getFamilyDigest');
    final result = await func.call({'date': date});
    final data = result.data as Map<String, dynamic>;
    final children = data['children'] as List<dynamic>;
    return children
        .map((c) => ChildSummary(
              childId: c['childId'] as String,
              displayName: c['displayName'] as String?,
              photoUrl: c['photoUrl'] as String?,
              completed: c['completed'] as int? ?? 0,
              pending: c['pending'] as int? ?? 0,
              skipped: c['skipped'] as int? ?? 0,
              worshipDate: c['worshipDate'] as String,
            ))
        .toList();
  }

  /// Stream undangan yang pernah dibuat oleh guardian ini.
  Stream<List<Invitation>> invitationsStream(String guardianId) {
    return _db
        .collection('invitations')
        .where('guardianId', isEqualTo: guardianId)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => Invitation(
                  id: doc.id,
                  guardianId: doc['guardianId'] as String? ?? '',
                  tokenHash: doc['tokenHash'] as String? ?? '',
                  status: doc['status'] as String? ?? 'pending',
                  createdAt:
                      (doc['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
                ))
            .toList());
  }
}
