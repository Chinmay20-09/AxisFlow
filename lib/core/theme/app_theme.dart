// lib/ui/app_theme.dart

import 'package:flutter/material.dart';

class AppTheme {
  // =========================
  // CORE COLORS
  // =========================
  static const Color accent = Color(0xFFFFFFFF);

  static const Color bg = Color(0xFF0F0F14);

  static const Color surface = Color(0xFF1A1A24);

  static const Color surfaceAlt = Color(0xFF22222F);

  static const Color surfaceGlass = Color(0x1AFFFFFF);

  static const Color border = Color(0xFF2A2A3A);

  static const Color borderSoft = Color(0x14FFFFFF);

  // =========================
  // SEMANTIC COLORS
  // =========================

  static const Color income = Color(0xFF4ADE80);

  static const Color expense = Color(0xFFF87171);

  static const Color pending = Color(0xFFFBBF24);

  static Color primary = income;

  // =========================
  // TEXT COLORS
  // =========================

  static const Color textPrimary = Color(0xFFF1F1F5);

  static const Color textSecondary = Color(0xFF8888AA);

  static const Color textMuted = Color(0xFF555566);

  // =========================
  // RADII
  // =========================

  static const double radiusSmall = 10;

  static const double radiusMedium = 18;

  static const double radiusLarge = 24;

  // =========================
  // PADDING
  // =========================

  static const double screenPadding = 20;

  static const double cardPadding = 20;

  static const double sectionGap = 32;
  static const Color background = bg;

  static const Color onPrimary = bg;

  static const Color onSurface = textPrimary;

  static const Color onSurfaceVariant = textSecondary;

  static const Color surfaceContainerHigh = surfaceAlt;

  static const Color surfaceContainerHighest = surfaceAlt;

  // =========================
  // GLASS DECORATION
  // =========================

  static BoxDecoration glassCard = BoxDecoration(
    color: surfaceGlass,
    borderRadius: BorderRadius.circular(radiusLarge),
    border: Border.all(color: borderSoft),
  );

  // =========================
  // THEME
  // =========================

  static ThemeData theme(Color primary) => ThemeData(
    brightness: Brightness.dark,

    scaffoldBackgroundColor: bg,

    fontFamily: 'Inter',

    splashFactory: NoSplash.splashFactory,

    colorScheme: ColorScheme.dark(
      primary: primary,
      surface: surface,
      error: expense,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: bg,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
      iconTheme: IconThemeData(color: textSecondary),
    ),

    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primary,
      foregroundColor: bg,
    ),

    textTheme: const TextTheme(
      displayLarge: TextStyle(
        color: textPrimary,
        fontSize: 40,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.5,
      ),

      headlineLarge: TextStyle(
        color: textPrimary,
        fontSize: 32,
        fontWeight: FontWeight.w700,
      ),

      titleLarge: TextStyle(
        color: textPrimary,
        fontSize: 22,
        fontWeight: FontWeight.w600,
      ),

      bodyLarge: TextStyle(color: textPrimary, fontSize: 15),

      bodyMedium: TextStyle(color: textSecondary, fontSize: 13),

      labelSmall: TextStyle(
        color: textSecondary,
        fontSize: 11,
        letterSpacing: 1.2,
        fontWeight: FontWeight.w600,
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,

      fillColor: surfaceAlt,

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusSmall),
        borderSide: const BorderSide(color: border),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusSmall),
        borderSide: const BorderSide(color: border),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusSmall),
        borderSide: BorderSide(color: primary, width: 1.5),
      ),

      labelStyle: const TextStyle(color: textSecondary),

      hintStyle: const TextStyle(color: textMuted),
    ),
  );

  // =========================
  // HELPERS
  // =========================

  static Color typeColor(dynamic type) {
    switch (type.toString()) {
      case 'TransactionType.income':
        return income;

      case 'TransactionType.expense':
        return expense;

      case 'TransactionType.pending':
        return pending;

      default:
        return textSecondary;
    }
  }
}
