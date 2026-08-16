import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../data/worship_content.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';

/// Dashboard Statistik — pribadi, tanpa skor keimanan atau perbandingan.
class StatistikScreen extends StatefulWidget {
  const StatistikScreen({super.key});

  @override
  State<StatistikScreen> createState() => _StatistikScreenState();
}

enum _Periode {
  d7('7 hari terakhir'),
  d30('30 hari terakhir'),
  bulanIni('Bulan berjalan'),
  bulanLalu('Bulan sebelumnya');

  final String label;
  const _Periode(this.label);

  (DateTime, DateTime) range() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return switch (this) {
      _Periode.d7 => (today.subtract(const Duration(days: 6)), today),
      _Periode.d30 => (today.subtract(const Duration(days: 29)), today),
      _Periode.bulanIni => (DateTime(now.year, now.month, 1), DateTime(now.year, now.month + 1, 0)),
      _Periode.bulanLalu => (
          DateTime(now.year, now.month - 1, 1),
          DateTime(now.year, now.month, 0)
        ),
    };
  }
}

enum _Filter { semua, fardhu, sunnah, dzikir }

extension on _Filter {
  String get label => switch (this) {
        _Filter.semua => 'Semua kegiatan',
        _Filter.fardhu => 'Shalat fardhu',
        _Filter.sunnah => 'Shalat sunnah',
        _Filter.dzikir => 'Dzikir & doa',
      };
}

class _StatistikScreenState extends State<StatistikScreen> {
  _Periode _periode = _Periode.d30;
  _Filter _filter = _Filter.semua;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final (start, end) = _periode.range();
    final stats = state.statsFor(start, end);
    final consistency = state.dailyConsistency(start, end);
    final hasData = stats['totalTercatat'] as int > 0;

    return Scaffold(
      appBar: AppBar(title: const Text('Statistik')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final p in _Periode.values)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(p.label, style: const TextStyle(fontSize: 12.5)),
                        selected: _periode == p,
                        onSelected: (_) => setState(() => _periode = p),
                        selectedColor: AppColors.doneSoft,
                        labelStyle: TextStyle(
                          color: _periode == p ? AppColors.done : null,
                          fontWeight: FontWeight.w600,
                        ),
                        showCheckmark: false,
                      ),
                    ),
                ],
              ),
            ),
          ),
          Expanded(
            child: hasData
                ? ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    children: [
                      _FilterRow(filter: _filter, onChanged: (f) => setState(() => _filter = f)),
                      const SizedBox(height: 8),
                      _SummaryCards(stats: stats, filter: _filter),
                      const SizedBox(height: 16),
                      _ChartCard(
                        title: 'Konsistensi Harian',
                        subtitle: 'Jumlah aktivitas selesai per hari',
                        child: _LineChart(data: consistency),
                      ),
                      const SizedBox(height: 12),
                      _ChartCard(
                        title: 'Shalat Fardhu',
                        subtitle: 'Perbandingan antar shalat',
                        child: _FardhuBarChart(stats: stats, state: state),
                      ),
                      const SizedBox(height: 12),
                      _ChartCard(
                        title: 'Ibadah Sunnah',
                        subtitle: 'Tahajud, Witir, Dhuha, Rawatib',
                        child: _SunnahBarChart(stats: stats),
                      ),
                      const SizedBox(height: 12),
                      _ChartCard(
                        title: 'Dzikir & Doa',
                        subtitle: 'Jumlah penyelesaian',
                        child: _DhikrBarChart(stats: stats),
                      ),
                      const SizedBox(height: 12),
                      _ChartCard(
                        title: 'Tempat Shalat',
                        subtitle: 'Komposisi lokasi pelaksanaan',
                        child: _DonutChart(
                          data: {
                            'Masjid': (stats['fardhuMasjid'] as int).toDouble(),
                            'Musala': _placeCount(state, start, end, Place.musala),
                            'Rumah': (stats['fardhuRumah'] as int).toDouble(),
                            'Kerja': _placeCount(state, start, end, Place.kerja),
                            'Lainnya': _placeCount(state, start, end, Place.lain),
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      _ChartCard(
                        title: 'Pelaksanaan Shalat',
                        subtitle: 'Berjamaah atau sendiri',
                        child: _DonutChart(
                          data: {
                            'Berjamaah': (stats['fardhuJamaah'] as int).toDouble(),
                            'Sendiri': (stats['fardhuSendiri'] as int).toDouble(),
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      _ChartCard(
                        title: 'Ketepatan Waktu',
                        subtitle: 'Kategori waktu pelaksanaan',
                        child: _DonutChart(
                          data: {
                            'Awal waktu': (stats['fardhuAwal'] as int).toDouble(),
                            'Dalam waktu': _timeCount(state, start, end, TimeCategory.dalamWaktu),
                            'Akhir waktu': (stats['fardhuAkhir'] as int).toDouble(),
                            'Jama/Qasar': (stats['fardhuQadha'] as int).toDouble(),
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      _ChartCard(
                        title: 'Kalender Konsistensi',
                        subtitle: 'Ketuk tanggal untuk detail',
                        child: _ConsistencyCalendar(state: state),
                      ),
                      const SizedBox(height: 24),
                    ],
                  )
                : const EmptyState(
                    icon: Icons.insights_outlined,
                    message: 'Belum ada data yang cukup untuk menampilkan statistik pada periode ini.',
                  ),
          ),
        ],
      ),
    );
  }
}

double _placeCount(AppState state, DateTime start, DateTime end, Place place) {
  var c = 0;
  for (final d in state.eachDay(start, end)) {
    for (final name in kFardhuOrder) {
      final r = state.prayer(d, name);
      if (r.place == place &&
          (r.status == PrayerStatus.done || r.status == PrayerStatus.qadha ||
              r.status == PrayerStatus.jamaQasar)) {
        c++;
      }
    }
  }
  return c.toDouble();
}

double _timeCount(AppState state, DateTime start, DateTime end, TimeCategory t) {
  var c = 0;
  for (final d in state.eachDay(start, end)) {
    for (final name in kFardhuOrder) {
      final r = state.prayer(d, name);
      if (r.timeCategory == t &&
          (r.status == PrayerStatus.done || r.status == PrayerStatus.qadha ||
              r.status == PrayerStatus.jamaQasar)) {
        c++;
      }
    }
  }
  return c.toDouble();
}

// ---------------------------------------------------------------------------
// Filter
// ---------------------------------------------------------------------------

class _FilterRow extends StatelessWidget {
  final _Filter filter;
  final ValueChanged<_Filter> onChanged;
  const _FilterRow({required this.filter, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final f in _Filter.values)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(f.label, style: const TextStyle(fontSize: 12.5)),
                selected: filter == f,
                onSelected: (_) => onChanged(f),
                selectedColor: AppColors.primary,
                showCheckmark: false,
                labelStyle: TextStyle(
                  color: filter == f ? Colors.white : null,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Kartu ringkasan
// ---------------------------------------------------------------------------

class _SummaryCards extends StatelessWidget {
  final Map<String, dynamic> stats;
  final _Filter filter;
  const _SummaryCards({required this.stats, required this.filter});

  @override
  Widget build(BuildContext context) {
    final all = [
      ('Fardhu', stats['fardhuDone'] as int, Icons.mosque_outlined),
      ('Berjamaah', stats['fardhuJamaah'] as int, Icons.groups_outlined),
      ('Awal waktu', stats['fardhuAwal'] as int, Icons.schedule_outlined),
      ('Tahajud', stats['tahajud'] as int, Icons.nights_stay_outlined),
      ('Witir', stats['witir'] as int, Icons.bolt_outlined),
      ('Dhuha', stats['dhuha'] as int, Icons.wb_sunny_outlined),
      ('Rawatib', stats['rawatib'] as int, Icons.repeat_outlined),
      ('Dzikir pagi', stats['dzikirPagi'] as int, Icons.wb_twilight_outlined),
      ('Dzikir petang', stats['dzikirPetang'] as int, Icons.nightlight_outlined),
    ];
    final items = switch (filter) {
      _Filter.semua => all,
      _Filter.fardhu => all.take(3).toList(),
      _Filter.sunnah => all.where((e) => const ['Tahajud', 'Witir', 'Dhuha', 'Rawatib'].contains(e.$1)).toList(),
      _Filter.dzikir => all.where((e) => const ['Dzikir pagi', 'Dzikir petang'].contains(e.$1)).toList(),
    };
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 1.4,
      children: [
        for (final (label, value, icon) in items)
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 17, color: AppColors.primary),
                const SizedBox(height: 5),
                Text('$value',
                    style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
                Text(label,
                    style: TextStyle(
                        fontSize: 11, color: AppColors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Chart wrapper
// ---------------------------------------------------------------------------

class _ChartCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  const _ChartCard({required this.title, required this.subtitle, required this.child});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800)),
          Text(subtitle,
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Line chart konsistensi
// ---------------------------------------------------------------------------

class _LineChart extends StatelessWidget {
  final List<(DateTime, int)> data;
  const _LineChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final maxY = data.fold<int>(0, (m, e) => e.$2 > m ? e.$2 : m);
    final spots = [
      for (var i = 0; i < data.length; i++)
        FlSpot(i.toDouble(), data[i].$2.toDouble()),
    ];
    return SizedBox(
      height: 180,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: (maxY + 2).toDouble(),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => FlLine(
                color: Theme.of(context).dividerColor, strokeWidth: 1),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (v, _) => Text('${v.toInt()}',
                    style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: data.length <= 31,
                reservedSize: 24,
                interval: (data.length / 4).ceilToDouble().clamp(1, data.length).toDouble(),
                getTitlesWidget: (v, _) {
                  final i = v.toInt();
                  if (i < 0 || i >= data.length) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(DateFormat('d/M').format(data[i].$1),
                        style:
                            TextStyle(fontSize: 9.5, color: AppColors.textSecondary)),
                  );
                },
              ),
            ),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.28,
              color: AppColors.primary,
              barWidth: 2.4,
              dotData: FlDotData(show: true, getDotPainter: (s, p, b, i) =>
                  FlDotCirclePainter(
                    radius: 3,
                    color: AppColors.primary,
                    strokeWidth: 0,
                  )),
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.primary.withValues(alpha: 0.12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Bar chart fardhu
// ---------------------------------------------------------------------------

class _FardhuBarChart extends StatelessWidget {
  final Map<String, dynamic> stats;
  final AppState state;
  const _FardhuBarChart({required this.stats, required this.state});

  @override
  Widget build(BuildContext context) {
    final perPrayer = stats['perPrayer'] as Map<String, Map<String, int>>;
    final names = perPrayer.keys.toList();
    final maxV = perPrayer.values.fold<int>(
        0, (m, e) => (e['done']! > m ? e['done']! : m));
    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          maxY: (maxV + 1).toDouble(),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => FlLine(
                color: Theme.of(context).dividerColor, strokeWidth: 1),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (v, _) => Text('${v.toInt()}',
                    style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 24,
                getTitlesWidget: (v, _) {
                  final i = v.toInt();
                  if (i < 0 || i >= names.length) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                        PrayerName.fromKey(names[i]).label.substring(0, 1),
                        style:
                            TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          barGroups: [
            for (var i = 0; i < names.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: perPrayer[names[i]]!['done']!.toDouble(),
                    color: AppColors.primary,
                    width: 16,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  BarChartRodData(
                    toY: perPrayer[names[i]]!['jamaah']!.toDouble(),
                    color: AppColors.done,
                    width: 8,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Bar chart sunnah & dzikir
// ---------------------------------------------------------------------------

class _SunnahBarChart extends StatelessWidget {
  final Map<String, dynamic> stats;
  const _SunnahBarChart({required this.stats});

  @override
  Widget build(BuildContext context) {
    final data = [
      ('Tahajud', stats['tahajud'] as int),
      ('Witir', stats['witir'] as int),
      ('Dhuha', stats['dhuha'] as int),
      ('Rawatib', stats['rawatib'] as int),
    ];
    return _SimpleBar(data: data, color: AppColors.primaryLight);
  }
}

class _DhikrBarChart extends StatelessWidget {
  final Map<String, dynamic> stats;
  const _DhikrBarChart({required this.stats});

  @override
  Widget build(BuildContext context) {
    final data = [
      ('Dzikir pagi', stats['dzikirPagi'] as int),
      ('Dzikir petang', stats['dzikirPetang'] as int),
      ('Setelah shalat', stats['dzikirSetelah'] as int),
      ('Sebelum tidur', stats['dzikirSebelumTidur'] as int),
    ];
    return _SimpleBar(data: data, color: AppColors.accent);
  }
}

class _SimpleBar extends StatelessWidget {
  final List<(String, int)> data;
  final Color color;
  const _SimpleBar({required this.data, required this.color});

  @override
  Widget build(BuildContext context) {
    final maxV = data.fold<int>(0, (m, e) => e.$2 > m ? e.$2 : m);
    return SizedBox(
      height: 180,
      child: BarChart(
        BarChartData(
          maxY: (maxV + 1).toDouble(),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => FlLine(
                color: Theme.of(context).dividerColor, strokeWidth: 1),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (v, _) => Text('${v.toInt()}',
                    style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (v, _) {
                  final i = v.toInt();
                  if (i < 0 || i >= data.length) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(data[i].$1,
                        style: TextStyle(
                            fontSize: 9.5, color: AppColors.textSecondary)),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          barGroups: [
            for (var i = 0; i < data.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: data[i].$2.toDouble(),
                    color: color,
                    width: 22,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Donut chart
// ---------------------------------------------------------------------------

class _DonutChart extends StatelessWidget {
  final Map<String, double> data;
  const _DonutChart({required this.data});

  static const _palette = [
    AppColors.primary,
    AppColors.done,
    AppColors.accent,
    Color(0xFF5C7C99),
    Color(0xFFB0874B),
  ];

  @override
  Widget build(BuildContext context) {
    final entries = data.entries.where((e) => e.value > 0).toList();
    final total = entries.fold<double>(0, (s, e) => s + e.value);
    if (total == 0) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text('Belum ada data untuk chart ini.',
            style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
      );
    }
    return Column(
      children: [
        SizedBox(
          height: 160,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 44,
              sections: [
                for (var i = 0; i < entries.length; i++)
                  PieChartSectionData(
                    value: entries[i].value,
                    color: _palette[i % _palette.length],
                    radius: 44,
                    title: '${(entries[i].value / total * 100).round()}%',
                    titleStyle: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Colors.white),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 6,
          alignment: WrapAlignment.center,
          children: [
            for (var i = 0; i < entries.length; i++)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                        color: _palette[i % _palette.length],
                        borderRadius: BorderRadius.circular(3)),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    '${entries[i].key} ${entries[i].value.toInt()}',
                    style: TextStyle(
                        fontSize: 11.5,
                        color: Theme.of(context).colorScheme.onSurface),
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Kalender konsistensi
// ---------------------------------------------------------------------------

class _ConsistencyCalendar extends StatelessWidget {
  final AppState state;
  const _ConsistencyCalendar({required this.state});

  @override
  Widget build(BuildContext context) {
    final month = DateTime(DateTime.now().year, DateTime.now().month, 1);
    final summary = state.calendarSummary(month);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final firstWeekday = month.weekday;
    final today = AppState.dateOnly(DateTime.now());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(DateFormat('MMMM yyyy', 'id_ID').format(month),
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7, childAspectRatio: 1),
          itemCount: firstWeekday - 1 + daysInMonth,
          itemBuilder: (context, i) {
            if (i < firstWeekday - 1) return const SizedBox.shrink();
            final d = DateTime(month.year, month.month, i - firstWeekday + 2);
            final level = summary[AppState.dateKey(d)] ?? 0;
            final isDark =
                Theme.of(context).brightness == Brightness.dark;
            // bg + teks dark-aware: level 0 kosong, 1 sebagian, 2 lengkap, 3 haid/kondisi
            final (bg, fg) = switch (level) {
              3 => isDark
                  ? (const Color(0xFF23303A), const Color(0xFF9DBBD8))
                  : (AppColors.uzurSoft, AppColors.textSecondary),
              2 => isDark
                  ? (const Color(0xFF1E3A30), const Color(0xFF7FD1A8))
                  : (AppColors.doneSoft, const Color(0xFF2E6B4F)),
              1 => isDark
                  ? (const Color(0xFF1E3A30), const Color(0xFF7FD1A8))
                  : (AppColors.doneSoft, AppColors.textSecondary),
              _ => isDark
                  ? (const Color(0xFF1D2927), const Color(0xFFB9C7C3))
                  : (AppColors.pendingSoft, AppColors.textSecondary),
            };
            return GestureDetector(
              onTap: () async {
                state.currentDate = d;
                final picked = await showDatePicker(
                  context: context,
                  initialDate: d,
                  firstDate: DateTime(d.year - 1),
                  lastDate: DateTime.now(),
                );
                if (picked != null) state.currentDate = picked;
              },
              child: Container(
                margin: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(8),
                  border: d == today
                      ? Border.all(color: AppColors.primary, width: 1.4)
                      : null,
                ),
                alignment: Alignment.center,
                child: Text('${d.day}',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: fg,
                    )),
              ),
            );
          },
        ),
      ],
    );
  }
}
