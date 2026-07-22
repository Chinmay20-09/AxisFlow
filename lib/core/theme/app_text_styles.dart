import 'package:flutter/material.dart';

import '../constants/app_sizes.dart';
import 'app_colors.dart';

abstract class AppTextStyles {
  static TextStyle appTitle = TextStyle(
    color: AppColors.primary,
    fontSize: AppSizes.title,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle pageTitle = TextStyle(
    color: AppColors.textPrimary,
    fontSize: AppSizes.title,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle sectionTitle = TextStyle(
    color: AppColors.textPrimary,
    fontSize: AppSizes.sectionTitle,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle body = TextStyle(
    color: AppColors.textSecondary,
    fontSize: AppSizes.body,
    height: 1.6,
  );

  static final TextStyle bodyMuted = body.copyWith(
    color: AppColors.textSecondary.withValues(alpha: 0.65),
  );

  static const TextStyle statValue = TextStyle(
    color: AppColors.textPrimary,
    fontSize: AppSizes.stat,
    fontWeight: FontWeight.bold,
  );

  static TextStyle cardBadge = TextStyle(
    color: AppColors.primary,
    fontSize: AppSizes.badge,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.2,
  );

  // ── Support & Development screen styles ───────────────────────────────

  /// Large heading used for titles and amount display.
  static const TextStyle headlineLg = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 22,
    fontWeight: FontWeight.w700,
  );

  /// Large heading variant for mobile app bar titles.
  static const TextStyle headlineLgMobile = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 18,
    fontWeight: FontWeight.w700,
  );

  /// Standard body text at medium size.
  static const TextStyle bodyMd = TextStyle(
    color: AppColors.textPrimary,
    fontSize: AppSizes.body,
    height: 1.5,
  );

  /// Small label text for secondary info.
  static const TextStyle labelSm = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 11,
    letterSpacing: 1.2,
    fontWeight: FontWeight.w600,
  );

  /// Medium label text for section headings.
  static const TextStyle labelMd = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 13,
    letterSpacing: 1.0,
    fontWeight: FontWeight.w600,
  );
}
