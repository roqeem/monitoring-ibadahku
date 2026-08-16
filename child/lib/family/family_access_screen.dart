import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_service.dart';
import '../family/relationships_repository.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';

/// Layar "Akses Keluarga" — daftar wali yang sudah mengajak/memantau akun ini.
class FamilyAccessScreen extends StatelessWidget {
  final String uid;
  const FamilyAccessScreen({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    final fb = FirebaseService.instance;

    return Scaffold(
      appBar: AppBar(title: const Text('Akses Keluarga')),
      body: !fb.available
          ? const _OfflinePlaceholder()
          : StreamBuilder<QuerySnapshot>(
              stream: RelationshipsRepository(
                      FirebaseFirestore.instance, uid)
                  .activeRelationshipsQuery()
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snapshot.data!.docs;
                final active = docs.where((d) =>
                    (d.data() as Map<String, dynamic>)['status'] == 'active').toList();
                final pending = docs.where((d) =>
                    (d.data() as Map<String, dynamic>)['status'] == 'pending' ||
                    (d.data() as Map<String, dynamic>)['status'] == 'awaitingConsent').toList();

                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  children: [
                    const _SectionTitle(title: 'Akses Aktif'),
                    if (active.isEmpty)
                      _buildEmptyState('Belum ada wali yang memantau akun ini.')
                    else
                      ...active.map((d) => _buildRelationshipTile(
                          context, d.data() as Map<String, dynamic>)),
                    const _SectionTitle(title: 'Undangan Tertunda'),
                    if (pending.isEmpty)
                      _buildEmptyState('Tidak ada undangan tertunda.')
                    else
                      ...pending.map((d) => _buildPendingTile(d)),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Text(message,
          style: const TextStyle(fontSize: 13, color: Colors.grey),
          textAlign: TextAlign.center),
    );
  }

  Widget _buildRelationshipTile(
      BuildContext context, Map<String, dynamic> data) {
    final relId = data['relationshipId'] as String? ?? '';
    final guardianId = data['guardianId'] as String? ?? 'anonim';
    final createdAt = data['createdAt'] as Timestamp?;
    return FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('guardians')
            .doc(guardianId)
            .get(),
        builder: (context, snap) {
          final gData = snap.data?.data() as Map<String, dynamic>?;
          final name = gData?['displayName'] ?? 'Wali';
          final role = gData?['declaredRelationship'] ?? 'Wali';
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.accent,
              child: Text(name.toString()[0].toUpperCase(),
                  style: const TextStyle(color: Colors.white)),
            ),
            title: Text(name.toString()),
            subtitle: Text('$role · Sejak ${_formatDate(createdAt)}',
                style: const TextStyle(fontSize: 12)),
            trailing: PopupMenuButton<String>(
              onSelected: (v) async {
                if (v == 'revoke') {
                  await RelationshipsRepository(
                          FirebaseFirestore.instance, uid)
                      .revoke(relId);
                  ScaffoldMessenger.of(context)
                      .showSnackBar(const SnackBar(content: Text('Akses dicabut')));
                }
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'revoke', child: Text('Cabut Akses')),
              ],
            ),
          );
        });
  }

  Widget _buildPendingTile(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final guardianId = data['guardianId'] as String? ?? '';
    return FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('guardians')
            .doc(guardianId)
            .get(),
        builder: (context, snap) {
          final gData = snap.data?.data() as Map<String, dynamic>?;
          final name = gData?['displayName'] ?? 'Wali';
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.uzur,
              child: const Icon(Icons.hourglass_empty, color: Colors.white),
            ),
            title: Text(name.toString()),
            subtitle: const Text('Menunggu persetujuan'),
          );
        });
  }

  String _formatDate(Timestamp? ts) {
    if (ts == null) return '-';
    final d = ts.toDate();
    return '${d.day}/${d.month}/${d.year}';
  }
}

class _OfflinePlaceholder extends StatelessWidget {
  const _OfflinePlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'Koneksi cloud belum tersedia. '
          'Hubungkan akun Firebase untuk mengelola akses keluarga.',
          textAlign: TextAlign.center,
          style: TextStyle(height: 1.5),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
      child: Text(title,
          style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5)),
    );
  }
}
