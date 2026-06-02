// lib/ui/widgets/transaction_tile.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:axisflow/data/models/transaction_model.dart';
import 'package:axisflow/core/theme/app_theme.dart';
import 'package:axisflow/core/formatters.dart';
import 'package:axisflow/core/constants/app_sizes.dart';
import 'package:axisflow/core/constants/app_spacing.dart';
import 'package:axisflow/core/constants/app_radius.dart';
import 'package:axisflow/core/theme/app_text_styles.dart';
import 'package:axisflow/ui/screens/categories.dart';

class TransactionTile extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback? onLongPress;

  const TransactionTile({
    super.key,
    required this.transaction,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.typeColor(transaction.type);

    return GestureDetector(
      onLongPress: onLongPress,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(AppRadius.large),
          border: Border.all(color: AppTheme.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.large),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.large),
            // Presentation-only: actions are lifted to the parent via callbacks
            onTap: null,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.tileVertical,
              ),
              child: Row(
                children: [
                  Container(
                    width: AppSizes.tileAvatar,
                    height: AppSizes.tileAvatar,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        _typeIcon(transaction.type),
                        style: TextStyle(
                          color: color,
                          fontSize: AppSizes.tileIcon,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          transaction.note.isEmpty
                              ? getCategoryDisplay(transaction.category)
                              : transaction.note,
                          style: AppTextStyles.sectionTitle.copyWith(
                            fontSize: 15,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _chip(
                                getCategoryDisplay(transaction.category),
                                AppTheme.textSecondary,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              _chip(transaction.typeLabel, color),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Flexible(
                          child: Text(
                            DateFormat(
                              'dd MMM • hh:mm a',
                            ).format(transaction.createdAt),
                            style: AppTextStyles.body.copyWith(
                              fontSize: AppSizes.badge,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${transaction.isExpense ? '-' : '+'}${formatCompactCurrency(transaction.amount)}',
                        style: AppTextStyles.statValue.copyWith(
                          color: color,
                          fontSize: AppSizes.stat,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _chip(String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(AppRadius.small),
    ),
    child: Text(
      label,
      style: AppTextStyles.body.copyWith(
        color: color,
        fontSize: AppSizes.badge,
        fontWeight: FontWeight.w700,
      ),
      overflow: TextOverflow.ellipsis,
    ),
  );

  String _typeIcon(TransactionType type) {
    switch (type) {
      case TransactionType.income:
        return '↓';
      case TransactionType.expense:
        return '↑';
    }
  }
}
