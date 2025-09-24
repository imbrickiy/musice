import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:musice/main.dart';

void main() {
  testWidgets('About sheet opens from FAB and shows app name and version', (tester) async {
    await tester.pumpWidget(const RadioApp());

    // Wait for splash then settle into home screen
    await tester.pump(const Duration(milliseconds: 1300));
    await tester.pumpAndSettle();

    // Tap the info FAB
    await tester.tap(find.byIcon(Icons.info_outline));
    await tester.pumpAndSettle();

    // About content appears
    expect(find.textContaining('Musice v1.0.0'), findsOneWidget);
  });
}

