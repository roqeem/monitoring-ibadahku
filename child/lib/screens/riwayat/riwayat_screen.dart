import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../home/home_shell.dart' show homeTabIndex;
import '../home/today_screen.dart';

/// Halaman Riwayat — data per tanggal, ringkasan mingguan, kalender bulanan.
class RiwayatScreen extends StatefulWidget {
  const RiwayatScreen({super.key});

  @override
  State<RiwayatScreen> createState() => _RiwayatScreenState();
}

class _RiwayatScreenState extends State<RiwayatScreen> {
  int _tab = 0; // 0 harian, 1 mingguan, 2 bulanan
  DateTime _anchor = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 0, label: Text('Harian'), icon: Icon(Icons.today_outlined, size: 16)),
                ButtonSegment(value: 1, label: Text('Mingguan'), icon: Icon(Icons.date_range_outlined, size: 16)),
                ButtonSegment(value: 2, label: Text('Bulanan'), icon: Icon(Icons.calendar_month_outlined, size: 16)),
              ],
              selected: {_tab},
              onSelectionChanged: (s) => setState(() => _tab = s.first),
              showSelectedIcon: false,
              style: SegmentedButton.styleFrom(
                selectedBackgroundColor: AppColors.doneSoft,
                selectedForegroundColor: AppColors.done,
              ),
            ),
          ),
          Expanded(
            child: switch (_tab) {
              0 => _HarianView(anchor: _anchor, onAnchor: (d) => setState(() => _anchor = d)),
              1 => _MingguanView(anchor: _anchor, onAnchor: (d) => setState(() => _anchor = d)),
              _ => _BulananView(anchor: _anchor, onAnchor: (d) => setState(() => _anchor = d)),
            },
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Harian
// ---------------------------------------------------------------------------

class _HarianView extends StatelessWidget {
  final DateTime anchor;
  final ValueChanged<DateTime> onAnchor;
  const _HarianView({required this.anchor, required this.onAnchor});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final d = AppState.dateOnly(anchor);
    final (done, total) = state.progressOf(d);
    final sections = state.timeline(d);

    return Column(
      children: [
        _DateNav(date: d, onAnchor: onAnchor),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            children: [
              AppCard(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Text('$done dari $total aktivitas tercatat',
                        style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700)),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        state.currentDate = d;
                        homeTabIndex.value = 0;
                      },
                      child: const Text('Lihat di Hari Ini'),
                    ),
                  ],
                ),
              ),
              for (final s in sections)
                _SectionReadOnly(section: s, date: d),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionReadOnly extends StatelessWidget {
  final TimelineSection section;
  final DateTime date;
  const _SectionReadOnly({required this.section, required this.date});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: section.title, subtitle: section.timeLabel),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var i = 0; i < section.items.length; i++) ...[
                if (i > 0) const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  dense: true,
                  leading: Icon(
                    switch (section.items[i].kind) {
                      ActivityKind.fardhu => Icons.mosque_outlined,
                      ActivityKind.sunnah => Icons.self_improvement,
                      ActivityKind.dhikr => Icons.menu_book_outlined,
                    },
                    size: 20,
                    color: statusColor(section.items[i].status, Theme.of(context).brightness),
                  ),
                  title: Text(section.items[i].title,
                      style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
                  trailing: StatusChip(status: section.items[i].status),
                  onTap: () => openActivitySheet(context, date, section.items[i]),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Mingguan
// ---------------------------------------------------------------------------

class _MingguanView extends StatelessWidget {
  final DateTime anchor;
  final ValueChanged<DateTime> onAnchor;
  const _MingguanView({required this.anchor, required this.onAnchor});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    // minggu berjalan: Senin - Minggu
    final monday = AppState.dateOnly(anchor).subtract(Duration(days: anchor.weekday - 1));
    final days = [for (var i = 0; i < 7; i++) monday.add(Duration(days: i))];
    final stats = state.statsFor(monday, days.last);

    return Column(
      children: [
        _WeekNav(monday: monday, onAnchor: onAnchor),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            children: [
              _SummaryStrip(stats: stats),
              const SizedBox(height: 12),
              AppCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    for (var i = 0; i < days.length; i++) ...[
                      if (i > 0) const Divider(height: 1, indent: 16, endIndent: 16),
                      _WeekRow(
                        date: days[i],
                        isSelected: AppState.dateOnly(anchor) == days[i],
                        onTap: () => onAnchor(days[i]),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _WeekRow extends StatelessWidget {
  final DateTime date;
  final bool isSelected;
  final VoidCallback onTap;
  const _WeekRow({required this.date, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final (done, total) = state.progressOf(date);
    final fardhu = _countFardhuDone(state, date);
    return ListTile(
      onTap: onTap,
      selected: isSelected,
      selectedTileColor: AppColors.doneSoft,
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: done > 0 ? AppColors.doneSoft : AppColors.pendingSoft,
          borderRadius: BorderRadius.circular(11),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(DateFormat('EEE', 'id_ID').format(date),
                style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary)),
            Text('${date.day}',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          ],
        ),
      ),
      title: Text(formatDateShort(date),
          style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
      subtitle: Text(
        'Fardhu $fardhu · Sunnah ${done - fardhu - _countDhikrDone(state, date)} · Dzikir ${_countDhikrDone(state, date)}',
        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
      ),
      trailing: Text('$done/$total',
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
    );
  }
}

int _countFardhuDone(AppState state, DateTime d) {
  var c = 0;
  for (final s in state.timeline(d)) {
    for (final it in s.items) {
      if (it.kind == ActivityKind.fardhu &&
          (it.status == ActivityStatus.done || it.status == ActivityStatus.uzur)) {
        c++;
      }
    }
  }
  return c;
}

int _countDhikrDone(AppState state, DateTime d) {
  var c = 0;
  for (final s in state.timeline(d)) {
    for (final it in s.items) {
      if (it.kind == ActivityKind.dhikr &&
          (it.status == ActivityStatus.done || it.status == ActivityStatus.uzur)) {
        c++;
      }
    }
  }
  return c;
}

// ---------------------------------------------------------------------------
// Bulanan (kalender)
// ---------------------------------------------------------------------------

class _BulananView extends StatelessWidget {
  final DateTime anchor;
  final ValueChanged<DateTime> onAnchor;
  const _BulananView({required this.anchor, required this.onAnchor});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final month = DateTime(anchor.year, anchor.month, 1);
    final summary = state.calendarSummary(month);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final firstWeekday = month.weekday; // 1=Sen
    final stats = state.statsFor(month, DateTime(month.year, month.month + 1, 0));
    final today = AppState.dateOnly(DateTime.now());

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () => onAnchor(DateTime(month.year, month.month - 1, 1)),
              ),
              Expanded(
                child: Text(
                  DateFormat('MMMM yyyy', 'id_ID').format(month),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () => onAnchor(DateTime(month.year, month.month + 1, 1)),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            children: [
              AppCard(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        for (final w in ['S', 'S', 'R', 'K', 'J', 'S', 'M'])
                          Expanded(
                            child: Center(
                              child: Text(w,
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textSecondary)),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 7, childAspectRatio: 1),
                      itemCount: firstWeekday - 1 + daysInMonth,
                      itemBuilder: (context, i) {
                        if (i < firstWeekday - 1) return const SizedBox.shrink();
                        final d = DateTime(month.year, month.month, i - firstWeekday + 2);
                        final key = AppState.dateKey(d);
                        final level = summary[key] ?? 0;
                        final isToday = d == today;
                        final isSelected = AppState.dateOnly(anchor) == d;
                        return _DayCell(
                            day: d.day,
                            level: level,
                            isToday: isToday,
                            isSelected: isSelected,
                            onTap: () => onAnchor(d));
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _Legend(color: AppColors.pendingSoft, label: 'Kosong'),
                  const SizedBox(width: 12),
                  _Legend(color: AppColors.doneSoft, label: 'Sebagian'),
                  const SizedBox(width: 12),
                  _Legend(color: AppColors.done, label: 'Lengkap'),
                  const SizedBox(width: 12),
                  _Legend(color: AppColors.uzur, label: 'Haid/Nifas'),
                ],
              ),
              const SizedBox(height: 16),
              _SummaryStrip(stats: stats),
            ],
          ),
        ),
      ],
    );
  }
}

class _DayCell extends StatelessWidget {
  final int day;
  final int level;
  final bool isToday;
  final bool isSelected;
  final VoidCallback onTap;
  const _DayCell({
    required this.day,
    required this.level,
    required this.isToday,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = switch (level) {
      3 => AppColors.uzur,
      2 => AppColors.done,
      1 => AppColors.done,
      _ => null,
    };
    final bg = switch (level) {
      3 => AppColors.uzurSoft,
      2 => AppColors.doneSoft,
      1 => AppColors.doneSoft,
      _ => AppColors.pendingSoft,
    };
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: isSelected ? color?.withValues(alpha: 0.45) ?? AppColors.doneSoft : bg,
          borderRadius: BorderRadius.circular(10),
          border: isToday ? Border.all(color: AppColors.primary, width: 1.6) : null,
        ),
        alignment: Alignment.center,
        child: Text(
          '$day',
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
            color: level == 2 && !isSelected ? Colors.white : null,
          ),
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
        ),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Elemen bersama
// ---------------------------------------------------------------------------

class _SummaryStrip extends StatelessWidget {
  final Map<String, dynamic> stats;
  const _SummaryStrip({required this.stats});

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Fardhu', stats['fardhuDone'] as int, Icons.mosque_outlined),
      ('Berjamaah', stats['fardhuJamaah'] as int, Icons.groups_outlined),
      ('Awal waktu', stats['fardhuAwal'] as int, Icons.schedule_outlined),
      ('Tahajud', stats['tahajud'] as int, Icons.nights_stay_outlined),
      ('Witir', stats['witir'] as int, Icons.bolt_outlined),
      ('Dhuha', stats['dhuha'] as int, Icons.wb_sunny_outlined),
      ('Rawatib', stats['rawatib'] as int, Icons.repeat_outlined),
      ('Dzikir pagi', stats['dzikirPagi'] as int, Icons.wb_twilight_outlined),
      ('Dzikir petang', stats['dzikirPetang'] as int, Icons.nightlight_outlined),
      ('Doa tidur', stats['doaSebelumTidur'] as int, Icons.bedtime_outlined),
    ];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final (label, value, icon) in items)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 16, color: AppColors.primary),
                const SizedBox(width: 6),
                Text('$label $value',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
      ],
    );
  }
}

class _DateNav extends StatelessWidget {
  final DateTime date;
  final ValueChanged<DateTime> onAnchor;
  const _DateNav({required this.date, required this.onAnchor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => onAnchor(date.subtract(const Duration(days: 1))),
          ),
          Expanded(
            child: Text(
              formatDateLong(date),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => onAnchor(date.add(const Duration(days: 1))),
          ),
        ],
      ),
    );
  }
}

class _WeekNav extends StatelessWidget {
  final DateTime monday;
  final ValueChanged<DateTime> onAnchor;
  const _WeekNav({required this.monday, required this.onAnchor});

  @override
  Widget build(BuildContext context) {
    final range = '${DateFormat('d MMM', 'id_ID').format(monday)} – '
        '${DateFormat('d MMM yyyy', 'id_ID').format(monday.add(const Duration(days: 6)))}';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => onAnchor(monday.subtract(const Duration(days: 7))),
          ),
          Expanded(
            child: Text(range,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => onAnchor(monday.add(const Duration(days: 7))),
          ),
        ],
      ),
    );
  }
}
