import 'package:flutter/material.dart';
import 'package:axisflow/core/constants/app_radius.dart';
import 'package:axisflow/core/constants/app_spacing.dart';
import 'package:axisflow/core/theme/app_colors.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool showBorder;
  final Color? backgroundColor;
  final BorderRadius borderRadius;
  final VoidCallback? onTap;
  final double borderWidth;
  final Color? activeBorderColor;

  const GlassCard({
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.xl),
    this.showBorder = true,
    this.backgroundColor,
    this.borderRadius = const BorderRadius.all(
      Radius.circular(AppRadius.extraLarge),
    ),
    this.onTap,
    this.borderWidth = 1,
    this.activeBorderColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBg = backgroundColor ?? AppColors.card;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: padding,
      decoration: BoxDecoration(
        color: effectiveBg,
        borderRadius: borderRadius,
        border: showBorder
            ? Border.all(
                color: activeBorderColor ?? Colors.white.withValues(alpha: 0.08),
                width: borderWidth,
              )
            : null,
      ),
      child: onTap != null
          ? InkWell(
              onTap: onTap,
              borderRadius: borderRadius,
              splashColor: Colors.white.withValues(alpha: 0.05),
              highlightColor: Colors.white.withValues(alpha: 0.03),
              child: child,
            )
          : child,
    );
  }
}
