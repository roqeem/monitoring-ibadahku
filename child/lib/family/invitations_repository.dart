import 'package:cloud_firestore/cloud_firestore.dart';

/// Repositori undangan akses keluarga.
/// Menyimpan/membaca undangan yang dibuat atau diterima oleh pengguna.
class InvitationsRepository {
  final FirebaseFirestore _db;
  final String _uid;

  InvitationsRepository(this._db, this._uid);

  Stream<List<DocumentSnapshot>> invitationStream() {
    return _db
        .collectionGroup('invitations')
        .where('guardianId', isEqualTo: _uid)
        .snapshots();
  }

  Future<QuerySnapshot> fetchInvitations() {
    return _db
        .collectionGroup('invitations')
        .where('guardianId', isEqualTo: _uid)
        .get();
  }

  Future<void> saveDraft(String token, String code) async {
    final inv = await _db
        .collection('invitations')
        .add({'tokenHash': token, 'code': code, 'status': 'pending'});
    return inv.update({'id': inv.id});
  }
}