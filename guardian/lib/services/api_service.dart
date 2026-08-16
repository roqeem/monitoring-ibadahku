import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import '../models/models.dart';

/// Layanan API untuk memanggil callable Firebase Functions
/// dari aplikasi Monitoring IbadahKu (orang tua).
///
/// Guardian TIDAK pernah membaca Firestore secara langsung untuk data anak —
/// semua akses lewat callable (`getFamilyDigest`, `sendStandardReminder`).
///
/// `firebase_functions` package tidak tersedia untuk Dart 3.5 (Flutter 3.24),
/// jadi callable dipanggil via HTTP: POST ke URL fungsi dengan header
/// `Authorization: Bearer <idToken>` dan body `{"data": {...}}`.
class ApiService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Region & project harus sama dengan deploy backend.
  /// Ganti [projectId] sesuai proyek Firebase yang dipakai (staging:
  /// `monitor-ibadahku-dev`).
  static const String _region = 'asia-southeast2';
  static const String projectId = 'monitor-ibadahku-dev';

  String _fnUrl(String name) =>
      'https://$_region-$projectId.cloudfunctions.net/$name';

  Future<dynamic> _call(String name, Map<String, dynamic> data) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw ApiException('unauthenticated', 'Belum masuk.');
    }
    final token = await user.getIdToken();
    final resp = await http.post(
      Uri.parse(_fnUrl(name)),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'data': data}),
    );
    final body = jsonDecode(resp.body) as Map<String, dynamic>;
    if (resp.statusCode != 200 || body['error'] != null) {
      final err = body['error'] as Map<String, dynamic>?;
      final code = err?['status'] as String? ?? 'unknown';
      final message = (err?['message'] as String?)?.replaceFirst(
              'functions/', '') ??
          'Gagal (${resp.statusCode})';
      throw ApiException(code, message);
    }
    return body['result'];
  }

  /// Buat undangan monitoring untuk seorang anak.
  /// [tokenPlain] adalah kode acak yang akan dibagikan kepada anak.
  Future<String> createInvitation(String tokenPlain) async {
    final data = await _call('createInvitation', {'tokenPlain': tokenPlain});
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
  /// Melempar [ApiException] bila rate-limited atau limit harian tercapai.
  Future<String?> sendStandardReminder(
    String childId,
    String worshipDate,
    String activityKey,
    String templateKey,
  ) async {
    final data = await _call('sendStandardReminder', {
      'childId': childId,
      'worshipDate': worshipDate,
      'activityKey': activityKey,
      'templateKey': templateKey,
    });
    return data['reminderId'] as String?;
  }

  /// Dapatkan ringkasan ibadah keluarga untuk satu tanggal.
  Future<List<ChildSummary>> getFamilyDigest(String date) async {
    final data = await _call('getFamilyDigest', {'date': date});
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

  /// Riwayat harian satu anak untuk [days] hari terakhir (termasuk hari ini).
  Future<List<ChildSummary>> getChildHistory(
    String childId,
    int days,
  ) async {
    final today = DateTime.now();
    final results = await Future.wait(
      List.generate(days, (i) {
        final d = today.subtract(Duration(days: i));
        final date = _dateKey(d);
        return getFamilyDigest(date).then((list) {
          for (final c in list) {
            if (c.childId == childId) return c;
          }
          // Anak tanpa record: summary kosong untuk tanggal itu.
          return ChildSummary(
            childId: childId,
            worshipDate: date,
            completed: 0,
            pending: 0,
            skipped: 0,
          );
        });
      }),
    );
    return results.reversed.toList(); // tertua → terbaru
  }

  static String _dateKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

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

class ApiException implements Exception {
  final String code;
  final String message;
  ApiException(this.code, this.message);

  bool get isRateLimited =>
      code == 'RESOURCE_EXHAUSTED' ||
      code == 'PERMISSION_DENIED' ||
      code.toLowerCase().contains('rate');

  @override
  String toString() => message;
}
