import 'package:axisflow/automation/sms/models/sms_event.dart';

/// Duplicate detection for SMS transactions.
///
/// Compares a new [SmsEvent] against a history of previously processed events
/// to determine if it's likely a duplicate. Uses a combination of:
/// - Same sender
/// - Close timestamp window (default: 5 minutes)
/// - Same amount (if parsable)
/// - Same reference number (if available)
///
/// No Hive or persistent storage — operates purely in-memory on the
/// provided history list.
class DuplicateDetector {
  /// Default time window in milliseconds for considering two SMS events
  /// as potentially the same transaction.
  static const int defaultTimeWindowMs = 5 * 60 * 1000; // 5 minutes

  /// Check if [current] is a duplicate of any event in [history].
  ///
  /// Returns `true` if a potential duplicate is found. The decision is based
  /// on matching sender, close timestamps, and either matching amount or
  /// matching reference number.
  static bool isDuplicate(
    SmsEvent current,
    List<SmsEvent> history, {
    int timeWindowMs = defaultTimeWindowMs,
  }) {
    if (history.isEmpty) return false;

    for (final past in history) {
      if (_isDuplicatePair(current, past, timeWindowMs: timeWindowMs)) {
        return true;
      }
    }
    return false;
  }

  /// Check if two [SmsEvent] instances represent the same transaction.
  static bool _isDuplicatePair(
    SmsEvent a,
    SmsEvent b, {
    int timeWindowMs = defaultTimeWindowMs,
  }) {
    // Must have same sender
    if (a.sender.toUpperCase() != b.sender.toUpperCase()) return false;

    // Must be within the time window
    final timeDiff = (a.timestamp - b.timestamp).abs();
    if (timeDiff > timeWindowMs) return false;

    // Extract amounts for comparison
    final amountA = _extractApproximateAmount(a.body);
    final amountB = _extractApproximateAmount(b.body);

    // If both have amounts, they must match (within small tolerance)
    if (amountA != null && amountB != null) {
      if ((amountA - amountB).abs() > 0.01) return false;
    }

    // Extract reference numbers for comparison
    final refA = _extractReference(a.body);
    final refB = _extractReference(b.body);

    // If both have reference numbers, they must match
    if (refA != null && refB != null) {
      if (refA != refB) return false;
    }

    // If we have amounts that match, or references that match, it's a duplicate
    if ((amountA != null && amountB != null) ||
        (refA != null && refB != null)) {
      return true;
    }

    // If neither amount nor reference are available, use body similarity
    // as a fallback — same sender + close timestamp + similar body length
    // is a weak duplicate signal
    if (amountA == null && amountB == null && refA == null && refB == null) {
      return a.body.length == b.body.length && a.body == b.body;
    }

    return false;
  }

  /// Quick amount extraction for duplicate comparison (not for display).
  static double? _extractApproximateAmount(String body) {
    final match = RegExp(
      r'(?:Rs\.?|₹|INR)\s*([\d,]+(?:\.\d{1,2})?)',
      caseSensitive: false,
    ).firstMatch(body);
    if (match == null) return null;
    return double.tryParse(match.group(1)!.replaceAll(',', ''));
  }

  /// Quick reference extraction for duplicate comparison.
  static String? _extractReference(String body) {
    final match = RegExp(
      r'(?:ref|Ref|Trxn|Txn|UTR|UTR\s*No)[^A-Za-z0-9]*([A-Za-z0-9]{6,})',
    ).firstMatch(body);
    return match?.group(1);
  }
}
