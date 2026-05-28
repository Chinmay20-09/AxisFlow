import 'package:flutter/material.dart';
import 'package:axisflow/core/constants/app_radius.dart';
import 'package:axisflow/core/constants/app_spacing.dart';
import 'package:axisflow/core/theme/app_colors.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool showBorder;
  final Color backgroundColor;
  final BorderRadiusGeometry borderRadius;

  const GlassCard({
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.xl),
    this.showBorder = true,
    this.backgroundColor = AppColors.card,
    this.borderRadius = const BorderRadius.all(
      Radius.circular(AppRadius.extraLarge),
    ),
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius,
        border: showBorder
            ? Border.all(color: Colors.white.withValues(alpha: 0.08))
            : null,
      ),
      child: child,
    );
  }
}
