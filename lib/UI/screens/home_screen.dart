// lib/ui/screens/home_screen.dart
import 'package:flutter/material.dart';
import '../../controller/transaction_controller.dart';
import '../../data/transaction_model.dart';
import '../app_theme.dart';
import '../widgets/summary_card.dart';
import '../widgets/barchart.dart';
import '../widgets/transaction_tile.dart';
import 'add_transaction_sheet.dart';
import 'category_screen.dart';
import '../widgets/linechart.dart';

enum _ChartType { line, bar }

class HomeScreen extends StatefulWidget {
  final TransactionController controller;
  const HomeScreen({super.key, required this.controller});


  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TransactionType? _filterType;
  _ChartType _chartType = _ChartType.line;

  List<Transaction> _filteredTransactions(List<Transaction> txns) {
    if (_filterType == null) return txns;
    return txns.where((t) => t.type == _filterType).toList();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final txns = widget.controller.transactions;
        final visibleTxns = _filteredTransactions(txns);
        return Scaffold(
          backgroundColor: AppTheme.bg,
          appBar: AppBar(
            title: const Text('AxisFlow'),
            actions: [
              IconButton(
                icon: const Icon(Icons.grid_view_rounded),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        CategoryScreen(controller: widget.controller),
                  ),
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SummaryCard(
                  income: widget.controller.totalincome,
                  expense: widget.controller.totalexpense,
                  pending: widget.controller.totalPending,
                  net: widget.controller.net,
                ),
                const SizedBox(height: 12),
                _chartToggle(),
                const SizedBox(height: 18),
                _chartType == _ChartType.line
                    ? linechart(data: widget.controller.weeklyData)
                    : barchart(data: widget.controller.weeklyData),
                const SizedBox(height: 18),
                _filterChips(txns),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'TRANSACTIONS',
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 11,
                                letterSpacing: 1.4,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Text(
                            '${visibleTxns.length} of ${txns.length} entries',
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      if (txns.isEmpty)
                        Column(
                          children: [
                            _emptyState(),
                            const SizedBox(height: 14),
                            TextButton.icon(
                              onPressed: _showAdd,
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text('Add first transaction'),
                              style: TextButton.styleFrom(
                                foregroundColor: AppTheme.income,
                                backgroundColor: AppTheme.surfaceAlt,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ],
                        )
                      else
                        Column(
                          children: visibleTxns
                              .map(
                                (t) => TransactionTile(
                                  transaction: t,
                                  onEdit: t.isEditable
                                      ? () => _showEdit(t)
                                      : null,
                                  onDelete: t.isEditable
                                      ? () => _confirmDelete(t.id)
                                      : null,
                                ),
                              )
                              .toList(),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _showAdd,
            backgroundColor: AppTheme.income,
            foregroundColor: AppTheme.bg,
            icon: const Icon(Icons.add),
            label: const Text(
              'ADD',
              style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1),
            ),
          ),
        );
      },
    );
  }

  Widget _emptyState() => Container(
    padding: const EdgeInsets.symmetric(vertical: 48),
    alignment: Alignment.center,
    child: Column(
      children: [
        const Text('₹', style: TextStyle(fontSize: 48, color: AppTheme.border)),
        const SizedBox(height: 12),
        const Text(
          'No transactions yet',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 6),
        Text(
          'Tap + ADD to get started',
          style: TextStyle(
            color: AppTheme.textSecondary.withValues(alpha: 0.5),
            fontSize: 12,
          ),
        ),
      ],
    ),
  );

  Widget _chartToggle() {
    return Row(
      children: [
        ChoiceChip(
          label: const Text('Line Chart'),
          selected: _chartType == _ChartType.line,
          selectedColor: AppTheme.surfaceAlt,
          backgroundColor: AppTheme.surface,
          labelStyle: TextStyle(
            color: _chartType == _ChartType.line ? AppTheme.textPrimary : AppTheme.textSecondary,
            fontWeight: _chartType == _ChartType.line ? FontWeight.w700 : FontWeight.w500,
          ),
          side: BorderSide(color: _chartType == _ChartType.line ? AppTheme.income : AppTheme.border),
          onSelected: (_) => setState(() => _chartType = _ChartType.line),
        ),
        const SizedBox(width: 10),
        ChoiceChip(
          label: const Text('Bar Chart'),
          selected: _chartType == _ChartType.bar,
          selectedColor: AppTheme.surfaceAlt,
          backgroundColor: AppTheme.surface,
          labelStyle: TextStyle(
            color: _chartType == _ChartType.bar ? AppTheme.textPrimary : AppTheme.textSecondary,
            fontWeight: _chartType == _ChartType.bar ? FontWeight.w700 : FontWeight.w500,
          ),
          side: BorderSide(color: _chartType == _ChartType.bar ? AppTheme.income : AppTheme.border),
          onSelected: (_) => setState(() => _chartType = _ChartType.bar),
        ),
      ],
    );
  }

  Widget _filterChips(List<Transaction> txns) {
    final options = <TransactionType?>[
      null,
      TransactionType.income,
      TransactionType.expense,
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: options.map((option) {
          final label = option == null
              ? 'All'
              : option.name[0].toUpperCase() + option.name.substring(1);
          final selected = _filterType == option;
          final count = option == null
              ? txns.length
              : txns.where((t) => t.type == option).length;

          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: ChoiceChip(
              label: Text('$label ($count)'),
              selected: selected,
              selectedColor: AppTheme.surfaceAlt,
              backgroundColor: AppTheme.surface,
              labelStyle: TextStyle(
                color: selected ? AppTheme.textPrimary : AppTheme.textSecondary,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
              side: BorderSide(color: selected ? AppTheme.income : AppTheme.border),
              onSelected: (_) => setState(() => _filterType = option),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _showAdd() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddTransactionSheet(controller: widget.controller),
    );
  }

  void _showEdit(Transaction t) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          AddTransactionSheet(controller: widget.controller, existing: t),
    );
  }

  void _confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete?',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: const Text(
          'This transaction will be removed.',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await widget.controller.delete(id);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppTheme.expense),
            ),
          ),
        ],
      ),
    );
  }
}
