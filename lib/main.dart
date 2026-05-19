// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'data/transaction_db.dart';
import 'controller/transaction_controller.dart';
import '../ui/app_theme.dart';
import '../ui/screens/home_screen.dart';

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

  // Init controller
  final controller = TransactionController()..load();

  runApp(AxisFlowApp(controller: controller));
}

class AxisFlowApp extends StatelessWidget {
  final TransactionController controller;
  const AxisFlowApp({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AxisFlow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: HomeScreen(controller: controller),
    );
  }
}
