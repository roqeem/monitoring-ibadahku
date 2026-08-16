import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';

class InvitationsScreen extends StatefulWidget {
  const InvitationsScreen({super.key});

  @override
  State<InvitationsScreen> createState() => _InvitationsScreenState();
}

class _InvitationsScreenState extends State<InvitationsScreen> {
  final _tokenCtrl = TextEditingController();
  bool _generating = false;

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AppState>().user!.id;
    final api = ApiService();

    return Scaffold(
      appBar: AppBar(title: const Text('Undangan Monitoring')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('invitations')
            .where('guardianId', isEqualTo: uid)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data!.docs;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildCreateSection(),
              const SizedBox(height: 16),
              if (docs.isEmpty)
                _buildEmptyState()
              else
                ...docs.map((doc) => _buildInviteCard(doc)).toList(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCreateSection() {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Buat Undangan Baru',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          TextField(
            controller: _tokenCtrl,
            decoration: InputDecoration(
              labelText: 'Kode akses (opsional)',
              hintText: 'Biarkan kosong untuk kode otomatis',
              prefixIcon: const Icon(Icons.key, size: 20),
            ),
            readOnly: _generating,
          ),
          const SizedBox(height: 12),
          Text(
            'Kode ini akan dibagikan ke anak anda untuk menyetujui akses '
            'pemantauan ibadah.',
            style: TextStyle(
              fontSize: 12.5,
              height: 1.5,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _generating ? null : _createInvitation,
              icon: _generating
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.qr_code, size: 20),
              label: Text(_generating ? 'Membuat...' : 'Buat Undangan',
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _createInvitation() async {
    setState(() => _generating = true);
    try {
      final token = _tokenCtrl.text.trim().isNotEmpty
          ? _tokenCtrl.text.trim()
          : _generateRandomCode();
      final id = await ApiService().createInvitation(token);

      setState(() {
        _tokenCtrl.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Undangan berhasil dibuat: $token')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal: $e'), backgroundColor: AppColors.missed),
      );
    } finally {
      setState(() => _generating = false);
    }
  }

  String _generateRandomCode() {
    final chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ0123456789';
    final rand = DateTime.now().millisecondsSinceEpoch;
    return String.fromCharCodes(
      Iterable.generate(
        6,
        (i) => chars[(rand + i * 7) % chars.length].codeUnitAt(0),
      ),
    );
  }

  Widget _buildInviteCard(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final status = data['status'] as String? ?? 'unknown';
    final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
    final color = status == 'accepted'
        ? AppColors.done
        : (status == 'pending' ? AppColors.pending : AppColors.missed);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          child: Icon(
            status == 'accepted'
                ? Icons.check_circle_outline
                : Icons.hourglass_empty,
            color: color,
          ),
        ),
        title: const Text('Undangan untuk anak'),
        subtitle: Text(
          '${DateFormat('dd/MM/yyyy HH:mm').format(createdAt ?? DateTime.now())}\nStatus: ${status.toUpperCase()}',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        isThreeLine: true,
        trailing: IconButton(
          icon: const Icon(Icons.copy, size: 20),
          tooltip: 'Salin kode',
          onPressed: () => _copyToken(context, doc.id),
        ),
      ),
    );
  }

  Future<void> _copyToken(BuildContext context, String invitationId) async {
    final token = await ApiService().getInvitationToken(invitationId);
    if (token != null && context.mounted) {
      await Clipboard.setData(ClipboardData(text: token));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kode undangan disalin: $token')),
      );
    }
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Text(
        'Belum ada undangan yang pernah dibuat.',
        textAlign: TextAlign.center,
        style: TextStyle(color: AppColors.textSecondary),
      ),
    );
  }
}
