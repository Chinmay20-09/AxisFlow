import 'package:flutter/material.dart';
import 'package:axisflow/core/theme/app_colors.dart';

// ── Planner Footer ─────────────────────────────────────────────────────────────
class PlannerFooter extends StatelessWidget {
  final VoidCallback onReset;
  final VoidCallback onSave;

  const PlannerFooter({
    super.key,
    required this.onReset,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      padding: EdgeInsets.only(
        left: 8,
        right: 8,
        bottom: MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer.withValues(alpha: 0.95),
        border: Border(
          top: BorderSide(
            color: Colors.white.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: OutlinedButton(
              onPressed: onReset,
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: Colors.white.withValues(alpha: 0.2),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                minimumSize: const Size.fromHeight(48),
              ),
              child: const Text(
                'Reset',
                style: TextStyle(
                  color: AppColors.onSurface,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: onSave, 
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                elevation: 0,
                shadowColor: AppColors.primary.withValues(alpha: 0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                minimumSize: const Size.fromHeight(48),
              ),
              child: const Text(
                'Save Budget',
                style: TextStyle(
                  color: AppColors.onPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
