import 'package:flutter/material.dart';
import 'package:axisflow/controller/transaction_controller.dart';
import 'package:axisflow/data/services/auth_service.dart';
import 'package:axisflow/data/services/settings_service.dart';
import 'package:axisflow/ui/screens/onboarding.dart';
import 'package:axisflow/ui/screens/home_screen.dart';
import 'package:axisflow/ui/screens/auth/login_screen.dart';

class AuthGate extends StatefulWidget {
  final TransactionController controller;
  const AuthGate({super.key, required this.controller});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    // Ensure settings and auth services are initialized
    await SettingsService.instance.init();
    await AuthService.instance.init();
    if (!mounted) return;
    setState(() => _initialized = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final onboardingComplete = SettingsService.instance.onboardingComplete;
    if (!onboardingComplete) {
      return OnboardingScreen(controller: widget.controller);
    }

    // If user null -> show login
    final user = AuthService.instance.currentUser;
    if (user == null) {
      return LoginScreen(controller: widget.controller);
    }

    // Signed in -> home
    return HomeScreen(controller: widget.controller);
  }
}
