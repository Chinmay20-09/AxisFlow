import 'package:flutter/material.dart';

/// MenuButton: opens the app drawer when a [scaffoldKey] is provided.
/// Falls back to a popup navigation menu when used outside a scaffold with a drawer.
import 'package:axisflow/controller/transaction_controller.dart';

class MenuButton extends StatelessWidget {
  final TransactionController? controller;
  final GlobalKey<ScaffoldState>? scaffoldKey;

  const MenuButton({super.key, this.controller, this.scaffoldKey});

  @override
  Widget build(BuildContext context) {
    if (scaffoldKey != null) {
      return IconButton(
        icon: const Icon(Icons.menu),
        onPressed: () => scaffoldKey!.currentState?.openDrawer(),
      );
    }

    // Fallback: popup menu with simple navigation stubs
    return PopupMenuButton<String>(
      tooltip: 'Menu',
      icon: const Icon(Icons.menu),
      onSelected: (value) {
        // create or reuse controller if provided
        // Simple route mapping: push target screens if needed
      },
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'home', child: Text('Home')),
        const PopupMenuItem(value: 'dashboard', child: Text('Dashboard')),
        const PopupMenuItem(value: 'transactions', child: Text('Transactions')),
        const PopupMenuItem(value: 'categories', child: Text('Categories')),
        const PopupMenuItem(value: 'budgets', child: Text('Budgets')),
        const PopupMenuItem(value: 'profile', child: Text('Profile')),
        const PopupMenuItem(value: 'alerts', child: Text('Alerts')),
        const PopupMenuItem(value: 'settings', child: Text('Settings')),
      ],
    );
  }
}
