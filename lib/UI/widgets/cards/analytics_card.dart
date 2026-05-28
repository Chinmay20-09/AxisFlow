import 'package:flutter/material.dart';
import 'package:axisflow/core/constants/app_sizes.dart';
import 'package:axisflow/core/constants/app_spacing.dart';
import 'package:axisflow/core/theme/app_colors.dart';
import 'package:axisflow/core/theme/app_text_styles.dart';
import 'package:axisflow/ui/widgets/cards/glass_card.dart';

class AnalyticsCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final String? trend;
  final Color? trendColor;
  final IconData? icon;
  final Color backgroundColor;
  final bool showBorder;
  final EdgeInsetsGeometry padding;

  const AnalyticsCard({
    required this.title,
    required this.value,
    this.subtitle,
    this.trend,
    this.trendColor,
    this.icon,
    this.backgroundColor = const Color(0x0AFFFFFF),
    this.showBorder = false,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      backgroundColor: backgroundColor,
      showBorder: showBorder,
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null)
            Row(
              children: [
                Icon(icon, color: AppColors.primary, size: AppSizes.iconLarge),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            )
          else
            Text(
              title,
              style: AppTextStyles.body.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          const SizedBox(height: AppSpacing.sm),
          Text(value, style: AppTextStyles.statValue),
          if (subtitle != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(subtitle!, style: AppTextStyles.bodyMuted),
          ],
          if (trend != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              trend!,
              style: AppTextStyles.body.copyWith(
                color: trendColor ?? AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
