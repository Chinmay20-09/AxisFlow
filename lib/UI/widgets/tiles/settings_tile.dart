import 'package:flutter/material.dart';
import 'package:transaction/core/constants/app_radius.dart';
import 'package:transaction/core/constants/app_spacing.dart';
import 'package:transaction/core/theme/app_colors.dart';
import 'package:transaction/core/theme/app_text_styles.dart';

class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Icon(icon, color: AppColors.primary),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.sectionTitle.copyWith(fontSize: 16)),
                    if (subtitle != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(subtitle!, style: AppTextStyles.body.copyWith(color: AppColors.onSurfaceVariant.withValues(alpha: 0.75))),
                    ],
                  ],
                ),
              ),
             trailing!,
            ],
          ),
        ),
      ),
    );
  }
}
