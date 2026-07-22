import 'package:axisflow/data/models/transaction_model.dart';

/// Data passed from [SmsService] when a transaction is successfully saved.
///
/// Used to populate the [PopupAddTransaction] bottom sheet.
class TransactionSavedData {
  final String transactionId;
  final double amount;
  final String merchant;
  final String bank;
  final String account;
  final DateTime date;
  final String suggestedCategory;
  final bool needsAttention;
  final TransactionType transactionType;

  const TransactionSavedData({
    required this.transactionId,
    required this.amount,
    required this.merchant,
    required this.bank,
    required this.account,
    required this.date,
    this.suggestedCategory = 'Uncategorized',
    this.needsAttention = false,
    this.transactionType = TransactionType.expense,
  });
}
