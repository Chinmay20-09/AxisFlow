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
import 'data/models/transaction_model.dart';
import 'ui/screens/popup_add_transaction.dart';
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

  // Wire up the bottom sheet to appear after a successful auto-save.
  smsService.onTransactionSaved = (data) {
    final context = navigatorKey.currentContext;
    if (context == null) {
      print('[SMS] Cannot show sheet — navigator context is null (app likely backgrounded)');
      return;
    }
    // Use smsService's own sheet-queue mechanism for stack prevention
    smsService.showSheetForTransaction(data);
  };

  // Wire up the actual sheet presentation using the navigator key.
  // When Done is pressed, update the transaction in Hive with the
  // user-confirmed category and note, then clear Needs Attention.
  smsService.onSheetReadyToShow = (data, onDismiss) {
    final context = navigatorKey.currentContext;
    if (context == null) {
      print('[SMS] Cannot show sheet — navigator context is null');
      onDismiss(); // release the queue slot
      return;
    }

    // Build a sheet with onDone wired to update the persisted transaction.
    final sheet = PopupAddTransaction.fromSavedData(
      data,
      onDismissed: onDismiss,
      onDone: (result) async {
        try {
          final tx = TransactionDB.get(result.transactionId);
          if (tx == null) {
            print('[SMS] Cannot update transaction ${result.transactionId} — not found in Hive');
            return;
          }
          tx.category = result.selectedCategory;
          tx.note = result.note;
          tx.state = TransactionState.completed;
          await TransactionDB.update(tx);
          controller.load();
          print('[SMS] Transaction ${result.transactionId} updated: category=${result.selectedCategory}');
        } catch (e) {
          print('[SMS] Failed to update transaction ${result.transactionId}: $e');
        }
      },
    );
    PopupAddTransaction.show(context, sheet: sheet);
  };

  print('[TRACE] smsService.initialize()...');
  await smsService.initialize();
  print('[TRACE] smsService.initialize() ✓');

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
