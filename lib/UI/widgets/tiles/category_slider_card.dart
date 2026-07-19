import 'package:flutter/material.dart';
import 'package:axisflow/core/theme/app_colors.dart';
import 'package:axisflow/ui/screens/budgets/budget_models.dart';

// ── Category Slider Card ────────────────────────────────────────────────────────
class CategorySliderCard extends StatelessWidget {
  final CategoryBudget category;
  final double monthlyIncome;
  final ValueChanged<double> onChanged;

  const CategorySliderCard({
    super.key,
    required this.category,
    required this.monthlyIncome,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final amount = monthlyIncome * category.percent / 100;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        children: [
          // ── Header row ────────────────────────────────────────────────
          Row(
            children: [
              // Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: category.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  category.icon,
                  color: category.color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              // Name
              Expanded(
                child: Text(
                  category.name,
                  style: const TextStyle(
                    color: AppColors.onSurface,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              // Percentage
              Text(
                '${category.percent.round()}%',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 12),
              // Amount
              Text(
                '\$${amount.toStringAsFixed(0)}',
                style: TextStyle(
                  color: AppColors.onSurfaceVariant.withValues(alpha: 0.8),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // ── Slider ─────────────────────────────────────────────────────
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: Colors.white.withValues(alpha: 0.08),
              trackHeight: 4,
              thumbColor: AppColors.primary,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              overlayColor: AppColors.primary.withValues(alpha: 0.12),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
            ),
            child: Slider(
              value: category.percent,
              min: 0,
              max: 100,
              divisions: 100,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
