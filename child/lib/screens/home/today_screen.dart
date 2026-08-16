import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../data/prayer_times.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import 'sheets.dart';

/// Halaman utama: timeline ibadah harian berurutan waktu,
/// dari sepertiga malam hingga sebelum tidur.
/// Teks sekunder tema-aware (abu gelap di light, abu terang di dark).
Color _sec(BuildContext c) => Theme.of(c).brightness == Brightness.dark
    ? const Color(0xFFB9C7C3)
    : AppColors.textSecondary;

class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key});


  /// Waktu shalat berikutnya yang belum lewat (untuk sorot chip).
  bool _isNextPrayer(PrayerTimesResult pt, DateTime t) {
    final now = DateTime.now();
    if (!t.isAfter(now)) return false;
    return PrayerTimesResult.kOrder
        .map((e) => pt.forPrayer(e.$1))
        .whereType<DateTime>()
        .where((x) => x.isAfter(now))
        .fold<DateTime?>(null, (a, b) => a == null || b.isBefore(a) ? b : a) ==
        t;
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final today = state.currentDate;
    final pt = state.prayerTimes(today);
    final (done, total) = state.progressOf(today);
    final conditions = state.conditionsOn(today);
    final isToday = AppState.dateOnly(DateTime.now()) == today;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(formatDateLong(today)),
            Text(
              isToday ? 'Timeline ibadah hari ini' : 'Melihat tanggal lain',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w400),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Pilih tanggal',
            icon: const Icon(Icons.calendar_today_outlined, size: 20),
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: today,
                firstDate: DateTime(today.year - 1),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                state.currentDate = picked;
              }
            },
          ),
          IconButton(
            tooltip: 'Kembali ke hari ini',
            icon: const Icon(Icons.today_outlined, size: 20),
            onPressed: () => state.currentDate = DateTime.now(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {},
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          children: [
            // Header ringkasan
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Progres hari ini',
                            style: TextStyle(
                                fontSize: 12.5, color: _sec(context))),
                        const SizedBox(height: 4),
                        Text('$done dari $total aktivitas',
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: total == 0 ? 0 : done / total,
                            minHeight: 8,
                            backgroundColor: AppColors.pendingSoft,
                            color: AppColors.done,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.doneSoft,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.checklist_rounded, color: AppColors.done, size: 28),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Kondisi khusus
            if (conditions.isNotEmpty) ...[
              _ConditionBanner(conditions: conditions),
              const SizedBox(height: 12),
            ],

            // Jadwal shalat
            AppCard(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 16, color: AppColors.primary),
                      const SizedBox(width: 6),
                      const Text('Jadwal Shalat',
                          style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700)),
                      const Spacer(),
                      Text('${state.settings.cityName} · ${state.settings.calcMethod.label}',
                          style: TextStyle(fontSize: 11, color: _sec(context))),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Chip kotak — horizontal scroll.
                  SizedBox(
                    height: 60,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: PrayerTimesResult.kOrder.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (_, i) {
                        final (key, label) = PrayerTimesResult.kOrder[i];
                        final t = pt.forPrayer(key);
                        if (t == null) return const SizedBox.shrink();
                        final fmt = DateFormat(state.settings.use24h ? 'HH:mm' : 'h:mm a');
                        return _TimeChip(
                          label: label,
                          time: fmt.format(t.toLocal()),
                          highlight: _isNextPrayer(pt, t),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Jadwal dihitung lokal (perkiraan). Koreksi menit tersedia di Pengaturan → Jadwal.',
                    style: TextStyle(fontSize: 11, color: _sec(context)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Timeline
            for (final section in state.timeline(today)) ...[
              SectionHeader(
                title: section.title,
                subtitle: section.timeLabel,
              ),
              AppCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    for (var i = 0; i < section.items.length; i++) ...[
                      if (i > 0) const Divider(height: 1, indent: 16, endIndent: 16),
                      _ActivityTile(item: section.items[i], date: today),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TimeChip extends StatelessWidget {
  final String label;
  final String time;
  final bool highlight;
  const _TimeChip({required this.label, required this.time, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    // Dark mode: teks putih, bukan textPrimary gelap (tak terlihat di bg gelap).
    final ink = highlight
        ? AppColors.done
        : dark
            ? Colors.white
            : AppColors.textPrimary;
    return IntrinsicWidth(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: highlight
              ? AppColors.doneSoft
              : dark
                  ? const Color(0xFF1D2927)
                  : const Color(0xFFF3F6F4),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: highlight
                ? AppColors.done
                : dark
                    ? const Color(0xFF2E3C38)
                    : const Color(0xFFE4EAE8),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              maxLines: 1,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: ink,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              time,
              maxLines: 1,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConditionBanner extends StatelessWidget {
  final List<SpecialCondition> conditions;
  const _ConditionBanner({required this.conditions});

  @override
  Widget build(BuildContext context) {
    final labels = conditions.map((c) => c.type.label).join(' · ');
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.uzurSoft,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.medical_services_outlined, color: AppColors.uzur, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Kondisi khusus aktif: $labels',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(
                  'Shalat pada periode ini tidak dianggap terlewat. Kelola di Pengaturan → Kondisi.',
                  style: TextStyle(fontSize: 11.5, color: _sec(context)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final ActivityItem item;
  final DateTime date;
  const _ActivityTile({required this.item, required this.date});

  @override
  Widget build(BuildContext context) {
    final state = context.read<AppState>();
    final locked = state.isFuture(date);
    final dark = Theme.of(context).brightness == Brightness.dark;
    // Pending/partial: kotak ikon netral (border), bukan blok berwarna.
    final neutral = item.status == ActivityStatus.pending ||
        item.status == ActivityStatus.partial;

    final icon = switch (item.kind) {
      ActivityKind.fardhu => Icons.mosque_outlined,
      ActivityKind.sunnah => Icons.self_improvement,
      ActivityKind.dhikr => Icons.menu_book_outlined,
    };

    return InkWell(
      onTap: locked
          ? () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Tanggal mendatang belum dapat dicatat.')))
          : () => openActivitySheet(context, date, item),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: neutral ? Colors.transparent : statusSoft(item.status),
                borderRadius: BorderRadius.circular(11),
                border: neutral
                    ? Border.all(
                        color: dark
                            ? const Color(0xFF2E3C38)
                            : AppColors.divider,
                      )
                    : null,
              ),
              child: Icon(icon, size: 20, color: statusColor(item.status, Theme.of(context).brightness)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title,
                      style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(item.subtitle,
                      style: TextStyle(fontSize: 12, color: _sec(context))),
                ],
              ),
            ),
            const SizedBox(width: 8),
            StatusChip(status: item.status),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, size: 18, color: _sec(context)),
          ],
        ),
      ),
    );
  }
}

/// Buka sheet pencatatan sesuai jenis aktivitas.
Future<void> openActivitySheet(BuildContext context, DateTime date, ActivityItem item) {
  switch (item.kind) {
    case ActivityKind.fardhu:
      return showSheet(context, PrayerSheet(date: date, prayerName: item.prayerName!));
    case ActivityKind.sunnah:
      return showSheet(context, SunnahSheet(date: date, type: item.sunnahType!));
    case ActivityKind.dhikr:
      return showSheet(context,
          DhikrSheet(date: date, contentId: item.dhikrContentId!, block: item.dhikrBlock),
          isScrollControlled: true);
  }
}
