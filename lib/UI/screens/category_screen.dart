// lib/ui/screens/category_screen.dart
import 'package:flutter/material.dart';
import '../../controller/transaction_controller.dart';
import '../../data/transaction_model.dart';
import '../app_theme.dart';
import '../widgets/transaction_tile.dart';
import 'add_transaction_sheet.dart';

class CategoryScreen extends StatelessWidget {
  final TransactionController controller;
  const CategoryScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final grouped = controller.byCategory;
        final categories = grouped.keys.toList()..sort();

        return Scaffold(
          backgroundColor: AppTheme.bg,
          appBar: AppBar(title: const Text('BY CATEGORY')),
          body: categories.isEmpty
              ? const Center(child: Text('No transactions', style: TextStyle(color: AppTheme.textSecondary)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: categories.length,
                  itemBuilder: (context, i) {
                    final cat = categories[i];
                    final items = grouped[cat]!;
                    final total = items.fold(0.0, (s, t) {
                      return s + (t.type == TransactionType.expense ? -t.amount : t.amount);
                    });
                    return _CategorySection(
                      category: cat,
                      transactions: items,
                      total: total,
                      controller: controller,
                    );
                  },
                ),
        );
      },
    );
  }
}

class _CategorySection extends StatefulWidget {
  final String category;
  final List<Transaction> transactions;
  final double total;
  final TransactionController controller;

  const _CategorySection({
    required this.category,
    required this.transactions,
    required this.total,
    required this.controller,
  });

  @override
  State<_CategorySection> createState() => _CategorySectionState();
}

class _CategorySectionState extends State<_CategorySection> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppTheme.surfaceAlt,
                borderRadius: BorderRadius.vertical(
                  top: const Radius.circular(14),
                  bottom: _expanded ? Radius.zero : const Radius.circular(14),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    widget.category,
                    style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.border,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${widget.transactions.length}',
                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${widget.total >= 0 ? '+' : ''}₹${widget.total.abs().toStringAsFixed(0)}',
                    style: TextStyle(
                      color: widget.total >= 0 ? AppTheme.income : AppTheme.expense,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    _expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: AppTheme.textSecondary,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: widget.transactions.map((t) => TransactionTile(
                  transaction: t,
                  onEdit: t.isEditable ? () => _showEdit(context, t) : null,
                  onDelete: t.isEditable ? () => widget.controller.delete(t.id) : null,
                )).toList(),
              ),
            ),
        ],
      ),
    );
  }

  void _showEdit(BuildContext context, Transaction t) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddTransactionSheet(controller: widget.controller, existing: t),
    );
  }
}
