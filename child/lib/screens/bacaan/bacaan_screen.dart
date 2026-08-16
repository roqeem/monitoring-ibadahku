import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/worship_content.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../home/sheets.dart';

/// Halaman Bacaan — daftar doa & dzikir, plus pembaca penuh.
class BacaanScreen extends StatelessWidget {
  const BacaanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final today = state.currentDate;
    final haid = state.hasCondition(today, SpecialConditionType.haid);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bacaan'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text('Bacaan untuk ${formatDateShort(today)}',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          if (haid)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                  color: AppColors.uzurSoft, borderRadius: BorderRadius.circular(12)),
              child: const Text(
                'Kondisi haid/nifas aktif: doa & dzikir tetap dapat dibaca dan dicatat.',
                style: TextStyle(fontSize: 12.5, color: AppColors.uzur),
              ),
            ),
          for (final seq in kDhikrSequences)
            _BacaanCard(seq: seq),
        ],
      ),
    );
  }
}

class _BacaanCard extends StatelessWidget {
  final DhikrSequence seq;
  const _BacaanCard({required this.seq});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final rec = state.dhikr(state.currentDate, seq.id);
    final done = rec.completed;
    final progress = rec.completedItems;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        onTap: () => showSheet(
          context,
          DhikrSheet(date: state.currentDate, contentId: seq.id),
          isScrollControlled: true,
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: done ? AppColors.doneSoft : AppColors.pendingSoft,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(
                seq.id == 'doa_bangun_tidur' || seq.id == 'doa_sebelum_tidur'
                    ? Icons.waving_hand_outlined
                    : Icons.menu_book_outlined,
                color: done ? AppColors.done : AppColors.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(seq.title,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(
                    done
                        ? 'Selesai hari ini · ${seq.items.length} bacaan'
                        : progress > 0
                            ? '$progress dari ${seq.items.length} bacaan'
                            : '${seq.items.length} bacaan · ${seq.subtitle}',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            if (done)
              const Icon(Icons.check_circle, color: AppColors.done, size: 22)
            else
              const Icon(Icons.chevron_right, color: AppColors.pending),
          ],
        ),
      ),
    );
  }
}
