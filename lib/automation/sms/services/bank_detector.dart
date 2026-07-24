import '../models/processing_result.dart';
import '../parser/sms_field_extractor.dart';

/// Identifies financial institutions and payment apps from SMS sender names.
///
/// Uses a prefix-based matching strategy against known bank/Upi sender IDs.
/// Returns [BankResult] containing the display name and confidence.
class BankResult {
  final String displayName;
  final double confidence;

  BankResult({required this.displayName, required this.confidence});

  static final unknown = BankResult(displayName: 'UNKNOWN', confidence: 0.0);
}

class BankDetector {
  static const _bankMappings = <String, String>{
    'HDFCBK': 'HDFC',
    'ICICIB': 'ICICI',
    'SBIINB': 'SBI',
    'AXISBK': 'Axis',
    'KOTAK': 'Kotak Mahindra',
    'YESBNK': 'Yes Bank',
    'PNBSMS': 'PNB',
    'BOIIND': 'Bank of India',
    'IDFCFB': 'IDFC First',
    'CANBNK': 'Canara Bank',
    'UNIONB': 'Union Bank',
    'FEDBNK': 'Federal Bank',
    'SBICARD': 'SBI Card',
    'ICICICARD': 'ICICI Card',
    'HDFCCARD': 'HDFC Card',
    'AXISCARD': 'Axis Card',
  };

  static const _upiMappings = <String, String>{
    'GPAY': 'Google Pay',
    'PHONEPE': 'PhonePe',
    'PAYTM': 'Paytm',
    'BHIM': 'BHIM',
    'AMAZONPAY': 'Amazon Pay',
  };

  /// Combine all mappings for lookup order: banks first, then UPI.
  static Map<String, String> get _allMappings =>
      {..._bankMappings, ..._upiMappings};

  /// Detect bank/Upi from the raw sender string.
  ///
  /// Matches by checking if the sender starts with or contains any known key.
  /// Matching is case-insensitive.
  static BankResult detect(String sender) {
    if (sender.isEmpty) return BankResult.unknown;

    final upper = sender.toUpperCase();

    // Try exact or starts-with match against all mappings
    BankResult? bestMatch;
    int bestLength = 0;

    for (final entry in _allMappings.entries) {
      if (upper.startsWith(entry.key) || entry.key.startsWith(upper)) {
        final matchLen = entry.key.length;
        if (matchLen > bestLength) {
          bestLength = matchLen;
          bestMatch = BankResult(
            displayName: entry.value,
            // Longer match = higher confidence
            confidence: (matchLen / 8.0).clamp(0.5, 1.0),
          );
        }
      }
    }

    // Fallback: check if sender contains any known key
    if (bestMatch == null) {
      for (final entry in _allMappings.entries) {
        if (upper.contains(entry.key) || entry.key.contains(upper)) {
          final matchLen = entry.key.length;
          if (matchLen > bestLength) {
            bestLength = matchLen;
            bestMatch = BankResult(
              displayName: entry.value,
              confidence: 0.5,
            );
          }
        }
      }
    }

    return bestMatch ?? BankResult.unknown;
  }

  /// Detect bank from sender or fallback to body keyword matching.
  static BankResult detectFromSenderOrBody(String sender, String body) {
    final fromSender = detect(sender);
    if (fromSender.displayName != 'UNKNOWN' && fromSender.confidence >= 0.5) {
      return fromSender;
    }

    // Fallback: check body for known bank keywords
    final upperBody = body.toUpperCase();
    for (final entry in _allMappings.entries) {
      if (upperBody.contains(entry.key)) {
        return BankResult(displayName: entry.value, confidence: 0.4);
      }
    }

    return BankResult.unknown;
  }

  /// Transaction type detection based on body content keywords.
  ///
  /// Delegates to [SmsFieldExtractor.detectTransactionType] — the single
  /// source of truth for body-based transaction type detection.
  static BankTransactionType detectTransactionType(String body) {
    return SmsFieldExtractor.detectTransactionType(body);
  }
}
