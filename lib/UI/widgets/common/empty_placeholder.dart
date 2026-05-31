import 'package:flutter/material.dart';
import 'package:axisflow/core/theme/app_colors.dart';

class EmptyPlaceholder extends StatelessWidget {
  final String message;

  const EmptyPlaceholder({this.message = 'Nothing to show', super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
          style: BorderStyle.solid,
        ),
      ),
      child: Center(
        child: Opacity(
          opacity: 0.4,
          child: Text(
            message,
            style: const TextStyle(
              color: AppColors.onSurfaceVariant,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
