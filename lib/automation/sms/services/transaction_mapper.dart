import 'dart:math';
import 'package:axisflow/data/models/transaction_model.dart';
import '../models/processing_result.dart';

/// Maps a [ProcessingResult] into the app's [Transaction] model.
///
/// The parser/mapper/repository separation is maintained:
/// - Parser extracts fields from SMS (already done in TransactionParser)
/// - Mapper converts to app model (this class)
/// - Repository saves to Hive (TransactionDB)
///
/// This class has NO knowledge of Hive or persistence.
class TransactionMapper {
  /// Default category for auto-imported SMS transactions.
  static const String defaultCategory = 'Uncategorized';

  /// Map a [ProcessingResult] into a [Transaction].
  ///
  /// Returns `null` if the result is not a valid transaction
  /// (e.g. no amount detected).
  static Transaction? toTransaction(ProcessingResult result) {
    if (!result.isTransaction) return null;
    if (result.amount == null || result.amount! <= 0) return null;

    final now = DateTime.now();
    final timestamp = result.timestamp > 0
        ? DateTime.fromMillisecondsSinceEpoch(result.timestamp)
        : now;

    return Transaction(
      id: 'sms_${timestamp.millisecondsSinceEpoch}_${Random().nextInt(99999)}',
      amount: result.amount!,
      type: _mapTransactionType(result),
      note: _buildNote(result),
      category: defaultCategory,
      createdAt: timestamp,
      state: TransactionState.completed,
    );
  }

  /// Determine whether the SMS transaction is income or expense.
  static TransactionType _mapTransactionType(ProcessingResult result) {
    switch (result.transactionType) {
      case BankTransactionType.credit:
        return TransactionType.income;
      case BankTransactionType.debit:
      case BankTransactionType.atm:
      case BankTransactionType.upi:
      case BankTransactionType.imps:
      case BankTransactionType.neft:
      case BankTransactionType.rtgs:
      case BankTransactionType.card:
      case BankTransactionType.wallet:
        return TransactionType.expense;
      case BankTransactionType.unknown:
        // Default to expense for unrecognized transaction types
        return TransactionType.expense;
    }
  }

  /// Build a structured note string from the processing result.
  ///
  /// sender, and confidence as structured fields instead of flattening
  /// them into the note string.
  static String _buildNote(ProcessingResult result) {
    final parts = <String>[];

    parts.add('Sender: ${result.sender}');

    if (result.merchant != null && result.merchant!.isNotEmpty) {
      parts.add('Merchant: ${result.merchant}');
    }

    if (result.bank != null && result.bank != 'UNKNOWN') {
      parts.add('Bank: ${result.bank}');
    }

    if (result.referenceNumber != null && result.referenceNumber!.isNotEmpty) {
      parts.add('Ref: ${result.referenceNumber}');
    }

    parts.add('Confidence: ${(result.confidence * 100).toStringAsFixed(0)}%');

    // Include original SMS content for traceability
    if (result.rawSms.isNotEmpty) {
      parts.add('SMS: ${result.rawSms}');
    }

    return parts.join('\n');
  }
}
