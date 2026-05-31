import 'package:flutter/material.dart';
import 'package:axisflow/controller/transaction_controller.dart';
import 'package:axisflow/core/constants/app_spacing.dart';
import 'package:axisflow/core/theme/app_text_styles.dart';
import 'package:axisflow/core/theme/app_colors.dart';
import 'package:axisflow/ui/widgets/navigation/menu_button.dart';

class HomeHeader extends StatelessWidget {
  final TransactionController controller;
  final GlobalKey<ScaffoldState> scaffoldKey;

  const HomeHeader({
    required this.controller,
    required this.scaffoldKey,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            MenuButton(scaffoldKey: scaffoldKey, controller: controller),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'AxisFlow',
              style: AppTextStyles.sectionTitle.copyWith(
                color: AppColors.primary,
                fontSize: 24,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
