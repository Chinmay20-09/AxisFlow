import 'package:flutter/material.dart';
import 'package:axisflow/core/constants/app_spacing.dart';
import 'package:axisflow/core/theme/app_colors.dart';
import 'package:axisflow/core/theme/app_text_styles.dart';
import 'package:axisflow/ui/widgets/cards/glass_card.dart';

class InsightCard extends StatelessWidget {
  final String message;
  const InsightCard({required this.message, super.key});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: AppColors.primary, size: 16),
              const SizedBox(width: AppSpacing.sm),
              Text('AI INSIGHT', style: AppTextStyles.cardBadge.copyWith(color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(message, style: AppTextStyles.body.copyWith(color: AppColors.onSurface, fontSize: 20, fontWeight: FontWeight.w600, height: 1.4)),
        ],
      ),
    );
  }
}
