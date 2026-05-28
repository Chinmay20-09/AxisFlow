import 'package:flutter/material.dart';

class MenuButton extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const MenuButton({super.key, required this.scaffoldKey});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.reorder),
      onPressed: () {
        scaffoldKey.currentState?.openDrawer();
      },
    );
  }
}
