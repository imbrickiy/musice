import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:musice/main.dart';

void main() {
  testWidgets('Builds at 1280x800 and shows core widgets', (tester) async {
    // Configure the virtual screen size for this test
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(1280, 800);
    addTearDown(() async {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      await tester.pumpAndSettle();
    });

    await tester.pumpWidget(const RadioApp());

    // Wait for splash to navigate to home
    await tester.pump(const Duration(milliseconds: 1300));
    await tester.pumpAndSettle();

    // Basic smoke checks on the home screen at this resolution
    expect(find.byIcon(Icons.podcasts), findsOneWidget);
    expect(find.byType(Slider), findsOneWidget);
    expect(find.byIcon(Icons.play_arrow), findsWidgets);
  });
}
