// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:axisflow/data/local/settings_db.dart';
import 'package:axisflow/data/local/transaction_db.dart';
import 'package:axisflow/data/models/transaction_model.dart';
import 'package:axisflow/automation/sms/models/sms_event.dart';
import 'package:axisflow/automation/sms/models/sms_sync_result.dart';
import 'package:axisflow/automation/sms/services/transaction_parser.dart';
import 'package:axisflow/automation/sms/services/duplicate_detector.dart';
import 'package:axisflow/automation/sms/services/transaction_mapper.dart';
import '../models/processing_result.dart';

/// Orchestrates batch SMS synchronization from the device inbox.
///
/// Pipeline:
///   1. Retrieve lastProcessedSmsTimestamp from SettingsDB
///   2. Call native MethodChannel to get SMS since that timestamp
///   3. Parse each message through the existing pipeline
///   4. Deduplicate against in-memory history + database
///   5. Save valid transactions
///   6. Update lastProcessedSmsTimestamp
///   7. Return SmsSyncResult
///
/// This is the single sync entry point used by:
///   - Automatic sync on app launch
///   - Automatic sync on app resume
///   - Pull-to-refresh on Home / Alerts screens
class SmsSyncService {
  static const _syncChannel = MethodChannel('com.example.transaction/sms_sync');
  static const _lastProcessedKey = 'sms.lastProcessedTimestamp';

  /// In-memory history of previously processed results (for dedup).
  final List<ProcessingResult> _resultHistory = [];

  /// Guards against concurrent sync runs.
  bool _isSyncing = false;

  /// Optional callback invoked when a transaction is saved during sync.
  void Function(Transaction transaction)? onTransactionSaved;

  /// Pre-populate [resultHistory] from existing database transactions
  /// so duplicate detection works across sync runs.
  Future<void> prePopulateHistory() async {
    try {
      final existingTxns = TransactionDB.getAll();
      for (final tx in existingTxns) {
        _resultHistory.add(_txToProcessingResult(tx));
      }
      print('[SMS_SYNC] Pre-populated history with ${_resultHistory.length} existing transactions');
    } catch (e) {
      print('[SMS_SYNC] Could not pre-populate history: $e');
    }
  }

  /// Run a full sync: scan inbox → parse → dedup → save → update timestamp.
  ///
  /// Returns [SmsSyncResult] with counts. Never throws.
  Future<SmsSyncResult> sync() async {
    if (_isSyncing) {
      print('[SMS_SYNC] Already syncing — skipping duplicate request');
      return const SmsSyncResult();
    }
    _isSyncing = true;

    try {
      // ── Step 1: Read last processed timestamp ────────────────────────
      await SettingsDB.init();
      final lastTimestamp = SettingsDB.get<int>(_lastProcessedKey, 0) ?? 0;

      // ── Step 2: Scan device inbox via native channel ─────────────────
      final rawJson = await _syncChannel.invokeMethod<String>('scanSmsSince', {
        'sinceTimestamp': lastTimestamp,
      });

      if (rawJson == null || rawJson.isEmpty) {
        print('[SMS_SYNC] No SMS data returned from native side');
        return const SmsSyncResult();
      }

      // ── Step 3: Decode JSON array ────────────────────────────────────
      final List<dynamic> rawMessages = jsonDecode(rawJson);
      if (rawMessages.isEmpty) {
        print('[SMS_SYNC] No new SMS messages since last sync');
        return const SmsSyncResult();
      }

      print('[SMS_SYNC] Processing ${rawMessages.length} SMS messages');

      // ── Step 4: Process each message ─────────────────────────────────
      int imported = 0;
      int duplicates = 0;
      int failed = 0;
      int needsReview = 0;
      int processed = 0;
      int newestTimestamp = lastTimestamp;

      for (final raw in rawMessages) {
        if (raw is! Map) {
          failed++;
          continue;
        }

        processed++;

        try {
          final sender = raw['sender'] as String? ?? '';
          final timestamp = (raw['timestamp'] as num?)?.toInt() ?? 0;
          final body = raw['body'] as String? ?? '';

          // Track the newest timestamp for persistence
          if (timestamp > newestTimestamp) {
            newestTimestamp = timestamp;
          }

          // Skip empty bodies
          if (body.isEmpty) continue;

          // Build SmsEvent
          final smsEvent = SmsEvent(
            sender: sender,
            body: body,
            timestamp: timestamp,
          );

          // Parse
          final result = TransactionParser.processEvent(smsEvent);

          // Dedup against in-memory history
          final isDupInMemory = DuplicateDetector.isDuplicate(result, _resultHistory);

          // Dedup against database
          final existingTxns = TransactionDB.getAll();
          final isDupInDb = DuplicateDetector.existsInDatabase(result, existingTxns);

          final isDup = isDupInMemory || isDupInDb;

          if (isDup) {
            duplicates++;
            _resultHistory.add(result);
            continue;
          }

          // Save if valid transaction
          if (result.isTransaction) {
            final transaction = TransactionMapper.toTransaction(result);
            if (transaction != null) {
              await TransactionDB.add(transaction);
              imported++;
              if (transaction.state == TransactionState.pending) {
                needsReview++;
              }
              onTransactionSaved?.call(transaction);
            } else {
              failed++;
            }
          }

          // Add to in-memory history
          _resultHistory.add(result);
          if (_resultHistory.length > 200) {
            _resultHistory.removeAt(0);
          }
        } catch (e) {
          print('[SMS_SYNC] Error processing message: $e');
          failed++;
        }
      }

      // ── Step 5: Persist newest timestamp ─────────────────────────────
      if (newestTimestamp > lastTimestamp) {
        await SettingsDB.set<int>(_lastProcessedKey, newestTimestamp);
        print('[SMS_SYNC] Updated lastProcessedTimestamp to $newestTimestamp');
      }

      print('[SMS_SYNC] Sync complete: processed=$processed, '
          'imported=$imported, duplicates=$duplicates, '
          'failed=$failed, needsReview=$needsReview');

      return SmsSyncResult(
        processed: processed,
        imported: imported,
        duplicates: duplicates,
        failed: failed,
        needsReview: needsReview,
      );
    } catch (e) {
      print('[SMS_SYNC] Sync failed: $e');
      return const SmsSyncResult();
    } finally {
      _isSyncing = false;
    }
  }

  /// Reset the last processed timestamp (e.g., after a full manual rescan).
  Future<void> resetTimestamp() async {
    await SettingsDB.set<int>(_lastProcessedKey, 0);
    _resultHistory.clear();
    await prePopulateHistory();
  }

  // ── Helpers (mirroring SmsService._txToProcessingResult) ─────────────

  ProcessingResult _txToProcessingResult(Transaction tx) {
    final sender = _extractFromNote(tx.note, 'Sender');
    final merchant = _extractFromNote(tx.note, 'Merchant');
    final ref = _extractFromNote(tx.note, 'Ref');
    final bank = _extractFromNote(tx.note, 'Bank');
    return ProcessingResult(
      isTransaction: true,
      bank: bank.isNotEmpty ? bank : null,
      amount: tx.amount,
      merchant: merchant.isNotEmpty ? merchant : null,
      referenceNumber: ref.isNotEmpty ? ref : null,
      sender: sender,
      timestamp: tx.createdAt.millisecondsSinceEpoch,
      rawSms: tx.note,
      confidence: 1.0,
    );
  }

  String _extractFromNote(String note, String prefix) {
    for (final line in note.split('\n')) {
      if (line.startsWith('$prefix: ')) {
        return line.substring('$prefix: '.length).trim();
      }
    }
    return '';
  }
}
