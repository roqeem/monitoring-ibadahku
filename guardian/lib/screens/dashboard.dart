import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../state/app_state.dart';
import '../services/api_service.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import 'child/child_detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardState();
}

class _DashboardState extends State<DashboardScreen> {
  DateTime _selectedDate = DateTime.now();
  late Future<List<ChildSummary>> _digestFuture;

  @override
  void initState() {
    super.initState();
    _loadDigest();
  }

  void _loadDigest() {
    final date = DateFormat('yyyy-MM-dd').format(_selectedDate);
    _digestFuture = ApiService().getFamilyDigest(date);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 60)),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _loadDigest();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<AppState>().user;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Monitoring IbadahKu'),
        actions: [
          if (user != null)
            Padding(
              padding: const EdgeInsets.only(right: 12, left: 8),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primary,
                child: Text(
                  user.displayName[0].toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            color: Theme.of(context).colorScheme.surface,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('EEEE, d MMMM yyyy')
                      .format(_selectedDate),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today_outlined, size: 20),
                  onPressed: _pickDate,
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<ChildSummary>>(
              future: _digestFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                final children = snapshot.data ?? [];
                if (children.isEmpty) {
                  return Center(
                    child: Text(
                      'Belum ada anak yang terhubung. '
                      'Bagikan undangan melalui menu Undangan.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: children.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final c = children[i];
                    final total = c.completed + c.pending + c.skipped;
                    return Card(
                      elevation: 2,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primary,
                          child: Text(
                            (c.displayName?.isNotEmpty ?? false)
                                ? c.displayName![0].toUpperCase()
                                : 'A',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(c.displayName ??
                            c.childId.substring(0, 8)),
                        subtitle: Text(
                          '${c.completed}/${total} ibadah selesai',
                        ),
                        trailing: Icon(Icons.chevron_right, size: 20),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ChildDetailScreen(child: c),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).pushNamed('/invitations');
        },
        icon: const Icon(Icons.qr_code_scanner),
        label: const Text('Bagikan Undangan'),
      ),
    );
  }
}
