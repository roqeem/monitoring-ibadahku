import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_service.dart';

/// Repositori relasi keluarga untuk pengguna.
/// Membaca dan mengelola hubungan aktif antara pengguna (sebagai anak)
/// dengan wali/ortang tuanya.
class RelationshipsRepository {
  final FirebaseFirestore _db;
  final String _uid;

  RelationshipsRepository(this._db, this._uid);

  /// Query hubungan di mana pengguna ini adalah anak.
  Query activeRelationshipsQuery() {
    return _db
        .collection('relationships')
        .where('childId', isEqualTo: _uid)
        .where('status', whereIn: ['active', 'pending']);
  }

  /// Stream hubungan aktif di mana pengguna ini adalah anak.
  Stream<QuerySnapshot> activeRelationshipsStream() {
    return activeRelationshipsQuery().snapshots();
  }

  /// Ambil semua hubungan yang masih aktif.
  Future<List<QueryDocumentSnapshot>> fetchActiveRelationships() async {
    final snap = await activeRelationshipsQuery().get();
    return snap.docs;
  }

  /// Batalkan izin akses terhadap satu relasi.
  Future<void> revoke(String relationshipId) {
    return _db.collection('relationships').doc(relationshipId).update({
      'status': 'revokedByChild',
      'revokedAt': FieldValue.serverTimestamp(),
    });
  }
}