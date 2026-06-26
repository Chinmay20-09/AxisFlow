import 'package:flutter/material.dart';

abstract class AppColors {
  // Semantic color roles (new)
  static const Color background = Color(0xFF05070A);
  static const Color surface = Color(0xFF111417);
  static const Color card = Color(0x1AFFFFFF);

  // Text roles
  static const Color textPrimary = Color(0xFFE1E2E7);
  static const Color textSecondary = Color(0xFF8888AA);
  static const Color textMuted = Color(0xFF8B8FA8);

  // Financial / semantic accents
  static const Color income = Color(
    0xFF6BFB9A,
  ); // maps to accentGreen / primary
  static const Color expense = Color(0xFFFF6B6B); // maps to accentRed

  // Feedback roles
  static const Color success = Color(0xFF6BFB9A);
  static const Color warning = Color(0xFFFBBF24);
  static const Color error = Color(0xFFFFB4AB);

  // --- Legacy / palette entries (kept for compatibility) ---
  static const Color surfaceBackground = Color(0xFF0F0F14);
  static const Color surfaceContainerHigh = Color(0xFF22222F);
  static const Color surfaceContainerHighest = Color(0xFF22222F);
  static const Color primary = Color(0xFF6BFB9A);
  static const Color secondary = Color.fromARGB(255, 251, 14, 14);
  static const Color onSurface = Color(0xFFF1F1F5);
  static const Color onSurfaceVariant = Color(0xFF8888AA);
  static const Color accent = Color(0xFFFFFFFF);
  static const Color amber = Color(0xFFFBBF24);
  static const Color secondaryContainer = Color(0xFF464950);
  static const Color surfaceContainer = Color(0xFF1D2023);
  static const Color accentGreen = Color(0xFF6BFB9A);
  static const Color accentBlue = Color(0xFF7DD3FC);
  static const Color accentPurple = Color(0xFFB794F4);
  static const Color accentAmber = Color(0xFFFBBF24);
  static const Color onPrimary = Color(0xFF003919);
  static const Color outline = Color(0xFF869486);
  static const Color primaryContainer = Color(0xFF4ADE80);
  static const Color errorContainer = Color(0xFF93000A);
  static const Color surfaceContainerLow = Color(0xFF191C1F);
  static const Color outlineVariant = Color(0xFF3D4A3E);
  static const Color muted = Color(0xFF8B8FA8);
  static const Color label = Color(0xFFE4E6F0);
  static const Color accentRed = Color(0xFFFF6B6B);
  static const Color border = Color(0xFF2A2C38);
  static const Color black = Color(0xFF0F1114);
}
