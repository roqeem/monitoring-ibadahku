/// Widget bersama IbadahKu.
library;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../state/app_state.dart';
import '../theme/app_theme.dart';

/// Kartu dengan padding standar.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? color;
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final card = Card(
      color: color,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(padding: padding, child: child),
      ),
    );
    return card;
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  const SectionHeader({super.key, required this.title, this.subtitle, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 20, 4, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                if (subtitle != null)
                  Text(subtitle!,
                      style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// Chip status aktivitas.
class StatusChip extends StatelessWidget {
  final ActivityStatus status;
  final String? text;
  const StatusChip({super.key, required this.status, this.text});

  @override
  Widget build(BuildContext context) {
    final label = text ?? status.label;
    final b = Theme.of(context).brightness;
    // Pending/partial: gaya outline netral, tidak mencolok.
    final neutral = status == ActivityStatus.pending ||
        status == ActivityStatus.partial;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: neutral ? Colors.transparent : statusSoft(status),
        borderRadius: BorderRadius.circular(20),
        border: neutral
            ? Border.all(
                color: b == Brightness.dark
                    ? const Color(0xFF2E3C38)
                    : AppColors.divider,
              )
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            switch (status) {
              ActivityStatus.done => Icons.check_circle,
              ActivityStatus.pending => Icons.radio_button_unchecked,
              ActivityStatus.partial => Icons.adjust,
              ActivityStatus.missed => Icons.help,
              ActivityStatus.uzur => Icons.shield_outlined,
            },
            size: 13,
            color: statusColor(status, Theme.of(context).brightness),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: statusColor(status, Theme.of(context).brightness)),
          ),
        ],
      ),
    );
  }
}

/// Tombol aksi primer: warna aktif dan non-aktif (disabled) eksplisit.
class PrimaryButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;
  final bool busy;
  const PrimaryButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.busy = false,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !busy;
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor:
              enabled ? AppColors.primary : AppColors.primary.withValues(alpha: 0.38),
          foregroundColor:
              enabled ? Colors.white : Colors.white70,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: enabled ? onPressed : null,
        child: busy
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2))
            : Text(
                label,
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: enabled ? Colors.white : Colors.white70),
              ),
      ),
    );
  }
}

/// Pemilih chip satu pilihan.
class ChipSelect<T> extends StatelessWidget {
  final List<T> options;
  final T? selected;
  final String Function(T) labelOf;
  final ValueChanged<T> onSelected;
  final bool Function(T)? enabled;
  final IconData? Function(T)? iconOf;
  final bool wrap;
  const ChipSelect({
    super.key,
    required this.options,
    required this.selected,
    required this.labelOf,
    required this.onSelected,
    this.enabled,
    this.iconOf,
    this.wrap = true,
  });

  @override
  Widget build(BuildContext context) {
    final chips = options.map((o) {
      final isSel = o == selected;
      final ok = enabled?.call(o) ?? true;
      return ChoiceChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (iconOf != null) ...[
              Icon(iconOf!(o), size: 16,
                  color: isSel ? AppColors.done : Theme.of(context).colorScheme.onSurface),
              const SizedBox(width: 5),
            ],
            Text(labelOf(o), style: const TextStyle(fontSize: 13)),
          ],
        ),
        selected: isSel,
        onSelected: ok ? (_) => onSelected(o) : null,
        selectedColor: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF1E3A30)
            : AppColors.doneSoft,
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF1D2927)
            : null,
        labelStyle: TextStyle(
          color: isSel
              ? (Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF7FD1A8)
                  : AppColors.done)
              : Theme.of(context).colorScheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
        showCheckmark: false,
        side: BorderSide(
          color: isSel
              ? (Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF2E6B4F)
                  : AppColors.done)
              : Theme.of(context).dividerColor,
        ),
      );
    }).toList();
    return wrap
        ? Wrap(spacing: 8, runSpacing: 8, children: chips)
        : Row(children: [
            for (final c in chips) ...[c, const SizedBox(width: 8)]
          ]);
  }
}

/// Tanggal Indonesia: "Senin, 12 Agustus 2025".
String formatDateLong(DateTime d) =>
    DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(d);

String formatDateShort(DateTime d) =>
    DateFormat('d MMM yyyy', 'id_ID').format(d);

class EmptyState extends StatelessWidget {
  final String message;
  final IconData icon;
  final Widget? action;
  const EmptyState({super.key, required this.message, this.icon = Icons.inbox_outlined, this.action});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 12),
            Text(message,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 14,
                    height: 1.4)),
            if (action != null) ...[const SizedBox(height: 16), action!],
          ],
        ),
      ),
    );
  }
}

class ConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final VoidCallback onConfirm;
  final Color? confirmColor;
  const ConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.onConfirm,
    this.confirmColor,
  });

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();

  Future<void> show(BuildContext context) => showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context), child: const Text('Batal')),
            FilledButton(
              style: FilledButton.styleFrom(
                  backgroundColor: confirmColor ?? AppColors.primary),
              onPressed: () {
                Navigator.pop(context);
                onConfirm();
              },
              child: Text(confirmLabel),
            ),
          ],
        ),
      );
}

/// Bottom sheet berisi form pencatatan.
Future<void> showSheet(BuildContext context, Widget child, {bool isScrollControlled = true}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: isScrollControlled,
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: child,
    ),
  );
}

String safeDateKey(BuildContext context) => AppState.dateKey(DateTime.now());
