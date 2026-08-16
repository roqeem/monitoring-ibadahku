import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/models.dart';
import '../../services/api_service.dart';
import '../../features/reminders/reminder_templates.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';

class ChildDetailScreen extends StatefulWidget {
  final ChildSummary child;
  const ChildDetailScreen({super.key, required this.child});

  @override
  State<ChildDetailScreen> createState() => _ChildDetailScreenState();
}

class _ChildDetailScreenState extends State<ChildDetailScreen> {
  late Future<List<ChildSummary>> _history;
  bool _sending = false;
  String? _sendResult;

  @override
  void initState() {
    super.initState();
    _history = ApiService().getChildHistory(widget.child.childId, 7);
  }

  String get _todayKey =>
      DateFormat('yyyy-MM-dd').format(DateTime.now());

  Future<void> _sendReminder(ReminderTemplate tpl) async {
    setState(() {
      _sending = true;
      _sendResult = null;
    });
    try {
      final reminderId = await ApiService().sendStandardReminder(
        widget.child.childId,
        _todayKey,
        tpl.activityKey,
        'gentle_${tpl.activityKey}',
      );
      if (!mounted) return;
      setState(() => _sendResult =
          'Pengirim diterima' + (reminderId != null ? '' : ' (dibatasi)'));
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_sendResult!),
        backgroundColor: AppColors.done,
      ));
      Navigator.of(context).pop();
    } on ReminderException catch (e) {
      if (!mounted) return;
      setState(() => _sendResult = e.message);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          e.isRateLimited
              ? 'Pengingat untuk aktivitas ini belum bisa dikirim lagi (batas 6 jam).'
              : e.message,
        ),
        backgroundColor: AppColors.missed,
      ));
    } catch (e) {
      if (!mounted) return;
      setState(() => _sendResult = 'Gagal: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Gagal: $e'),
        backgroundColor: AppColors.missed,
      ));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _showReminderSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        builder: (context, scrollCtrl) => Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Kirim Pengingat',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(
                'Pesan standar, netral. Maksimal 1 per 6 jam per aktivitas, '
                '10 per hari.',
                style: TextStyle(
                    fontSize: 12.5, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  controller: scrollCtrl,
                  itemCount: kReminderTemplates.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 6),
                  itemBuilder: (context, i) {
                    final tpl = kReminderTemplates[i];
                    return ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                            color: AppColors.primary.withOpacity(0.3)),
                      ),
                      leading: Icon(Icons.notifications_active_outlined,
                          color: AppColors.primary),
                      title: Text(tpl.label,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(tpl.message,
                          style: TextStyle(
                              fontSize: 12.5, color: AppColors.textSecondary)),
                      isThreeLine: true,
                      trailing: _sending
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.send, size: 18),
                      onTap: _sending ? null : () => _sendReminder(tpl),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.child;
    final name = c.displayName ?? c.childId.substring(0, 8);
    return Scaffold(
      appBar: AppBar(
        title: Text(name),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_active_outlined),
            tooltip: 'Kirim pengingat',
            onPressed: _sending ? null : _showReminderSheet,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _todaySummaryCard(c),
          const SizedBox(height: 20),
          FutureBuilder<List<ChildSummary>>(
            future: _history,
            builder: (context, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final days = snap.data ?? [];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(title: 'RIWAYAT 7 HARI'),
                  if (days.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'Belum ada data ibadah.',
                        textAlign: TextAlign.center,
                        style:
                            TextStyle(color: AppColors.textSecondary),
                      ),
                    )
                  else ...[
                    _barChart(days),
                    const SizedBox(height: 8),
                    ...days.reversed.map((d) => _dayRow(d)).toList(),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _todaySummaryCard(ChildSummary c) {
    final total = c.completed + c.pending + c.skipped;
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hari ini · ${DateFormat('EEEE, d MMMM').format(DateTime.now())}',
            style: TextStyle(
                fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _stat('Selesai', c.completed, AppColors.done),
              _stat('Belum', c.pending, AppColors.pending),
              _stat('Terlewat', c.skipped, AppColors.missed),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: total == 0 ? 0 : c.completed / total,
            backgroundColor: AppColors.pending.withOpacity(0.2),
            color: AppColors.done,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 8),
          Text(
            '${c.completed}/$total aktivitas tercatat',
            style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, int value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text('$value',
              style: TextStyle(
                  fontSize: 26, fontWeight: FontWeight.w800, color: color)),
          Text(label, style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _barChart(List<ChildSummary> days) {
    final maxVal = days.fold<int>(
        0, (m, d) => [m, d.completed, d.pending].reduce((a, b) => a > b ? a : b));
    final safeMax = maxVal < 1 ? 1 : maxVal;

    return AppCard(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
      child: SizedBox(
        height: 160,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: safeMax.toDouble() + 1,
            barTouchData: BarTouchData(enabled: false),
            titlesData: FlTitlesData(
              leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final i = value.toInt();
                    if (i < 0 || i >= days.length) return const SizedBox.shrink();
                    final d = days[i];
                    final dt = DateTime.tryParse(d.worshipDate);
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        dt != null ? DateFormat('E').format(dt) : '',
                        style: const TextStyle(fontSize: 10),
                      ),
                    );
                  },
                ),
              ),
            ),
            gridData: const FlGridData(show: false),
            borderData: FlBorderData(show: false),
            barGroups: List.generate(days.length, (i) {
              final d = days[i];
              return BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: d.completed.toDouble(),
                    color: AppColors.done,
                    width: 10,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  BarChartRodData(
                    toY: d.pending.toDouble(),
                    color: AppColors.pending,
                    width: 10,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _dayRow(ChildSummary d) {
    final dt = DateTime.tryParse(d.worshipDate);
    final label = dt != null
        ? DateFormat('EEEE, d MMM').format(dt)
        : d.worshipDate;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(label, style: const TextStyle(fontSize: 13)),
          ),
          Text('${d.completed} ✓',
              style: const TextStyle(fontSize: 12, color: AppColors.done)),
          const SizedBox(width: 10),
          Text('${d.pending} ·',
              style: const TextStyle(fontSize: 12, color: AppColors.pending)),
          const SizedBox(width: 10),
          Text('${d.skipped} ×',
              style: const TextStyle(fontSize: 12, color: AppColors.missed)),
        ],
      ),
    );
  }
}
