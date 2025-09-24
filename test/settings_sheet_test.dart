import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:musice/main.dart';

void main() {
  testWidgets('Settings sheet opens from header and shows title', (tester) async {
    await tester.pumpWidget(const RadioApp());

    // Wait for splash screen to navigate to home
    await tester.pump(const Duration(milliseconds: 1300));
    await tester.pumpAndSettle();

    // Tap the settings button in header
    final settingsButton = find.byKey(const Key('settingsButton'));
    expect(settingsButton, findsOneWidget);
    await tester.tap(settingsButton);
    await tester.pumpAndSettle();

    // Settings content appears
    expect(find.text('Settings'), findsOneWidget);
  });
}

