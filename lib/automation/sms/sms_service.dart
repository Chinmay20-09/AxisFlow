import 'package:flutter/services.dart';

/// PHASE 1 — Minimal SMS bridge.
///
/// Listens to the native EventChannel (`com.example.transaction/sms`) and
/// prints `[SMS] Event received: SMS_RECEIVED` whenever an SMS arrives.
///
/// NO body, NO sender, NO timestamp is transmitted from the native layer.
/// Only the string `"SMS_RECEIVED"` is sent.
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
        print('[SMS] Event received: $event');
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
}
