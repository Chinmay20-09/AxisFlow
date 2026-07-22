// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:flutter/services.dart';
import 'models/sms_event.dart';
import 'models/processing_result.dart';
import 'services/bank_detector.dart';
import 'services/transaction_parser.dart';
import 'services/duplicate_detector.dart';
import 'services/transaction_mapper.dart';
import 'package:axisflow/data/local/transaction_db.dart';
import 'package:axisflow/controller/transaction_controller.dart';

/// PHASE 8 — Full automatic transaction pipeline with Hive persistence.
///
/// Pipeline:
///   EventChannel → SmsEvent → BankDetector → TransactionParser
///   → DuplicateDetector → TransactionMapper → TransactionDB → Dashboard
///
/// On every valid SMS:
///   1. ProcessingResult is generated
///   2. If isTransaction and not duplicate → mapped to Transaction
///   3. Saved to TransactionDB (Hive)
///   4. TransactionController reloads → dashboard auto-updates
class SmsService {
  static const _channel = EventChannel('com.example.transaction/sms');

  bool _initialized = false;

  /// In-memory history of received events (for duplicate detection).
  final List<SmsEvent> _eventHistory = [];

  /// The controller used to refresh the UI after saving.
  TransactionController? _controller;

  /// Set the controller to enable automatic dashboard refresh on save.
  void setController(TransactionController controller) {
    _controller = controller;
  }

  /// Callback invoked when an SMS is fully processed.
  /// Set this to receive processing results.
  void Function(ProcessingResult result)? onProcessed;

  /// Start listening to native SMS events.
  /// Safe to call multiple times (only initializes once).
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    print('[SMS] SmsService initialize()');

    _channel.receiveBroadcastStream().listen(
      (event) async {
        print('[SMS] Raw payload received');

        // Step 1: Decode and create SmsEvent
        final decoded = _decodePayload(event);
        if (decoded == null) return;

        if (!_validatePayload(decoded)) return;

        print('[SMS] Payload validated');

        final smsEvent = SmsEvent.fromJson(decoded);
        print('[SMS] Event: sender=${smsEvent.sender}, '
            'body="${smsEvent.body.length > 60 ? '${smsEvent.body.substring(0, 60)}...' : smsEvent.body}"');

        // Step 2: Detect bank
        final bankResult = BankDetector.detect(smsEvent.sender);
        print('[Bank] Detected: ${bankResult.displayName} '
            '(confidence: ${bankResult.confidence.toStringAsFixed(2)})');

        // Step 3: Parse transaction fields
        final parsed = TransactionParser.parseBody(smsEvent.body);
        print('[Parser] Amount: ${parsed.amount}, '
            'Merchant: ${parsed.merchant}, '
            'Balance: ${parsed.balance}, '
            'Ref: ${parsed.referenceNumber}');

        // Step 4: Check for duplicates
        final isDup = DuplicateDetector.isDuplicate(smsEvent, _eventHistory);
        if (isDup) {
          print('[Duplicate] Potential duplicate detected — skipping');
        }

        // Step 5: Build ProcessingResult
        final result = TransactionParser.processEvent(smsEvent);
        print('[Processing] Result: '
            'isTransaction=${result.isTransaction}, '
            'bank=${result.bank}, '
            'amount=${result.amount}, '
            'merchant=${result.merchant}, '
            'balance=${result.balance}, '
            'type=${result.transactionType.name}, '
            'confidence=${result.confidence.toStringAsFixed(2)}');

        // Step 6: Auto-save if valid transaction and not duplicate
        if (result.isTransaction && !isDup) {
          await _autoSaveTransaction(result);
        } else if (!result.isTransaction) {
          print('[Storage] Skipping — not a transaction');
        } else if (isDup) {
          // Already logged as duplicate above
        }

        // Add to history (even duplicates — for future comparison)
        _eventHistory.add(smsEvent);
        // Keep history bounded
        if (_eventHistory.length > 100) {
          _eventHistory.removeAt(0);
        }

        // Notify listener
        onProcessed?.call(result);
      },
      onError: (error) {
        print('[SMS][ERROR] Stream error: $error');
      },
      onDone: () {
        print('[SMS] Stream closed');
      },
    );

    print('[SMS] EventChannel connected');
    print('[SMS] Waiting for SMS...');
  }

  /// Map the [ProcessingResult] to a [Transaction] and persist it.
  Future<void> _autoSaveTransaction(ProcessingResult result) async {
    final transaction = TransactionMapper.toTransaction(result);

    if (transaction == null) {
      print('[Mapper] Failed to map ProcessingResult — missing amount or not a transaction');
      return;
    }

    print('[Mapper] Mapped to Transaction: '
        'amount=${transaction.amount}, '
        'type=${transaction.typeLabel}, '
        'category=${transaction.category}, '
        'merchant_from_note=${transaction.note.split('\n').first}');

    // Save to Hive
    try {
      await TransactionDB.add(transaction);
      print('[Repository] TransactionDB.add() succeeded (id: ${transaction.id})');
      print('[Storage] Transaction persisted to Hive (id: ${transaction.id})');
    } catch (e) {
      print('[Storage][ERROR] Failed to persist transaction: $e');
      return;
    }

    // Notify controller to refresh dashboard
    _controller?.load();
    print('[Dashboard] Controller notified — dashboard will refresh');
  }

  /// Decode the raw event into a [Map].
  Map<String, dynamic>? _decodePayload(dynamic event) {
    if (event == null) {
      print('[SMS][ERROR] Payload is null');
      return null;
    }

    if (event is! String) {
      print('[SMS][ERROR] Payload is not a string');
      return null;
    }

    try {
      final decoded = jsonDecode(event);
      if (decoded is! Map<String, dynamic>) {
        print('[SMS][ERROR] Payload is not JSON');
        return null;
      }
      return decoded;
    } catch (e) {
      print('[SMS][ERROR] Failed to decode JSON: $e');
      return null;
    }
  }

  /// Validate that the decoded map contains all required keys.
  bool _validatePayload(Map<String, dynamic> payload) {
    if (!payload.containsKey('version') || !payload.containsKey('event')) {
      print('[SMS][ERROR] Invalid payload schema: missing version or event');
      return false;
    }

    if (!payload.containsKey('data') || payload['data'] is! Map) {
      print('[SMS][ERROR] Missing data object');
      return false;
    }

    final data = payload['data'] as Map<String, dynamic>;

    if (!data.containsKey('sender')) {
      print('[SMS][ERROR] Missing sender');
      return false;
    }

    if (!data.containsKey('timestamp')) {
      print('[SMS][ERROR] Missing timestamp');
      return false;
    }

    if (!data.containsKey('body')) {
      print('[SMS][ERROR] Missing body');
      return false;
    }

    return true;
  }
}
