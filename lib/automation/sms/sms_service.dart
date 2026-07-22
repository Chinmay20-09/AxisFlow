import 'dart:convert';
import 'package:flutter/services.dart';

/// PHASE 2 — Structured JSON payload (string serialized).
///
/// Listens to the native EventChannel (`com.example.transaction/sms`) and
/// receives a **JSON string**. The string is decoded and validated to ensure
/// it contains at minimum `version` and `event` keys.
///
/// Future phases can extend the JSON object with additional keys (sender,
/// body, timestamp, etc.) without breaking this validation layer.
class SmsService {
  static const _channel = EventChannel('com.example.transaction/sms');

  bool _initialized = false;

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

        // Parse and validate the JSON string
        final decoded = _decodePayload(event);
        if (decoded == null) return;

        if (!_validatePayload(decoded)) return;

        // ignore: avoid_print
        print('[SMS] Payload validated');

        // Pretty-print the payload
        final formatted = const JsonEncoder.withIndent('  ').convert(decoded);
        // ignore: avoid_print
        print('[SMS] Event:\n$formatted');
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
  ///
  /// The native layer sends a JSON **string**, so we:
  /// 1. Check it's not null
  /// 2. Try to parse it with [jsonDecode]
  /// 3. Verify the result is a [Map]
  ///
  /// Returns `null` on any failure.
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

  /// Validate that the decoded map contains required keys.
  bool _validatePayload(Map<String, dynamic> payload) {
    if (!payload.containsKey('version') || !payload.containsKey('event')) {
      // ignore: avoid_print
      print('[SMS][ERROR] Invalid payload schema');
      return false;
    }
    return true;
  }
}
