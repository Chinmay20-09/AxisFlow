// ignore_for_file: avoid_print

import '../models/processing_result.dart';

/// Duplicate detection for SMS transactions.
///
/// **Architecture note:**
/// This class performs ALL comparisons on structured [ProcessingResult] objects,
/// NOT on raw SMS strings. This ensures consistency with [TransactionParser]
/// and [SmsFieldExtractor], which are the single sources of truth for field
/// extraction.
///
/// Before this refactoring, [DuplicateDetector] had its own regexes for
/// amount and reference extraction, which could produce different results
/// than [TransactionParser]. This caused:
///   - False negatives: a real duplicate might be missed because the amounts
///     were parsed differently.
///   - False positives: a non-duplicate might be flagged because one parser
///     found a match the other didn't.
///
/// **Comparison strategy (priority order):**
/// 1. Same reference number -> strongest duplicate signal.
/// 2. Same sender + same amount + same merchant + timestamp within window.
/// 3. Body equality as fallback when no structured fields exist.
class DuplicateDetector {
  /// Default time window in milliseconds for considering two transactions
  /// as potentially the same.
  static const int defaultTimeWindowMs = 5 * 60 * 1000; // 5 minutes

  /// Check if [current] is a duplicate of any result in [history].
  ///
  /// [history] is a list of previously processed [ProcessingResult] objects.
  /// Returns `true` if a potential duplicate is found.
  ///
  /// Comparison uses structured fields only — no regex parsing of raw SMS.
  static bool isDuplicate(
    ProcessingResult current,
    List<ProcessingResult> history, {
    int timeWindowMs = defaultTimeWindowMs,
  }) {
    print('[TRACE] DuplicateDetector.isDuplicate() — history size=${history.length}, '
        'current sender=${current.sender}, timeWindowMs=$timeWindowMs');

    if (history.isEmpty) {
      print('[TRACE]   history empty → false');
      return false;
    }

    for (int i = 0; i < history.length; i++) {
      final past = history[i];
      print('[TRACE]   comparing with history[$i]: sender=${past.sender},'
          ' ts=${past.timestamp}');
      if (_isDuplicatePair(current, past, timeWindowMs: timeWindowMs)) {
        print('[TRACE]   → MATCH at index $i — returning true');
        return true;
      }
    }

    print('[TRACE]   → no duplicate found — returning false');
    return false;
  }

  /// Check if two [ProcessingResult] instances represent the same transaction.
  ///
  /// Comparison priority:
  /// 1. Same unique reference number → immediate duplicate (strongest signal).
  /// 2. Same sender + same amount + same merchant + close timestamp.
  /// 3. Body equality as final fallback (only when nothing structured is available).
  static bool _isDuplicatePair(
    ProcessingResult a,
    ProcessingResult b, {
    int timeWindowMs = defaultTimeWindowMs,
  }) {
    // ── Priority 1: Same reference number ─────────────────────────────────
    if (a.referenceNumber != null &&
        b.referenceNumber != null &&
        a.referenceNumber == b.referenceNumber) {
      print('[TRACE]   priority 1: matching ref "${a.referenceNumber}" → TRUE');
      return true;
    }

    // ── Must have same sender for further comparison ──────────────────────
    final sameSender = a.sender.toUpperCase() == b.sender.toUpperCase();
    if (!sameSender) {
      print('[TRACE]   sender mismatch: "${a.sender}" vs "${b.sender}" → false');
      return false;
    }
    print('[TRACE]   sender match: "${a.sender}"');

    // Must be within the time window
    final timeDiff = (a.timestamp - b.timestamp).abs();
    if (timeDiff > timeWindowMs) {
      print('[TRACE]   timeDiff=$timeDiff ms > window=$timeWindowMs ms → false');
      return false;
    }
    print('[TRACE]   timeDiff=$timeDiff ms within window ✓');

    // ── Priority 2: Structured field comparison ───────────────────────────
    // Requires BOTH same amount AND same merchant to match.
    // This prevents false positives when two different transactions
    // happen to have the same amount from the same bank within the
    // time window (e.g., two different Uber rides costing ₹150 each).
    final sameAmount = a.amount != null &&
        b.amount != null &&
        (a.amount! - b.amount!).abs() < 0.01;

    final sameMerchant = a.merchant != null &&
        b.merchant != null &&
        a.merchant!.toUpperCase() == b.merchant!.toUpperCase();

    if (sameAmount && sameMerchant) {
      print('[TRACE]   priority 2: matching amount=${a.amount}'
          ' + merchant="${a.merchant}" → TRUE');
      return true;
    }

    // ── Priority 3: Fallback body equality ────────────────────────────────
    final noStructuredData = a.amount == null &&
        b.amount == null &&
        a.merchant == null &&
        b.merchant == null &&
        a.referenceNumber == null &&
        b.referenceNumber == null;

    if (noStructuredData) {
      final bodyMatch = a.rawSms == b.rawSms;
      print('[TRACE]   priority 3: no structured data in either,'
          ' body match: ${bodyMatch ? 'TRUE' : 'false'}');
      return bodyMatch;
    }

    print('[TRACE]   no duplicate signal found → false');
    return false;
  }
}
