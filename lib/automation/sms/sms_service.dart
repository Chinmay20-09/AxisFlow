// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models/sms_event.dart';
import 'models/processing_result.dart';
import 'services/bank_detector.dart';
import 'services/transaction_parser.dart';
import 'services/duplicate_detector.dart';
import 'services/transaction_mapper.dart';
import 'package:axisflow/data/local/transaction_db.dart';
import 'package:axisflow/data/models/transaction_model.dart';
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
class SmsService with WidgetsBindingObserver {
  static const _channel = EventChannel('com.example.transaction/sms');

  bool _initialized = false;

  /// In-memory history of processed results (for duplicate detection).
  ///
  /// Stores [ProcessingResult] objects so [DuplicateDetector] can compare
  /// structured fields (amount, merchant, reference) without parsing raw SMS.
  final List<ProcessingResult> _resultHistory = [];

  /// The controller used to refresh the UI after saving.
  TransactionController? _controller;

  /// Whether the app is currently in the foreground.
  bool _isInForeground = true;

  /// Guards against concurrent SMS event processing.
  ///
  /// The event channel callback is `async`, so two events can interleave
  /// when the first one suspends at `await _autoSaveTransaction()`.
  /// This causes a race where the second event doesn't see the first
  /// event's transaction in the DB or in-memory history, leading to
  /// duplicate saves and duplicate popups.
  ///
  /// When `true`, the event is silently skipped — it's almost certainly
  /// a duplicate Android broadcast of the same SMS.
  bool _isProcessing = false;

  /// Set the controller to enable automatic dashboard refresh on save.
  void setController(TransactionController controller) {
    _controller = controller;
  }

  /// Callback invoked when an SMS is fully processed.
  /// Set this to receive processing results.
  void Function(ProcessingResult result)? onProcessed;

  /// Callback invoked when the app returns from background.
  /// Used by main.dart to trigger SMS sync on app resume.
  VoidCallback? onResume;

  /// Register this service as a lifecycle observer to track foreground state.
  void _registerLifecycle() {
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final wasInForeground = _isInForeground;
    _isInForeground = state == AppLifecycleState.resumed;
    print('[TRACE] SmsService lifecycle: state=$state, isInForeground=$_isInForeground');

    // Trigger sync when app returns to foreground (was backgrounded).
    if (!wasInForeground && _isInForeground) {
      print('[SMS] App resumed from background — triggering SMS sync');
      onResume?.call();
    }
  }

  /// Start listening to native SMS events.
  /// Safe to call multiple times (only initializes once).
  Future<void> initialize() async {
    // Register lifecycle observer
    _registerLifecycle();

    // LOG: verify initialize() called once
    // LOG: verify initialize() called once
    print('[TRACE] SmsService.initialize(): _initialized was $_initialized before guard');
    if (_initialized) {
      print('[TRACE] SmsService.initialize(): SKIP — already initialized');
      return;
    }
    _initialized = true;
    print('[TRACE] SmsService.initialize(): _initialized now true (first call)');

    print('[SMS] SmsService initialize()');

    // Pre-populate _resultHistory from existing database transactions
    // so that duplicate detection works across app restarts.
    print('[TRACE] Pre-populating _resultHistory from TransactionDB...');
    try {
      final existingTxns = TransactionDB.getAll();
      for (final tx in existingTxns) {
        _resultHistory.add(_txToProcessingResult(tx));
      }
      print('[TRACE] Pre-populated _resultHistory with ${_resultHistory.length} existing transactions');
    } catch (e) {
      print('[TRACE] Could not pre-populate _resultHistory: $e');
    }

    print('[TRACE] EventChannel receiveBroadcastStream().listen() — subscribing...');
    _channel.receiveBroadcastStream().listen(
      (event) async {
        print('[TRACE] ===== EVENT CHANNEL CALLBACK FIRED =====');

        // ── Processing guard: skip if another event is currently ──────
        // being processed. This prevents the async interleaving race
        // where two events for the same SMS both pass duplicate detection
        // because neither sees the other's saved transaction yet.
        if (_isProcessing) {
          print('[SMS] Already processing an SMS event — skipping (likely duplicate broadcast)');
          return;
        }
        _isProcessing = true;
        try {
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

          // Step 4: Check for duplicates — first in-memory (fast path),
          // then database (persistent source of truth).
          final hash = result.hashCode;
          print('[TRACE] >>> DuplicateDetector.isDuplicate() (hash=$hash)...');
          final isDupInMemory = DuplicateDetector.isDuplicate(result, _resultHistory);
          print('[TRACE] <<< DuplicateDetector.isDuplicate() → $isDupInMemory (history size: ${_resultHistory.length})');

          // Step 4b: Database-level duplicate check before saving.
          // This catches duplicates across app restarts or if in-memory history
          // is somehow incomplete.
          print('[TRACE] >>> DuplicateDetector.existsInDatabase()...');
          final existingTxns = TransactionDB.getAll();
          final isDupInDb = DuplicateDetector.existsInDatabase(result, existingTxns);
          print('[TRACE] <<< DuplicateDetector.existsInDatabase() → $isDupInDb');

          final isDup = isDupInMemory || isDupInDb;
          if (isDup) {
            print('[Duplicate] Potential duplicate detected — skipping (memory=$isDupInMemory, db=$isDupInDb)');
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
          if (_resultHistory.length > 200) {
            _resultHistory.removeAt(0);
          }

          // Notify listener
          onProcessed?.call(result);
        } finally {
          // Release processing guard — ALWAYS, even on early returns
          // or exceptions. This prevents permanently blocking SMS
          // processing if a payload validation fails or an error occurs.
          _isProcessing = false;
        }
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

    // Transaction is now visible in the Alerts screen via the controller.
    // The user can review it at their own pace by tapping "Review" on the
    // pending transaction card. No popup is shown automatically.
  }

  /// Extract merchant from transaction note ("Merchant: ...").
  String _extractMerchantFromNote(String note) {
    for (final line in note.split('\n')) {
      if (line.startsWith('Merchant: ')) {
        return line.substring('Merchant: '.length).trim();
      }
    }
    return 'Unknown Merchant';
  }

  /// Extract bank from transaction note ("Bank: ...").
  String _extractBankFromNote(String note) {
    for (final line in note.split('\n')) {
      if (line.startsWith('Bank: ')) {
        return line.substring('Bank: '.length).trim();
      }
    }
    return 'Unknown Bank';
  }

  /// Convert an existing [Transaction] into a rough [ProcessingResult]
  /// for duplicate detection across restarts.
  ProcessingResult _txToProcessingResult(Transaction tx) {
    final sender = _extractSenderFromNote(tx.note);
    final merchant = _extractMerchantFromNote(tx.note);
    final ref = _extractRefFromNote(tx.note);
    return ProcessingResult(
      isTransaction: true,
      bank: _extractBankFromNote(tx.note),
      amount: tx.amount,
      merchant: merchant,
      referenceNumber: ref,
      sender: sender,
      timestamp: tx.createdAt.millisecondsSinceEpoch,
      rawSms: tx.note, // note includes the original SMS
      confidence: 1.0,
    );
  }

  /// Extract sender from transaction note line ("Sender: ...").
  String _extractSenderFromNote(String note) {
    for (final line in note.split('\n')) {
      if (line.startsWith('Sender: ')) {
        return line.substring('Sender: '.length).trim();
      }
    }
    return '';
  }

  /// Extract reference from transaction note line ("Ref: ...").
  String? _extractRefFromNote(String note) {
    for (final line in note.split('\n')) {
      if (line.startsWith('Ref: ')) {
        return line.substring('Ref: '.length).trim();
      }
    }
    return null;
  }

  /// No popup is shown anymore — all pending transactions appear in
  /// the Alerts screen where the user can review them in batch.

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
