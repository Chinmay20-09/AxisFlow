import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:axisflow/controller/transaction_controller.dart';
import 'package:axisflow/core/theme/app_theme.dart';
import 'package:axisflow/data/models/transaction_model.dart';
import 'package:axisflow/core/error_handler.dart';
import 'package:axisflow/ui/screens/categories.dart';
import 'package:axisflow/ui/widgets/cards/category_selector.dart';
import 'package:axisflow/core/theme/app_colors.dart';


/// Lightweight replacement for the old AddTransactionSheet.
/// Keeps the same public API: AddTransactionSheet(controller, existing?)
class AddTransactionSheet extends StatefulWidget {
  final TransactionController controller;
  final Transaction? existing;

  const AddTransactionSheet({
    super.key,
    required this.controller,
    this.existing,
  });

  @override
  State<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<AddTransactionSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  TransactionType _type = TransactionType.income;
  String _category = 'Salary';
  bool _isPending = false;
  bool _saving = false;

  // Dynamic category lists (initialised from defaults, loaded from settings)
  List<String> _incomeCatsList = incomeCategories.map((c) => c.name).toList();
  List<String> _expenseCatsList = expenseCategories.map((c) => c.name).toList();

  List<String> get _currentCategories =>
      _type == TransactionType.income ? _incomeCatsList : _expenseCatsList;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      _amountCtrl.text = e.amount.toStringAsFixed(0);
      _noteCtrl.text = e.note;
      _type = e.type;
      _category = e.category;
      _isPending = e.state == TransactionState.pending;
    } else {
      _category = _incomeCatsList.first;
    }
    _loadCategoryLists();
  }

  Future<void> _loadCategoryLists() async {
    try {
      final inc = await loadIncomeCategoryNames();
      final exp = await loadExpenseCategoryNames();
      if (mounted) {
        setState(() {
          _incomeCatsList = inc;
          _expenseCatsList = exp;
          if (!_currentCategories.contains(_category)) {
            _category = _currentCategories.first;
          }
        });
      }
    } catch (_) {
      // ignore
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  bool get _canSave {
    final v = double.tryParse(_amountCtrl.text.trim());
    return !_saving && v != null && v > 0;
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade700,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      isEdit ? 'Edit transaction' : 'New transaction',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceAlt,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _type == TransactionType.income ? '↓' : '↑',
                      style: TextStyle(color: AppTheme.typeColor(_type)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Type toggle
              Row(
                children: TransactionType.values.map((t) {
                  final selected = _type == t;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() {
                        _type = t;
                        if (!_currentCategories.contains(_category)) {
                          _category = _currentCategories.first;
                        }
                      }),
                      child: Container(
                        margin: EdgeInsets.only(
                          right: t != TransactionType.values.last ? 8 : 0,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppTheme.typeColor(t).withValues(alpha: 0.12)
                              : AppTheme.surfaceAlt,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selected
                                ? AppTheme.typeColor(t)
                                : Colors.transparent,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(t == TransactionType.income ? '↓' : '↑'),
                            const SizedBox(height: 6),
                            Text(
                              t.name.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 12),

              TextFormField(
                controller: _amountCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixText: '₹ ',
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Enter amount';
                  final a = double.tryParse(v.trim());
                  if (a == null || a <= 0) return 'Enter valid amount';
                  return null;
                },
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 10),

              TextFormField(
                controller: _noteCtrl,
                decoration: const InputDecoration(labelText: 'Note (optional)'),
                textInputAction: TextInputAction.done,
              ),

              const SizedBox(height: 8),

              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: _isPending,
                onChanged: (v) => setState(() => _isPending = v ?? false),
                title: const Text('Mark as Pending'),
                controlAffinity: ListTileControlAffinity.leading,
              ),

              const SizedBox(height: 8),

              // Shared category selector with favorites, icons, and picker
              CategorySelector(
                transactionType: _type,
                selectedCategory: _category,
                onChanged: (name) => setState(() => _category = name),
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _canSave ? _save : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.black,
                  ),
                  child: _saving
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(isEdit ? 'UPDATE TRANSACTION' : 'ADD TRANSACTION'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (_formKey.currentState?.validate() != true) return;
    final amt = double.parse(_amountCtrl.text.trim());
    setState(() => _saving = true);
    await Future.delayed(const Duration(milliseconds: 200)); // small UX delay

    try {
      if (widget.existing != null) {
        final t = widget.existing!;
        t.amount = amt;
        t.note = _noteCtrl.text.trim();
        t.type = _type;
        t.category = _category;
        t.state = _isPending
            ? TransactionState.pending
            : TransactionState.completed;
        await widget.controller.update(t);
      } else {
        final t = Transaction(
          id: '${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(9999)}',
          amount: amt,
          type: _type,
          note: _noteCtrl.text.trim(),
          category: _category,
          createdAt: DateTime.now(),
          state: _isPending
              ? TransactionState.pending
              : TransactionState.completed,
        );
        await widget.controller.add(t);
      }

      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      // show friendly error and keep sheet open for retry
      if (!mounted) return;
      showErrorSnackBar(context, e, 'Failed to save transaction');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
