import 'package:flutter/material.dart';

abstract final class StoreColors {
  static const ink = Color(0xFF202D2B);
  static const muted = Color(0xFF6D7B77);
  static const accent = Color(0xFF087F71);
  static const canvas = Color(0xFFF6F8F7);
  static const accentSoft = Color(0xFFEAF4F0);
  static const border = Color(0xFFE2E9E6);
}

ThemeData createTheme() => ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: StoreColors.accent,
    brightness: Brightness.light,
    surface: Colors.white,
  ),
  scaffoldBackgroundColor: StoreColors.canvas,
  textTheme: const TextTheme(
    headlineLarge: TextStyle(
      fontSize: 40,
      fontWeight: FontWeight.w800,
      letterSpacing: -1.4,
      color: StoreColors.ink,
    ),
    titleLarge: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w700,
      color: StoreColors.ink,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: StoreColors.ink,
    ),
    bodyMedium: TextStyle(fontSize: 14, height: 1.45, color: StoreColors.ink),
    bodySmall: TextStyle(fontSize: 12, height: 1.4, color: StoreColors.muted),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: StoreColors.canvas,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: StoreColors.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: StoreColors.accent, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFFBA1A1A)),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFFBA1A1A), width: 2),
    ),
  ),
  chipTheme: ChipThemeData(
    backgroundColor: Colors.white,
    selectedColor: StoreColors.accentSoft,
    side: const BorderSide(color: StoreColors.border),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    labelStyle: const TextStyle(fontSize: 13, color: StoreColors.ink),
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      minimumSize: const Size(48, 48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: StoreColors.accent,
      minimumSize: const Size(48, 48),
      side: const BorderSide(color: StoreColors.border),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  ),
);
