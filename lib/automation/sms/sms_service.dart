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

  /// In-memory history of processed results (for duplicate detection).
  ///
  /// Stores [ProcessingResult] objects so [DuplicateDetector] can compare
  /// structured fields (amount, merchant, reference) without parsing raw SMS.
  final List<ProcessingResult> _resultHistory = [];

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
    // LOG: verify initialize() called once
    print('[TRACE] SmsService.initialize(): _initialized was $_initialized before guard');
    if (_initialized) {
      print('[TRACE] SmsService.initialize(): SKIP — already initialized');
      return;
    }
    _initialized = true;
    print('[TRACE] SmsService.initialize(): _initialized now true (first call)');

    print('[SMS] SmsService initialize()');

    print('[TRACE] EventChannel receiveBroadcastStream().listen() — subscribing...');
    _channel.receiveBroadcastStream().listen(
      (event) async {
        print('[TRACE] ===== EVENT CHANNEL CALLBACK FIRED =====');
        print('[TRACE] event runtimeType=${event.runtimeType}');
        print('[TRACE] event value (first 120 chars): ${event.toString().length > 120 ? '${event.toString().substring(0, 120)}...' : event.toString()}');
        print('[SMS] Raw payload received');

        // Step 1: Decode and create SmsEvent
        print('[TRACE] >>> _decodePayload()...');
        final decoded = _decodePayload(event);
        print('[TRACE] <<< _decodePayload() → ${decoded == null ? 'NULL' : 'OK'}');
        if (decoded == null) return;

        print('[TRACE] >>> _validatePayload()...');
        final valid = _validatePayload(decoded);
        print('[TRACE] <<< _validatePayload() → $valid');
        if (!valid) return;

        print('[SMS] Payload validated');

        print('[TRACE] >>> SmsEvent.fromJson()...');
        final smsEvent = SmsEvent.fromJson(decoded);
        print('[TRACE] <<< SmsEvent.fromJson() ✓');
        print('[SMS] Event: sender=${smsEvent.sender}, '
            'body="${smsEvent.body.length > 60 ? '${smsEvent.body.substring(0, 60)}...' : smsEvent.body}"');

        // Step 2: Detect bank
        print('[TRACE] >>> BankDetector.detect(${smsEvent.sender})...');
        final bankResult = BankDetector.detect(smsEvent.sender);
        print('[TRACE] <<< BankDetector.detect() → ${bankResult.displayName} (${bankResult.confidence})');
        print('[Bank] Detected: ${bankResult.displayName} '
            '(confidence: ${bankResult.confidence.toStringAsFixed(2)})');

        // Step 3: Build ProcessingResult (uses SmsFieldExtractor internally)
        print('[TRACE] >>> TransactionParser.processEvent()...');
        final result = TransactionParser.processEvent(smsEvent);
        print('[TRACE] <<< TransactionParser.processEvent() → isTransaction=${result.isTransaction}, amount=${result.amount}');
        print('[Processing] Result: '
            'isTransaction=${result.isTransaction}, '
            'bank=${result.bank}, '
            'amount=${result.amount}, '
            'merchant=${result.merchant}, '
            'balance=${result.balance}, '
            'type=${result.transactionType.name}, '
            'confidence=${result.confidence.toStringAsFixed(2)}');

        // Step 4: Check for duplicates (uses structured ProcessingResult fields)
        print('[TRACE] >>> DuplicateDetector.isDuplicate()...');
        final isDup = DuplicateDetector.isDuplicate(result, _resultHistory);
        print('[TRACE] <<< DuplicateDetector.isDuplicate() → $isDup (history size: ${_resultHistory.length})');
        if (isDup) {
          print('[Duplicate] Potential duplicate detected — skipping');
        }

        // Step 5: Auto-save if valid transaction and not duplicate
        print('[TRACE] >>> Decision: isTransaction=${result.isTransaction} && !isDup=${!isDup}');
        if (result.isTransaction && !isDup) {
          print('[TRACE] >>> _autoSaveTransaction()...');
          await _autoSaveTransaction(result);
          print('[TRACE] <<< _autoSaveTransaction() ✓');
        } else if (!result.isTransaction) {
          print('[Storage] Skipping — not a transaction');
        } else if (isDup) {
          print('[Storage] Skipping — duplicate');
        }

        // Add result to history (even duplicates — for future comparison)
        _resultHistory.add(result);
        // Keep history bounded
        if (_resultHistory.length > 100) {
          _resultHistory.removeAt(0);
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
    print('[TRACE] >>> TransactionMapper.toTransaction()...');
    final transaction = TransactionMapper.toTransaction(result);
    print('[TRACE] <<< TransactionMapper.toTransaction() → ${transaction == null ? 'NULL' : 'id=${transaction.id}'}');

    if (transaction == null) {
      print('[Mapper] Failed to map ProcessingResult — missing amount or not a transaction');
      return;
    }

    print('[Mapper] Mapped to Transaction: '
        'id=${transaction.id}, '
        'amount=${transaction.amount}, '
        'type=${transaction.typeLabel}, '
        'category=${transaction.category}, '
        'state=${transaction.state.name}, '
        'merchant_from_note=${transaction.note.split('\n').first}');

    // Save to Hive
    print('[TRACE] >>> TransactionDB.add(${transaction.id})...');
    print('[TRACE]   Transaction fields: id=${transaction.id}, amount=${transaction.amount}, type=${transaction.type}, category=${transaction.category}, state=${transaction.state}, createdAt=${transaction.createdAt}');
    try {
      await TransactionDB.add(transaction);
      print('[TRACE] <<< TransactionDB.add() ✓');
      print('[Repository] TransactionDB.add() succeeded (id: ${transaction.id})');
      print('[Storage] Transaction persisted to Hive (id: ${transaction.id})');
    } catch (e, stack) {
      print('[Storage][ERROR] Failed to persist transaction: $e');
      print('[Storage][ERROR] Stack trace: $stack');
      return;
    }

    // Verify by reading back
    print('[TRACE] >>> box.get(${transaction.id}) — verifying persistence...');
    final readBack = TransactionDB.get(transaction.id);
    print('[TRACE] <<< Transaction exists in Hive: ${readBack != null}');

    // Notify controller to refresh dashboard
    print('[TRACE] >>> _controller?.load()...');
    _controller?.load();
    print('[TRACE] <<< _controller?.load() ✓');
    print('[Dashboard] Controller notified — dashboard will refresh');
  }

  /// Decode the raw event into a [Map].
  Map<String, dynamic>? _decodePayload(dynamic event) {
    print('[TRACE]   _decodePayload: event is null? ${event == null}');
    print('[TRACE]   _decodePayload: event type = ${event?.runtimeType}');
    
    if (event == null) {
      print('[SMS][ERROR] Payload is null');
      return null;
    }

    if (event is! String) {
      print('[SMS][ERROR] Payload is not a string — it is ${event.runtimeType}');
      print('[SMS][ERROR] Payload value: ${event.toString().length > 200 ? event.toString().substring(0, 200) : event.toString()}');
      return null;
    }

    print('[TRACE]   _decodePayload: string length = ${event.length}');
    print('[TRACE]   _decodePayload: first 100 chars = ${event.length > 100 ? event.substring(0, 100) : event}');

    try {
      final decoded = jsonDecode(event);
      print('[TRACE]   _decodePayload: jsonDecode succeeded, type = ${decoded.runtimeType}');
      if (decoded is! Map<String, dynamic>) {
        print('[SMS][ERROR] Payload is not JSON — decoded type is ${decoded.runtimeType}');
        return null;
      }
      print('[TRACE]   _decodePayload: keys = ${decoded.keys}');
      return decoded;
    } catch (e) {
      print('[SMS][ERROR] Failed to decode JSON: $e');
      print('[SMS][ERROR] Raw payload (first 500 chars): ${event.length > 500 ? event.substring(0, 500) : event}');
      return null;
    }
  }

  /// Validate that the decoded map contains all required keys.
  bool _validatePayload(Map<String, dynamic> payload) {
    print('[TRACE]   _validatePayload: keys = ${payload.keys}');
    
    if (!payload.containsKey('version') || !payload.containsKey('event')) {
      print('[SMS][ERROR] Invalid payload schema: missing version or event');
      print('[SMS][ERROR]   has version=${payload.containsKey('version')}, has event=${payload.containsKey('event')}');
      return false;
    }

    if (!payload.containsKey('data') || payload['data'] is! Map) {
      print('[SMS][ERROR] Missing data object');
      print('[SMS][ERROR]   has data=${payload.containsKey('data')}, data type=${payload['data']?.runtimeType}');
      return false;
    }

    final data = payload['data'] as Map<String, dynamic>;
    print('[TRACE]   _validatePayload: data keys = ${data.keys}');

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

    print('[TRACE]   _validatePayload: ✓ all fields present');
    return true;
  }
}
