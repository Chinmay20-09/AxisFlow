// ignore_for_file: avoid_print

import 'package:axisflow/data/models/transaction_model.dart';
import '../models/processing_result.dart';
import 'dart:convert';

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
    if (!result.isTransaction) {
      print('[TRACE] toTransaction: SKIP — isTransaction=false');
      return null;
    }
    if (result.amount == null || result.amount! <= 0) {
      print('[TRACE] toTransaction: SKIP — amount=${result.amount} (null or <=0)');
      return null;
    }

    final now = DateTime.now();
    final timestamp = result.timestamp > 0
        ? DateTime.fromMillisecondsSinceEpoch(result.timestamp)
        : now;

    print('[TRACE] toTransaction: ✓ mapping to Transaction (amount=${result.amount}, timestamp=$timestamp)');
    return Transaction(
      id: _deterministicId(result, timestamp),
      amount: result.amount!,
      type: _mapTransactionType(result),
      note: _buildNote(result),
      category: defaultCategory,
      createdAt: timestamp,
      state: TransactionStateHelper.defaultImportedState,
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

  /// Generate a deterministic, unique ID for a transaction based on
  /// SMS content rather than random chance.
  ///
  /// Uses a hash of [sender] + [amount] + [merchant] + [referenceNumber]
  /// + [timestamp] so the same SMS always produces the same ID.
  /// Two different SMS events will produce different IDs.
  static String _deterministicId(ProcessingResult result, DateTime timestamp) {
    final raw = '${result.sender}|${result.amount}|${result.merchant}|'
        '${result.referenceNumber}|${timestamp.millisecondsSinceEpoch}';
    final bytes = utf8.encode(raw);
    // Simple hash: take first 12 hex chars of SHA256-like digest.
    // Dart doesn't have built-in SHA256 without crypto package,
    // so we use a stable hash combining approach.
    int hash = 17;
    for (final byte in bytes) {
      hash = hash * 31 + byte;
    }
    final hashStr = hash.toRadixString(16).padLeft(8, '0');
    return 'sms_${timestamp.millisecondsSinceEpoch}_$hashStr';
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
