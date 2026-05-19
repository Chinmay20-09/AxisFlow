import 'package:flutter/material.dart';
import 'package:transaction/core/constants/app_spacing.dart';
import 'package:transaction/core/theme/app_text_styles.dart';
import 'package:transaction/ui/widgets/common/axis_button.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? actionText;
  final VoidCallback? onAction;
  final Widget? trailing;

  const SectionHeader({
    required this.title,
    this.subtitle,
    this.actionText,
    this.onAction,
    this.trailing,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final Widget? action = trailing ??
        (actionText != null
            ? AxisButton.secondary(
                label: actionText!,
                onPressed: onAction,
              )
            : null);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.sectionTitle),
              if (subtitle != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(subtitle!, style: AppTextStyles.bodyMuted),
              ],
            ],
          ),
        ),
        ?action,
      ],
    );
  }
}
