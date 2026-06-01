// lib/ui/widgets/cards/ai_insight_card.dart
import 'package:flutter/material.dart';
import 'package:axisflow/core/theme/app_text_styles.dart';
import 'package:axisflow/core/constants/app_spacing.dart';
import 'package:axisflow/core/theme/app_colors.dart';
import 'package:axisflow/core/constants/app_radius.dart';

class AiInsightCard extends StatelessWidget {
  final String message;
  final VoidCallback? onTap;

  const AiInsightCard({required this.message, this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.extraLarge),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.extraLarge),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Expanded(child: Text(message, style: AppTextStyles.body)),
              const SizedBox(width: AppSpacing.md),
              Icon(Icons.auto_awesome, color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }
}
