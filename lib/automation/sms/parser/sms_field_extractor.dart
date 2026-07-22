// ignore_for_file: avoid_print

/// Centralized field extraction from Indian bank SMS messages.
///
/// **Why this class exists — design rationale:**
///
/// Before this refactoring, field extraction regexes were duplicated across
/// [TransactionParser] (amount, merchant, balance, reference) and
/// [DuplicateDetector] (amount, reference). This caused:
///   - Inconsistent extraction: the two classes could match different patterns
///     for the same field, leading to different amounts or references.
///   - Duplicated maintenance: any new bank format required editing two files.
///   - Confusing responsibilities: [DuplicateDetector] should detect duplicates,
///     not parse raw SMS bodies.
///
/// **Architecture:**
/// ```
/// SMS
///   ↓
/// SmsFieldExtractor ← ONLY place regex patterns live
///   ↓
/// ParsedTransaction (pure data)
///   ↓
/// TransactionParser (orchestration, confidence, ProcessingResult)
///   ↓
/// DuplicateDetector (compares structured fields, NO regex)
/// ```
///
/// **Adding a new bank format:**
/// 1. Add the SMS example to the test file.
/// 2. Add a small helper method in this class if no existing pattern matches.
/// 3. Done — no other file needs editing for extraction changes.
///
/// **Design principles:**
/// - Small helper methods over monolithic regex lists.
/// - Each helper targets ONE natural-language pattern family.
/// - Null safety: every method returns null when no match is found.
/// - No side effects, no logging (logging happens at the orchestration layer).
class SmsFieldExtractor {
  // ─────────────────────────────────────────────────────────────────────────
  // Amount extraction
  // ─────────────────────────────────────────────────────────────────────────

  /// Extract the transaction amount from an SMS body.
  ///
  /// Tries each pattern family in priority order and returns the first match.
  /// Supports: Rs./₹/INR prefix, "debited/credited by/with", "spent/paid",
  /// "withdrawn", "A/C XXXX debited/credited by", "amount/amt" keywords.
  static double? extractAmount(String body) {
    if (body.isEmpty) return null;

    // Priority 1: Currency-prefixed amounts (Rs., ₹, INR)
    final currencyMatch = _extractCurrencyPrefixedAmount(body);
    if (currencyMatch != null) return currencyMatch;

    // Priority 2: "debited/credited by/with" action phrases
    final actionMatch = _extractActionAmount(body);
    if (actionMatch != null) return actionMatch;

    // Priority 3: "A/C XXXX debited/credited by" account-specific
    final accountMatch = _extractAccountTransactionAmount(body);
    if (accountMatch != null) return accountMatch;

    // Priority 4: "spent/paid/withdrawn" keywords
    final spentMatch = _extractSpentWithdrawnAmount(body);
    if (spentMatch != null) return spentMatch;

    // Priority 5: "amount/amt" keyword patterns
    final keywordMatch = _extractAmountKeyword(body);
    if (keywordMatch != null) return keywordMatch;

    return null;
  }

  /// Matches "Rs.1500", "Rs 1500", "₹1500", "₹ 1500", "INR 1500",
  /// "Rs. 1,500.50", "INR 1,234.56"
  static double? _extractCurrencyPrefixedAmount(String body) {
    final patterns = [
      RegExp(r'(?:Rs\.?|₹|INR)\s*([\d,]+(?:\.\d{1,2})?)',
          caseSensitive: false),
    ];
    return _tryAmountPatterns(body, patterns);
  }

  /// Matches "debited by 1500", "credited by 5000",
  /// "debited with 1500", "credited with 1500"
  static double? _extractActionAmount(String body) {
    final patterns = [
      RegExp(
          r'(?:debited|credited)\s+(?:by|with)\s*(?:Rs\.?|₹|INR)?\s*([\d,]+(?:\.\d{1,2})?)',
          caseSensitive: false),
    ];
    return _tryAmountPatterns(body, patterns);
  }

  /// Matches "A/C XXXX1234 debited by 1500",
  /// "Account XX1234 credited by 5000"
  static double? _extractAccountTransactionAmount(String body) {
    final patterns = [
      RegExp(
          r'(?:A/C|account|a/c)\s+\S+\s+(?:debited|credited)\s+by\s*(?:Rs\.?|₹|INR)?\s*([\d,]+(?:\.\d{1,2})?)',
          caseSensitive: false),
    ];
    return _tryAmountPatterns(body, patterns);
  }

  /// Matches "spent Rs.1500", "paid Rs. 250", "withdrawn Rs. 500"
  static double? _extractSpentWithdrawnAmount(String body) {
    final patterns = [
      RegExp(
          r'(?:spent|paid|withdrawn)\s+(?:Rs\.?|₹|INR)?\s*([\d,]+(?:\.\d{1,2})?)',
          caseSensitive: false),
    ];
    return _tryAmountPatterns(body, patterns);
  }

  /// Matches "amount 250", "amt 250", "amount is 1500", "amt: 500"
  static double? _extractAmountKeyword(String body) {
    final patterns = [
      RegExp(
          r'(?:amount|amt)\s*(?:is|of|:)?\s*(?:Rs\.?|₹|INR)?\s*([\d,]+(?:\.\d{1,2})?)',
          caseSensitive: false),
    ];
    return _tryAmountPatterns(body, patterns);
  }

  /// Try a list of amount patterns and return the first valid match.
  static double? _tryAmountPatterns(String body, List<RegExp> patterns) {
    for (final pattern in patterns) {
      final match = pattern.firstMatch(body);
      if (match != null) {
        final cleaned = match.group(1)!.replaceAll(',', '');
        final value = double.tryParse(cleaned);
        if (value != null && value > 0) return value;
      }
    }
    return null;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Merchant extraction
  // ─────────────────────────────────────────────────────────────────────────

  /// Extract the merchant/payee name from an SMS body.
  ///
  /// Looks for keywords like "at", "to", "paid to", "transfer to" followed
  /// by a capitalized merchant name. Stops at common separators like
  /// keywords (on, ref, via, Avl Bal), dates, dashes, and periods.
  ///
  /// Returns null if no valid merchant is found. A valid merchant must:
  /// - Start with an uppercase letter
  /// - Be between 2 and 50 characters long
  static String? extractMerchant(String body) {
    if (body.isEmpty) return null;

    final patterns = <RegExp>[
      // "at AMAZON", "at AMAZON PAY", "at SWIGGY"
      // Also handles "at POS - SWIGGY" by optionally skipping
      // known terminal descriptors (POS, ATM, TERMINAL) before
      // capturing the actual merchant name.
      RegExp(
          r'(?:at|to|for|towards|via)\s+'
          r'(?:(?:POS|ATM|TERMINAL)\s*[-–]\s+)?'  // skip descriptors
          r'([A-Z][A-Za-z0-9\s&.]+?)'
          r'(?:\s+(?:on|ref|Avl|Bal|Rs|at|from|of|via|using|by)\b'
          r'|\s*[-–]\s+'
          r'|\.\s*'
          r'|\s+\d{2}[-/]\d{2}[-/]\d{2,4}'
          r'|$)',
          caseSensitive: false),
      // "at MERCHANT on date"
      RegExp(
          r'(?:at|to)\s+([A-Z][A-Za-z0-9\s&.-]+?)\s+on\s+\d{2}',
          caseSensitive: false),
      // "paid to MERCHANT", "paid at MERCHANT"
      RegExp(
          r'paid\s+(?:to|at)\s+([A-Z][A-Za-z0-9\s&.-]+?)'
          r'(?:\s+(?:on|via|ref|Avl|Bal|Rs)\b|\.|$)',
          caseSensitive: false),
      // "transfer to MERCHANT", "transferred to MERCHANT"
      RegExp(
          r'transfer(?:red)?\s+to\s+([A-Z][A-Za-z0-9\s&.-]+?)'
          r'(?:\s+(?:on|ref|via|Avl|Bal)\b|\.|$)',
          caseSensitive: false),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(body);
      if (match != null) {
        final merchant = match.group(1)!.trim();
        // Valid merchants must start with an uppercase letter.
        // This prevents matching lowercase words like "login" in OTP SMS.
        if (merchant.length >= 2 &&
            merchant.length <= 50 &&
            merchant[0] == merchant[0].toUpperCase()) {
          return merchant;
        }
      }
    }
    return null;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Balance extraction
  // ─────────────────────────────────────────────────────────────────────────

  /// Extract the available balance after the transaction.
  ///
  /// Matches patterns like "Avl Bal Rs.12340", "Bal 12340",
  /// "Available Balance Rs. 12,340.50"
  static double? extractBalance(String body) {
    if (body.isEmpty) return null;

    final patterns = <RegExp>[
      // "Avl Bal Rs.12340", "Avl Bal 12340", "Bal Rs.12340"
      RegExp(
          r'(?:Avl|Available)?\s*Bal(?:ance)?\.?\s*(?:Rs\.?|₹|INR)?\s*([\d,]+(?:\.\d{1,2})?)',
          caseSensitive: false),
      // "balance is Rs.12340", "Balance Rs.12340"
      RegExp(
          r'balance\s+(?:is|of|:)?\s*(?:Rs\.?|₹|INR)?\s*([\d,]+(?:\.\d{1,2})?)',
          caseSensitive: false),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(body);
      if (match != null) {
        final cleaned = match.group(1)!.replaceAll(',', '');
        final value = double.tryParse(cleaned);
        if (value != null && value >= 0) return value;
      }
    }
    return null;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Reference number extraction
  // ─────────────────────────────────────────────────────────────────────────

  /// Extract the transaction reference number from an SMS body.
  ///
  /// Supports multiple formats:
  /// - Ref, RefNo, Ref No, Refno, Reference
  /// - Txn, Txn ID, Trxn
  /// - UTR, UTR No
  ///
  /// Returns the first valid alphanumeric reference found (minimum 6 chars).
  static String? extractReferenceNumber(String body) {
    if (body.isEmpty) return null;

    // Priority 1: Explicit Ref/UTR/Txn prefixed references
    final prefixed = _extractPrefixedReference(body);
    if (prefixed != null) return prefixed;

    // Priority 2: "reference number/txn id is XXXX" patterns
    final keywordRef = _extractKeywordReference(body);
    if (keywordRef != null) return keywordRef;

    return null;
  }

  /// Matches "Ref: ABC123", "RefNo 123ABC", "Ref No XYZ789",
  /// "UTR 123456789", "UTR No 987654", "Txn ID ABC123",
  /// "Trxn 123ABC", "Reference ABC123XYZ"
  ///
  /// Uses `\b` word boundaries to prevent partial-word matches
  /// (e.g., "Ref" in "Reference" is correctly rejected).
  static String? _extractPrefixedReference(String body) {
    final patterns = [
      // UTR: "UTR 123456789", "UTR No 987654321", "UTR# ABC123"
      RegExp(
          r'\bUTR\s*(?:No|#|:)?\s*([A-Za-z0-9]{6,})\b',
          caseSensitive: false),
      // Txn: "Txn ID ABC123", "Trxn 123ABC", "Txn 123456",
      // "Transaction ID XYZ789"
      RegExp(
          r'\b(?:Txn|Trxn|Transaction)\s*(?:ID|Id|id|#|:)?\s*([A-Za-z0-9]{6,})\b',
          caseSensitive: false),
      // Ref: "Ref: ABC123", "RefNo 123ABC", "Ref No XYZ789",
      // "Refno ABC123"
      // Negative lookahead prevents matching "Reference" or "Refer"
      // but allows "RefNo", "Refno", "Ref No", etc.
      RegExp(
          r'\bRef(?!erence|er\b)\s*(?:No|#|:|\s)?\s*([A-Za-z0-9]{6,})\b',
          caseSensitive: false),
      // Lowercase "ref" keyword variants: "ref: ABC123", "ref - ABC123"
      RegExp(
          r'(?:^|\s)ref\s*[:#-]\s*([A-Za-z0-9]{6,})\b',
          caseSensitive: false),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(body);
      if (match != null) {
        final ref = match.group(1)!.trim();
        if (ref.length >= 6) return ref;
      }
    }
    return null;
  }

  /// Matches "reference number is ABC123", "reference no ABC123XYZ",
  /// "transaction id is XYZ789"
  static String? _extractKeywordReference(String body) {
    final patterns = [
      RegExp(
          r'\b(?:reference|ref\.?)\s*(?:number|no)?[:.\s]+([A-Za-z0-9]{6,})\b',
          caseSensitive: false),
      RegExp(
          r'\b(?:reference|ref\.?)\s+(?:is|:)\s*([A-Za-z0-9]{6,})\b',
          caseSensitive: false),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(body);
      if (match != null) {
        final ref = match.group(1)!.trim();
        if (ref.length >= 6) return ref;
      }
    }
    return null;
  }
}
