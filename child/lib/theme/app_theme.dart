/// Tema IbadahKu — hijau tua / biru kehijauan, tenang, tidak menghakimi.
library;

import 'package:flutter/material.dart';

import '../state/app_state.dart' show ActivityStatus;

class AppColors {
  static const primary = Color(0xFF0F5C4C); // hijau tua
  static const primaryLight = Color(0xFF1A7A66);
  static const surface = Color(0xFFF7FAF8);
  static const card = Color(0xFFFFFFFF);
  static const done = Color(0xFF2E7D5B);
  static const doneSoft = Color(0xFFE3F2EC);
  static const pending = Color(0xFF8A9492);
  static const pendingSoft = Color(0xFFEDF1F0);
  static const missed = Color(0xFFB0874B); // kuning lembut, hindari merah
  static const missedSoft = Color(0xFFF7EFE0);
  static const uzur = Color(0xFF5C7C99);
  static const uzurSoft = Color(0xFFE8EFF5);
  static const accent = Color(0xFFD9A441); // aksen emas lembut
  static const textPrimary = Color(0xFF1C2B28);
  static const textSecondary = Color(0xFF5B6B67);
  static const divider = Color(0xFFE4EAE8);
}

ThemeData buildLightTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    brightness: Brightness.light,
    surface: AppColors.surface,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.surface,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.card,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.divider),
      ),
      margin: EdgeInsets.zero,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.card,
      indicatorColor: AppColors.doneSoft,
      labelTextStyle: WidgetStatePropertyAll(
        TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.card,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.divider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    ),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      side: const BorderSide(color: AppColors.divider),
      backgroundColor: AppColors.card,
      labelStyle: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500),
    ),
    dividerTheme: const DividerThemeData(color: AppColors.divider, thickness: 1),
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
  );
}

ThemeData buildDarkTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    brightness: Brightness.dark,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: const Color(0xFF101817),
    cardTheme: CardThemeData(
      color: const Color(0xFF182322),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFF26332F)),
      ),
      margin: EdgeInsets.zero,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFF101817),
      foregroundColor: Colors.white,
      elevation: 0,
      titleTextStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: const Color(0xFF182322),
      indicatorColor: const Color(0xFF2E7D5B),
      labelTextStyle: WidgetStatePropertyAll(
        TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white70),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF1D2927),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF2E3C38)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF2E3C38)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primaryLight, width: 1.6),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    ),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      side: const BorderSide(color: Color(0xFF2E3C38)),
      backgroundColor: const Color(0xFF1D2927),
      labelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
    ),
    dividerTheme: const DividerThemeData(color: Color(0xFF26332F), thickness: 1),
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
  );
}

/// Warna indikator status aktivitas (tema-aware via brightness).
Color statusColor(ActivityStatus status, Brightness b) => switch (status) {
      ActivityStatus.done => AppColors.done,
      ActivityStatus.pending => b == Brightness.dark ? Colors.white38 : AppColors.pending,
      ActivityStatus.partial => b == Brightness.dark ? Colors.white70 : AppColors.textSecondary,
      ActivityStatus.missed => AppColors.missed,
      ActivityStatus.uzur => AppColors.uzur,
    };

Color statusSoft(ActivityStatus status) => switch (status) {
      ActivityStatus.done => AppColors.doneSoft,
      ActivityStatus.pending => AppColors.pendingSoft,
      ActivityStatus.partial => AppColors.pendingSoft,
      ActivityStatus.missed => AppColors.missedSoft,
      ActivityStatus.uzur => AppColors.uzurSoft,
    };
