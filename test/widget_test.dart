// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:axisflow/controller/transaction_controller.dart';
import 'package:axisflow/main.dart';

void main() {
  testWidgets('App loads and opens add sheet', (WidgetTester tester) async {
    final controller = TransactionController();
    await tester.pumpWidget(AxisFlowApp(controller: controller));

    // Verify the FAB '+' exists
    expect(find.byIcon(Icons.add), findsOneWidget);

    // Tap the '+' icon and open add transaction sheet.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    // Verify the add sheet is shown with header text
    expect(find.text('New transaction'), findsOneWidget);
  });
}
