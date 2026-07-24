/// Result of a batch SMS synchronization run.
///
/// Returned by [SmsSyncService.sync] so callers can decide whether to
/// show a review popup, update a badge, or just refresh the UI.
class SmsSyncResult {
  /// Total SMS messages processed during this sync.
  final int processed;

  /// Transactions that were successfully saved (new, not duplicate).
  final int imported;

  /// Transactions that were skipped because they already exist.
  final int duplicates;

  /// SMS messages that failed to parse or save.
  final int failed;

  /// Newly imported transactions that need user review
  /// (isTransaction == true && state == pending).
  final int needsReview;

  const SmsSyncResult({
    this.processed = 0,
    this.imported = 0,
    this.duplicates = 0,
    this.failed = 0,
    this.needsReview = 0,
  });

  bool get hasNewData => imported > 0 || needsReview > 0;

  @override
  String toString() =>
      'SmsSyncResult(processed: $processed, imported: $imported, '
      'duplicates: $duplicates, failed: $failed, needsReview: $needsReview)';
}
