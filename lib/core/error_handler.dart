import 'package:flutter/material.dart';

void showErrorSnackBar(BuildContext context, Object error, [String? message]) {
  final msg =
      message ??
      (error is Exception ? error.toString() : 'An unexpected error occurred');
  // Log to console for developers
  // ignore: avoid_print
  print('Error: $error');
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(msg), backgroundColor: Colors.redAccent),
  );
}
