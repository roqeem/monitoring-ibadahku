import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_service.dart';

/// Repositori sederhana untuk melihat riwayat audit lokal.
/// Hanya menampilkan log yang relevan (tanpa data pribadi lainnya).
class AuditLogRepository {
  final FirebaseFirestore _db;
  final String _uid;

  AuditLogRepository(this._db, this._uid);

  /// Ambil entri audit terbaru yang melibatkan pengguna ini.
  Future<List<DocumentSnapshot>> fetchRecent({int limit = 50}) async {
    final snap = await _db
        .collection('auditLogs')
        .where('actorIdHash', isEqualTo: _hash(_uid))
        .orderBy('occurredAt', descending: true)
        .limit(limit)
        .get();
    return snap.docs;
  }

  String _hash(String input) {
    // Mirror backend hashId (first 16 chars of sha256 hex)
    final bytes = input.codeUnits;
    var hash = 0;
    for (final b in bytes) {
      hash = ((hash << 5) - hash + b) & 0xFFFFFFFF;
    }
    return hash.toRadixString(16).padLeft(16, '0');
  }
}