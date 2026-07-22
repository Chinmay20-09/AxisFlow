import 'dart:convert';
import 'package:flutter/services.dart';
import 'models/sms_event.dart';
import 'models/processing_result.dart';
import 'services/bank_detector.dart';
import 'services/transaction_parser.dart';
import 'services/duplicate_detector.dart';

/// PHASE 4-7 — Complete processing pipeline for automatic transaction detection.
///
/// Listens to the native EventChannel (`com.example.transaction/sms`), receives
/// the JSON payload with sender, timestamp, and body, then runs the full
/// processing chain:
///
///   SmsEvent → BankDetector → TransactionParser → DuplicateDetector → ProcessingResult
///
/// No UI, no Hive, no analytics, no AI — only the processing pipeline.
class SmsService {
  static const _channel = EventChannel('com.example.transaction/sms');

  bool _initialized = false;

  /// In-memory history of received events (for duplicate detection).
  final List<SmsEvent> _eventHistory = [];

  /// Callback invoked when an SMS is fully processed.
  /// Set this to receive processing results.
  void Function(ProcessingResult result)? onProcessed;

  /// Start listening to native SMS events.
  /// Safe to call multiple times (only initializes once).
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    // ignore: avoid_print
    print('[SMS] SmsService initialize()');

    _channel.receiveBroadcastStream().listen(
      (event) {
        // ignore: avoid_print
        print('[SMS] Raw payload received');

        // Step 1: Decode and create SmsEvent
        final decoded = _decodePayload(event);
        if (decoded == null) return;

        if (!_validatePayload(decoded)) return;

        // ignore: avoid_print
        print('[SMS] Payload validated');

        final smsEvent = SmsEvent.fromJson(decoded);
        // ignore: avoid_print
        print('[SMS] Event: sender=${smsEvent.sender}, '
            'body="${smsEvent.body.length > 60 ? '${smsEvent.body.substring(0, 60)}...' : smsEvent.body}"');

        // Step 2: Detect bank
        final bankResult = BankDetector.detect(smsEvent.sender);
        // ignore: avoid_print
        print('[Bank] Detected: ${bankResult.displayName} '
            '(confidence: ${bankResult.confidence.toStringAsFixed(2)})');

        // Step 3: Parse transaction fields
        final parsed = TransactionParser.parseBody(smsEvent.body);
        // ignore: avoid_print
        print('[Parser] Amount: ${parsed.amount}, '
            'Merchant: ${parsed.merchant}, '
            'Balance: ${parsed.balance}, '
            'Ref: ${parsed.referenceNumber}');

        // Step 4: Check for duplicates
        final isDup = DuplicateDetector.isDuplicate(smsEvent, _eventHistory);
        // ignore: avoid_print
        if (isDup) {
          print('[Duplicate] Potential duplicate detected — skipping');
        }

        // Step 5: Build ProcessingResult (always, even if duplicate)
        final result = TransactionParser.processEvent(smsEvent);
        // ignore: avoid_print
        print('[Processing] Result: '
            'isTransaction=${result.isTransaction}, '
            'bank=${result.bank}, '
            'amount=${result.amount}, '
            'merchant=${result.merchant}, '
            'balance=${result.balance}, '
            'type=${result.transactionType.name}, '
            'confidence=${result.confidence.toStringAsFixed(2)}');

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
        // ignore: avoid_print
        print('[SMS][ERROR] Stream error: $error');
      },
      onDone: () {
        // ignore: avoid_print
        print('[SMS] Stream closed');
      },
    );

    // ignore: avoid_print
    print('[SMS] EventChannel connected');
    // ignore: avoid_print
    print('[SMS] Waiting for SMS...');
  }

  /// Decode the raw event into a [Map].
  Map<String, dynamic>? _decodePayload(dynamic event) {
    if (event == null) {
      // ignore: avoid_print
      print('[SMS][ERROR] Payload is null');
      return null;
    }

    if (event is! String) {
      // ignore: avoid_print
      print('[SMS][ERROR] Payload is not a string');
      return null;
    }

    try {
      final decoded = jsonDecode(event);
      if (decoded is! Map<String, dynamic>) {
        // ignore: avoid_print
        print('[SMS][ERROR] Payload is not JSON');
        return null;
      }
      return decoded;
    } catch (e) {
      // ignore: avoid_print
      print('[SMS][ERROR] Failed to decode JSON: $e');
      return null;
    }
  }

  /// Validate that the decoded map contains all required keys.
  bool _validatePayload(Map<String, dynamic> payload) {
    if (!payload.containsKey('version') || !payload.containsKey('event')) {
      // ignore: avoid_print
      print('[SMS][ERROR] Invalid payload schema: missing version or event');
      return false;
    }

    if (!payload.containsKey('data') || payload['data'] is! Map) {
      // ignore: avoid_print
      print('[SMS][ERROR] Missing data object');
      return false;
    }

    final data = payload['data'] as Map<String, dynamic>;

    if (!data.containsKey('sender')) {
      // ignore: avoid_print
      print('[SMS][ERROR] Missing sender');
      return false;
    }

    if (!data.containsKey('timestamp')) {
      // ignore: avoid_print
      print('[SMS][ERROR] Missing timestamp');
      return false;
    }

    if (!data.containsKey('body')) {
      // ignore: avoid_print
      print('[SMS][ERROR] Missing body');
      return false;
    }

    return true;
  }
}
