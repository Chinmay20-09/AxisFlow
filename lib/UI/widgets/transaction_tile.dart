// lib/ui/widgets/transaction_tile.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/transaction_model.dart';
import '../app_theme.dart';

class TransactionTile extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const TransactionTile({
    super.key,
    required this.transaction,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.typeColor(transaction.type);
    final canEdit = transaction.isEditable;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
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
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: canEdit ? onEdit : null,
          onLongPress: canEdit ? onDelete : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      _typeIcon(transaction.type),
                      style: TextStyle(color: color, fontSize: 20),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        transaction.note.isEmpty
                            ? transaction.category
                            : transaction.note,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          spacing: 8,
                          children: [
                            _chip(transaction.category, AppTheme.textSecondary),
                            _chip(transaction.typeLabel, color),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Flexible(
                        child: Text(
                          DateFormat(
                            'dd MMM • hh:mm a',
                          ).format(transaction.createdAt),
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 11,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${transaction.isExpense ? '-' : '+'}₹${_fmt(transaction.amount)}',
                      style: TextStyle(
                        color: color,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    if (canEdit)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _iconBtn(
                            Icons.edit_outlined,
                            AppTheme.textSecondary,
                            onEdit,
                          ),
                          _iconBtn(
                            Icons.delete_outline,
                            AppTheme.expense,
                            onDelete,
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        )
      )
    );
  }

  Widget _chip(String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(
      label,
      style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700),
      overflow: TextOverflow.ellipsis,
    ),
  );

  Widget _iconBtn(IconData icon, Color color, VoidCallback? onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Tooltip(
          message: icon == Icons.delete_outline ? 'Delete' : 'Edit',
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Icon(icon, size: 18, color: color),
          ),
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

  String _fmt(double val) {
    if (val >= 10000000) {
      return '${(val / 10000000).toStringAsFixed(1)}Cr';
    } else if (val >= 100000) {
      return '${(val / 100000).toStringAsFixed(1)}L';
    } else if (val >= 1000) {
      return '${(val / 1000).toStringAsFixed(1)}k';
    } else {
      return val.toStringAsFixed(0);
    }
  }
}
