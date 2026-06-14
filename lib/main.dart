// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'data/local/transaction_db.dart';
import 'data/local/settings_db.dart';
import 'controller/transaction_controller.dart';
import 'core/theme/app_theme.dart';
import 'ui/screens/home_screen.dart';
import 'ui/screens/onboarding.dart';

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

  // Init controller
  final controller = TransactionController()..load();

  runApp(AxisFlowApp(controller: controller));
}

class AxisFlowApp extends StatelessWidget {
  final TransactionController controller;
  const AxisFlowApp({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final onboardingComplete = SettingsDB.get<bool>('app.onboardingComplete', false) ?? false;

    return MaterialApp(
      title: 'AxisFlow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme.copyWith(
        colorScheme: AppTheme.theme.colorScheme.copyWith(
          primary: AppTheme.primary,
          secondary: AppTheme.accent
        ),
      ),
      home: onboardingComplete
          ? HomeScreen(controller: controller)
          : OnboardingScreen(controller: controller),
    );
  }
}
