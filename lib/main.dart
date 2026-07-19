// lib/main.dart
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
import 'package:supabase_flutter/supabase_flutter.dart';

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

  // Init Hive
  await TransactionDB.init();

  // Init Settings DB (stores preferences like avatar path)
  await SettingsDB.init();

  // Initialize Supabase (requires filling lib/core/supabase_config.dart)
  await Supabase.initialize(
    url: supabaseUrl,
    publishableKey: supabasePublishableKey,
  );

  // Init SettingsService (loads persisted prefs)
  await SettingsService.instance.init();

  // Init AuthService (reads any persisted session)
  await AuthService.instance.init();

  // Init controller
  final controller = TransactionController()..load();

  runApp(AxisFlowApp(controller: controller));
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
          title: 'AxisFlow',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.theme(SettingsService.instance.accentColor),
          home: AuthGate(controller: controller),
        );
      },
    );
  }
}
