import 'package:flutter/material.dart';
import 'package:axisflow/core/theme/app_colors.dart';
import 'package:axisflow/ui/widgets/cards/glass_card.dart';

// ── Planner Summary Card ───────────────────────────────────────────────────────
class PlannerSummaryCard extends StatelessWidget {
  final TextEditingController incomeController;
  final double allocated;
  final double remaining;
  final ValueChanged<String> onIncomeChanged;

  const PlannerSummaryCard({
    super.key,
    required this.incomeController,
    required this.allocated,
    required this.remaining,
    required this.onIncomeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Monthly Budget label
          const Text(
            'Monthly Budget',
            style: TextStyle(
              color: AppColors.onSurfaceVariant,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 4),
          // Income input row
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary.withValues(alpha: 0.4),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: incomeController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(
                    color: AppColors.onSurface,
                    fontSize: 36,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.72,
                  ),
                  onChanged: onIncomeChanged,
                  decoration: InputDecoration(
                    hintText: 'Enter monthly income',
                    hintStyle: TextStyle(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 36,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.72,
                    ),
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.primary),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Allocated / Remaining row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Allocated',
                    style: TextStyle(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${allocated.round()}%',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Remaining',
                    style: TextStyle(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${remaining.round()}%',
                    style: const TextStyle(
                      color: AppColors.onSurface,
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),            const SizedBox(height: 8),
          // Animated progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: SizedBox(
              height: 6,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                  Positioned.fill(
                    child: TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOut,
                      tween: Tween(
                        begin: 0,
                        end: (allocated / 100).clamp(0, 1),
                      ),
                      builder: (context, widthFactor, child) {
                        return Align(
                          alignment: Alignment.centerLeft,
                          child: FractionallySizedBox(
                            widthFactor: widthFactor,
                            heightFactor: 1,
                            child: child,
                          ),
                        );
                      },
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 15,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
