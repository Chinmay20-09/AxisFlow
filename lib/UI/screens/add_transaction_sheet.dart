// lib/ui/screens/add_transaction_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../controller/transaction_controller.dart';
import '../../data/transaction_model.dart';
import '../app_theme.dart';
import 'dart:math';

// ignore: constant_identifier_names
const List<String> k_inCategories = [
  'Salary 💰',
  'Freelance 💻',
  'Business 🏢',
  'Investment 💼',
  'Gift 🎁',
  'Refund 💸',
  'Bonus 🎉',
  'Rental 🏠',
  'Scholarship 🎓',
  'Other 🔄',
];

// ignore: constant_identifier_names
const List<String> k_exCategories = [
  'Food 🍽️',
  'Transport 🚗',
  'Bills 💳',
  'Shopping 🛍️',
  'Health 🏥',
  'Education 📚',
  'Entertainment 🎬',
  'Travel 🌍',
  'Subscription 💳',
  'Rent 🏠',
  'EMI 💸',
  'Family 👨‍👩‍👧‍👦',
  'Personal 🧑',
  'Other 🔄'
];

class AddTransactionSheet extends StatefulWidget {
  final TransactionController controller;
  final Transaction? existing; // null = add, non-null = edit

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
  late String _category;
  bool _saving = false;
  bool _isPending = false;

  bool get _canSave {
    final value = double.tryParse(_amountCtrl.text.trim());
    return !_saving && value != null && value > 0;
  }

  @override
  void initState() {
    super.initState();
    _category = k_inCategories.first;
    final e = widget.existing;
    if (e != null) {
      _amountCtrl.text = e.amount.toStringAsFixed(0);
      _noteCtrl.text = e.note;
      _type = e.type;
      _category = e.category;
      _isPending = e.state == TransactionState.pending;
    }
  }

  List<String> get _currentCategories {
    switch (_type) {
      case TransactionType.income:
        return k_inCategories;
      case TransactionType.expense:
        return k_exCategories;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
  child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: AppTheme.border,
                borderRadius: BorderRadius.circular(3),
                       ),
        ),
      
    ),
          const SizedBox(height: 18),

          Row(
            children: [
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEdit ? 'Edit transaction' : 'New transaction',
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Save your income, expense quickly and easily',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceAlt,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Text(
                  _typeIcon(_type),
                  style: TextStyle(
                    fontSize: 18,
                    color: AppTheme.typeColor(_type),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Row(
            children: TransactionType.values.map((t) {
              final selected = _type == t;
              final color = AppTheme.typeColor(t);
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() {
                    _type = t;
                    if (!_currentCategories.contains(_category)) {
                      _category = _currentCategories.first;
                    }
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: EdgeInsets.only(
                      right: t != TransactionType.values.last ? 10 : 0,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: selected
                          ? color.withValues(alpha: 0.14)
                          : AppTheme.surfaceAlt,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: selected ? color : AppTheme.border,
                        width: selected ? 1.5 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          _typeIcon(t),
                          style: TextStyle(
                            fontSize: 18,
                            color: selected ? color : AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          t.name.toUpperCase(),
                          style: TextStyle(
                            color: selected ? color : AppTheme.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.9,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 22),

          TextFormField(
            controller: _amountCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textInputAction: TextInputAction.next,
            onChanged: (_) => setState(() {}),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
            validator: _validateAmount,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
            decoration: const InputDecoration(
              labelText: 'Amount',
              helperText: 'Enter the transaction amount',
              prefixText: '₹ ',
              prefixStyle: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 20,
              ),
            ),
          ),
          const SizedBox(height: 14),

          TextFormField(
            controller: _noteCtrl,
            textInputAction: TextInputAction.done,
            style: const TextStyle(color: AppTheme.textPrimary),
            decoration: const InputDecoration(
              labelText: 'Note (optional)',
              hintText: 'e.g. Coffee, salary, rent',
            ),
          ),
          const SizedBox(height: 14),

          CheckboxListTile(
          value: _isPending,
          onChanged: (v) {
          setState(() {
            _isPending = v ?? false;
          });
        },
          activeColor: AppTheme.typeColor(_type),
          contentPadding: EdgeInsets.zero,
          title: const Text(
          'Mark as Pending',
          style: TextStyle(
          color: AppTheme.textPrimary,
          fontWeight: FontWeight.w600,
    ),
  ),
),
const SizedBox(height: 10),

          DropdownButtonFormField<String>(
            initialValue: _category,
            dropdownColor: AppTheme.surfaceAlt,
            style: const TextStyle(color: AppTheme.textPrimary),
            decoration: const InputDecoration(labelText: 'Category'),
            items: _currentCategories
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: (v) => setState(() => _category = v!),
          ),
          const SizedBox(height: 26),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _canSave ? _save : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _canSave ? AppTheme.typeColor(_type) : AppTheme.border,
                foregroundColor: AppTheme.bg,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _saving
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.bg),
                    )
                  : Text(
                      isEdit ? 'UPDATE TRANSACTION' : 'ADD TRANSACTION',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
            ),
          ),
        ],
      ),
      ),
      )
    );
  }

  Future<void> _save() async {
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    final amt = double.tryParse(_amountCtrl.text.trim())!;
    FocusScope.of(context).unfocus();
    setState(() => _saving = true);

    if (widget.existing != null) {
      final t = widget.existing!;
      t.amount = amt;
      t.type = _type;
      t.note = _noteCtrl.text.trim();
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

    if (mounted) Navigator.pop(context);
  }

  String? _validateAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Enter amount';
    }
    final amount = double.tryParse(value.trim());
    if (amount == null || amount <= 0) {
      return 'Enter a valid positive amount';
    }
    return null;
  }

  String _typeIcon(TransactionType t) {
    switch (t) {
      case TransactionType.income:
        return '↓';
      case TransactionType.expense:
        return '↑';
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }
}
