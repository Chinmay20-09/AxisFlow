import 'package:axisflow/automation/sms/models/sms_event.dart';
import 'package:axisflow/automation/sms/services/bank_detector.dart';
import '../models/processing_result.dart';

/// Parsed fields extracted from an SMS body.
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

/// Regex-based SMS transaction parser.
///
/// Extracts structured transaction data from Indian bank SMS formats.
/// Multiple regex patterns are tried for each field to handle the variety
/// of bank message formats. The parser never crashes — nulls are returned
/// for any field that cannot be extracted.
class TransactionParser {
  // ── Amount patterns ──────────────────────────────────────────────────────

  static final _amountPatterns = <RegExp>[
    // "Rs.250", "Rs 250", "Rs. 250.50", "₹250", "₹ 250"
    RegExp(r'(?:Rs\.?|₹|INR)\s*([\d,]+(?:\.\d{1,2})?)', caseSensitive: false),
    // "debited with 250", "credited with 5000"
    RegExp(r'(?:debited|credited|spent|paid)\s+(?:with|of|is|Rs\.?|₹|INR)?\s*([\d,]+(?:\.\d{1,2})?)', caseSensitive: false),
    // "amount 250", "amt 250"
    RegExp(r'(?:amount|amt)\s*(?:is|of|:)?\s*(?:Rs\.?|₹|INR)?\s*([\d,]+(?:\.\d{1,2})?)', caseSensitive: false),
    // "A/C debited by 250"
    RegExp(r'(?:A/C|account)\s+(?:debited|credited)\s+by\s*(?:Rs\.?|₹|INR)?\s*([\d,]+(?:\.\d{1,2})?)', caseSensitive: false),
    // Standalone number after currency context words
    RegExp(r'(?:of|for|is)\s*(?:Rs\.?|₹|INR)?\s*([\d,]+(?:\.\d{1,2})?)\s*(?:wd|on|at|to|from|in)', caseSensitive: false),
  ];

  // ── Merchant patterns ────────────────────────────────────────────────────

  static final _merchantPatterns = <RegExp>[
    // "at AMAZON", "at AMAZON PAY", "at SWIGGY"
    RegExp(r'(?:at|to|for|towards|via)\s+([A-Z][A-Za-z0-9\s&.-]+?)(?:\s+(?:on|ref|Avl|Bal|Rs|at|from|of)|\.|$)', caseSensitive: false),
    // "at MERCHANT on date"
    RegExp(r'(?:at|to)\s+([A-Z][A-Za-z0-9\s&.-]+?)\s+on\s+\d{2}', caseSensitive: false),
    // "paid to MERCHANT"
    RegExp(r'paid\s+(?:to|at)\s+([A-Z][A-Za-z0-9\s&.-]+?)(?:\s+(?:on|via|ref|Avl|Bal|Rs|\.)|$)', caseSensitive: false),
    // "transfer to MERCHANT"
    RegExp(r'transfer(?:red)?\s+to\s+([A-Z][A-Za-z0-9\s&.-]+?)(?:\s+(?:on|ref|via|Avl|Bal|\.)|$)', caseSensitive: false),
  ];

  // ── Balance patterns ────────────────────────────────────────────────────

  static final _balancePatterns = <RegExp>[
    // "Avl Bal Rs.12340", "Avl Bal 12340", "Bal Rs.12340"
    RegExp(r'(?:Avl|Available)?\s*Bal(?:ance)?\.?\s*(?:Rs\.?|₹|INR)?\s*([\d,]+(?:\.\d{1,2})?)', caseSensitive: false),
    // "balance is Rs.12340", "balance Rs.12340"
    RegExp(r'balance\s+(?:is|of|:)?\s*(?:Rs\.?|₹|INR)?\s*([\d,]+(?:\.\d{1,2})?)', caseSensitive: false),
  ];

  // ── Reference number patterns ────────────────────────────────────────────

  static final _referencePatterns = <RegExp>[
    // "ref: ABC123", "Ref No 123ABC", "UTR 123456789"
    RegExp(r'(?:ref|Ref|Trxn|Txn|UTR|UTR\s*No|Ref\s*No)[^A-Za-z0-9]*([A-Za-z0-9]{6,})'),
    // Standalone 8+ char alphanumeric appearing after "ref" context
    RegExp(r'(?:reference|ref\.?|transaction\s*id|txn\s*id)\s*(?:is|:)?\s*([A-Za-z0-9]{6,})', caseSensitive: false),
  ];

  /// Parse an SMS body and extract structured transaction data.
  ///
  /// Returns a [ParsedTransaction] with null for any unavailable field.
  /// Never throws.
  static ParsedTransaction parseBody(String body) {
    if (body.isEmpty) return ParsedTransaction();

    final amount = _extractAmount(body);
    final merchant = _extractMerchant(body);
    final balance = _extractBalance(body);
    final refNumber = _extractReferenceNumber(body);

    // Determine transaction type from body keywords
    final txType = BankDetector.detectTransactionType(body);

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
    final parsed = parseBody(event.body);
    final bankResult = BankDetector.detectFromSenderOrBody(
      event.sender,
      event.body,
    );

    final isTransaction = parsed.amount != null ||
        bankResult.displayName != 'UNKNOWN' ||
        parsed.merchant != null;

    // Calculate confidence based on extracted fields
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

  // ── Private helpers ─────────────────────────────────────────────────────

  static double? _extractAmount(String body) {
    for (final pattern in _amountPatterns) {
      final match = pattern.firstMatch(body);
      if (match != null) {
        final cleaned = match.group(1)!.replaceAll(',', '');
        final value = double.tryParse(cleaned);
        if (value != null && value > 0) return value;
      }
    }
    return null;
  }

  static String? _extractMerchant(String body) {
    for (final pattern in _merchantPatterns) {
      final match = pattern.firstMatch(body);
      if (match != null) {
        final merchant = match.group(1)!.trim();
        if (merchant.length >= 2 && merchant.length <= 50) {
          return merchant;
        }
      }
    }
    return null;
  }

  static double? _extractBalance(String body) {
    for (final pattern in _balancePatterns) {
      final match = pattern.firstMatch(body);
      if (match != null) {
        final cleaned = match.group(1)!.replaceAll(',', '');
        final value = double.tryParse(cleaned);
        if (value != null && value >= 0) return value;
      }
    }
    return null;
  }

  static String? _extractReferenceNumber(String body) {
    for (final pattern in _referencePatterns) {
      final match = pattern.firstMatch(body);
      if (match != null) {
        final ref = match.group(1)!.trim();
        if (ref.length >= 6) return ref;
      }
    }
    return null;
  }

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
