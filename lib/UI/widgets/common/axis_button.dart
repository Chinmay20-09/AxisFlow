import 'package:flutter/material.dart';
import 'package:axisflow/core/constants/app_radius.dart';
import 'package:axisflow/core/constants/app_sizes.dart';
import 'package:axisflow/core/constants/app_spacing.dart';
import 'package:axisflow/core/theme/app_colors.dart';
import 'package:axisflow/core/theme/app_text_styles.dart';

enum AxisButtonVariant { primary, secondary }

class AxisButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AxisButtonVariant variant;
  final bool isLoading;
  final IconData? icon;

  const AxisButton.primary({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    super.key,
  }) : variant = AxisButtonVariant.primary;

  const AxisButton.secondary({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    super.key,
  }) : variant = AxisButtonVariant.secondary;

  @override
  Widget build(BuildContext context) {
    final bool disabled = onPressed == null || isLoading;
    final Color background = variant == AxisButtonVariant.primary
        ? AppColors.primary
        : Colors.transparent;
    final Color foreground = variant == AxisButtonVariant.primary
        ? AppColors.onSurface
        : AppColors.primary;
    final BorderSide borderSide = variant == AxisButtonVariant.secondary
        ? BorderSide(color: AppColors.primary.withValues(alpha: 0.18))
        : BorderSide.none;

    return ElevatedButton(
      onPressed: disabled ? null : onPressed,
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: background,
        foregroundColor: foreground,
        side: borderSide,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLoading) ...[
            const SizedBox(
              width: AppSpacing.sm,
              height: AppSpacing.sm,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.onSurface),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
          if (icon != null) ...[
            Icon(icon, size: AppSizes.iconSmall),
            const SizedBox(width: AppSpacing.sm),
          ],
          Text(
            label,
            style: AppTextStyles.body.copyWith(
              color: foreground,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
