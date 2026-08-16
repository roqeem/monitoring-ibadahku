import 'package:flutter/material.dart';

const Color kPrimary = Color(0xFF15825C);
const Color kPrimaryLight = Color(0xFF2DAA7B);
const Color kAccent = Color(0xFF1E6DFF);
const Color kTextPrimary = Color(0xFF1A1A1A);
const Color kTextSecondary = Color(0xFF757575);
const Color kDone = Color(0xFF2E7D32);
const Color kPending = Color(0xFFF9A825);
const Color kMissed = Color(0xFFC62828);

ThemeData buildLightTheme() {
  final base = ThemeData(
    brightness: Brightness.light,
    primaryColor: kPrimary,
    scaffoldBackgroundColor: const Color(0xFFF8F9FA),
    fontFamily: 'Inter',
    useMaterial3: true,
  );
  return base.copyWith(
    colorScheme: ColorScheme.light(
      primary: kPrimary,
      secondary: kAccent,
      surface: Colors.white,
      error: kMissed,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: kTextPrimary,
    ),
  );
}

ThemeData buildDarkTheme() {
  final base = ThemeData(
    brightness: Brightness.dark,
    primaryColor: kPrimary,
    useMaterial3: true,
  );
  return base.copyWith(
    colorScheme: ColorScheme.dark(
      primary: kPrimary,
      secondary: kAccent,
      surface: const Color(0xFF1A1A1A),
      error: kMissed,
    ),
  );
}
