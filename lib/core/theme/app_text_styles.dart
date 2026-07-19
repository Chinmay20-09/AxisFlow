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
}
