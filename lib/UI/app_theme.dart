// lib/ui/app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  // Colors
  static const Color bg = Color(0xFF0F0F14);
  static const Color surface = Color(0xFF1A1A24);
  static const Color surfaceAlt = Color(0xFF22222F);
  static const Color income = Color(0xFF4ADE80);     // green
  static const Color expense = Color(0xFFF87171);    // red
  static const Color pending = Color(0xFFFBBF24); // amber
  static const Color textPrimary = Color(0xFFF1F1F5);
  static const Color textSecondary = Color(0xFF8888AA);
  static const Color border = Color(0xFF2A2A3A);

  static ThemeData get theme => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: bg,
    colorScheme: const ColorScheme.dark(
      primary: income,
      surface: surface,
      error: expense,
    ),
    fontFamily: 'Courier', // monospace feel — clean and numeric
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w700, letterSpacing: -1),
      bodyLarge: TextStyle(color: textPrimary, fontSize: 15),
      bodyMedium: TextStyle(color: textSecondary, fontSize: 13),
      labelSmall: TextStyle(color: textSecondary, fontSize: 11, letterSpacing: 1.2),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceAlt,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: income, width: 1.5),
      ),
      labelStyle: const TextStyle(color: textSecondary),
      hintStyle: const TextStyle(color: Color(0xFF555566)),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: bg,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      ),
      iconTheme: IconThemeData(color: textSecondary),
    ),
  );

  static Color typeColor(dynamic type) {
    switch (type.toString()) {
      case 'TransactionType.income': return income;
      case 'TransactionType.expense': return expense;
      case 'TransactionType.pending': return pending;
      default: return textSecondary;
    }
  }
}