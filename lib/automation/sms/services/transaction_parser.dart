// ignore_for_file: avoid_print

import 'package:axisflow/automation/sms/models/sms_event.dart';
import 'package:axisflow/automation/sms/parser/sms_field_extractor.dart';
import 'package:axisflow/automation/sms/services/bank_detector.dart';
import '../models/processing_result.dart';

/// Parsed fields extracted from an SMS body.
///
/// This is a pure data class produced by [TransactionParser] and consumed
/// by [ProcessingResult]. All field extraction logic lives in
/// [SmsFieldExtractor] — this class only carries data.
class ParsedTransaction {
  final double? amount;
  final String? merchant;
  final double? balance;
  final String? referenceNumber;
  final BankTransactionType transactionType;

  ParsedTransaction({
    this.amount,
    this.merchant,
    this.balance,
    this.referenceNumber,
    this.transactionType = BankTransactionType.unknown,
  });
}

/// Orchestrates SMS transaction parsing by delegating field extraction
/// to [SmsFieldExtractor].
///
/// **This class no longer contains regex patterns.**
///
/// Responsibilities:
/// 1. Call [SmsFieldExtractor] methods to extract individual fields.
/// 2. Detect the transaction type (debit/credit/UPI/etc.) via [BankDetector].
/// 3. Calculate confidence score based on how many fields were extracted.
/// 4. Build a [ParsedTransaction] and a [ProcessingResult].
///
/// See [SmsFieldExtractor] for the centralized field extraction logic.
class TransactionParser {
  /// Parse an SMS body and extract structured transaction data.
  ///
  /// Delegates all field extraction to [SmsFieldExtractor].
  /// Returns a [ParsedTransaction] with null for any unavailable field.
  /// Never throws.
  static ParsedTransaction parseBody(String body) {
    if (body.isEmpty) {
      print('[TRACE] parseBody: body is empty');
      return ParsedTransaction();
    }
    print('[TRACE] parseBody: body length=${body.length},'
        ' first 60 chars="${body.length > 60 ? body.substring(0, 60) : body}"');

    // ── Step 1: Detect transaction type FIRST ────────────────────────────
    // This tells the extractor whether the SMS is a credit (income)
    // or debit (expense), so subsequent extraction can prefer patterns
    // matching the known direction of money flow.
    final txType = SmsFieldExtractor.detectTransactionType(body);
    print('[TRACE] parseBody: detected txType=${txType.name}');

    // ── Step 2: Field extraction (type-aware) ────────────────────────────
    // Amount extraction receives the transaction type so it can prioritise
    // "credited by" patterns when the type is credit, and "debited by"
    // patterns when the type is debit.
    final amount = SmsFieldExtractor.extractAmount(
      body,
      transactionType: txType,
    );
    final merchant = SmsFieldExtractor.extractMerchant(body);
    final balance = SmsFieldExtractor.extractBalance(body);
    final refNumber = SmsFieldExtractor.extractReferenceNumber(body);

    print('[TRACE] parseBody result: amount=$amount,'
        ' merchant=$merchant, balance=$balance, ref=$refNumber');

    return ParsedTransaction(
      amount: amount,
      merchant: merchant,
      balance: balance,
      referenceNumber: refNumber,
      transactionType: txType,
    );
  }

  /// Full pipeline: parse an [SmsEvent] into a [ProcessingResult].
  static ProcessingResult processEvent(SmsEvent event) {
    print('[TRACE] processEvent: sender=${event.sender}, body.length=${event.body.length}');

    final parsed = parseBody(event.body);
    final bankResult = BankDetector.detectFromSenderOrBody(
      event.sender,
      event.body,
    );
    print('[TRACE] processEvent: bankResult=${bankResult.displayName}'
        ' (${bankResult.confidence})');

    final isTransaction = parsed.amount != null ||
        bankResult.displayName != 'UNKNOWN' ||
        parsed.merchant != null;
    print('[TRACE] processEvent: isTransaction=$isTransaction'
        ' (amount!=null=${parsed.amount != null},'
        ' bank!=UNKNOWN=${bankResult.displayName != 'UNKNOWN'},'
        ' merchant!=null=${parsed.merchant != null})');

    final confidence = _calculateConfidence(
      isTransaction: isTransaction,
      hasAmount: parsed.amount != null,
      hasMerchant: parsed.merchant != null,
      hasBalance: parsed.balance != null,
      hasReference: parsed.referenceNumber != null,
      bankConfidence: bankResult.confidence,
    );

    return ProcessingResult.fromSmsEvent(
      event: event,
      isTransaction: isTransaction,
      bank: bankResult.displayName,
      amount: parsed.amount,
      merchant: parsed.merchant,
      referenceNumber: parsed.referenceNumber,
      balance: parsed.balance,
      transactionType: parsed.transactionType,
      confidence: confidence,
    );
  }

  // ── Confidence calculation ──────────────────────────────────────────────

  static double _calculateConfidence({
    required bool isTransaction,
    required bool hasAmount,
    required bool hasMerchant,
    required bool hasBalance,
    required bool hasReference,
    required double bankConfidence,
  }) {
    if (!isTransaction) return 0.0;

    double score = 0.0;

    // Bank match contributes up to 0.3
    score += bankConfidence * 0.3;

    // Amount detected contributes 0.3
    if (hasAmount) score += 0.3;

    // Merchant detected contributes 0.15
    if (hasMerchant) score += 0.15;

    // Balance detected contributes 0.1
    if (hasBalance) score += 0.1;

    // Reference number detected contributes 0.1
    if (hasReference) score += 0.1;

    // Extra 0.05 if both amount and merchant are present (good signal)
    if (hasAmount && hasMerchant) score += 0.05;

    return score.clamp(0.0, 1.0);
  }
}
