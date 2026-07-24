// lib/main.dart
// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'data/local/transaction_db.dart';
import 'data/local/settings_db.dart';
import 'data/services/settings_service.dart';
import 'data/services/auth_service.dart';
import 'controller/transaction_controller.dart';
import 'core/theme/app_theme.dart';
import 'core/config/supabase_config.dart';
import 'ui/screens/auth/auth_gate.dart';
import 'automation/sms/sms_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Global navigator key so [SmsService] can show bottom sheets from
/// outside the widget tree.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Dark system UI
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppTheme.bg,
    ),
  );

  // ── LOG: STARTUP TRACE ────────────────────────────────────────────────────
  print('[TRACE] === MAIN START ===');

  // Init Hive
  print('[TRACE] TransactionDB.init()...');
  await TransactionDB.init();
  print('[TRACE] TransactionDB.init() ✓');

  // Init Settings DB (stores preferences like avatar path)
  print('[TRACE] SettingsDB.init()...');
  await SettingsDB.init();
  print('[TRACE] SettingsDB.init() ✓');

  // Initialize Supabase (requires filling lib/core/supabase_config.dart)
  print('[TRACE] Supabase.initialize()...');
  await Supabase.initialize(
    url: supabaseUrl,
    publishableKey: supabasePublishableKey,
  );
  print('[TRACE] Supabase.initialize() ✓');

  // Init SettingsService (loads persisted prefs)
  print('[TRACE] SettingsService.instance.init()...');
  await SettingsService.instance.init();
  print('[TRACE] SettingsService.instance.init() ✓');

  // Init AuthService (reads any persisted session)
  print('[TRACE] AuthService.instance.init()...');
  await AuthService.instance.init();
  print('[TRACE] AuthService.instance.init() ✓');

  // Init controller
  print('[TRACE] TransactionController()..load()...');
  final controller = TransactionController()..load();
  print('[TRACE] TransactionController.load() ✓ (count: ${controller.transactions.length})');

  // Init SMS bridge with auto-save integration
  print('[TRACE] SmsService()...');
  final smsService = SmsService();
  smsService.setController(controller);

  // Wire up app-resume sync: scan inbox for missed SMS when app
  // returns from background.
  smsService.onResume = () {
    controller.smsSyncService.sync().then((result) {
      if (result.hasNewData) {
        print('[SMS] Resume sync complete: $result');
        controller.load();
      }
    });
  };

  print('[TRACE] smsService.initialize()...');
  await smsService.initialize();
  print('[TRACE] smsService.initialize() ✓');

  // ── Automatic SMS sync on launch ─────────────────────────────────────
  // Pre-populate in-memory history for duplicate detection, then scan
  // the device inbox for any missed SMS since the last sync timestamp.
  // This runs fire-and-forget so it doesn't block app startup.
  print('[TRACE] SmsSyncService.prePopulateHistory()...');
  await controller.smsSyncService.prePopulateHistory();
  print('[TRACE] SmsSyncService.prePopulateHistory() ✓');
  controller.smsSyncService.sync().then((result) {
    print('[TRACE] Initial SMS sync complete: $result');
    controller.load();
  });

  print('[TRACE] runApp()...');
  runApp(AxisFlowApp(controller: controller));
  print('[TRACE] === MAIN DONE ===');
}

class AxisFlowApp extends StatelessWidget {
  final TransactionController controller;
  const AxisFlowApp({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    // Rebuild app when settings change so theme updates immediately
    return AnimatedBuilder(
      animation: SettingsService.instance,
      builder: (context, _) {
        return MaterialApp(
          navigatorKey: navigatorKey,
          title: 'AxisFlow',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.theme(SettingsService.instance.accentColor),
          home: AuthGate(controller: controller),
        );
      },
    );
  }
}
