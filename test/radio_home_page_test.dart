import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:musice/main.dart';

void main() {
  testWidgets('RadioHomePage opens station picker modal', (tester) async {
    await tester.pumpWidget(const RadioApp());

    // Header shows current station name
    expect(find.text('Deep'), findsOneWidget);

    // Tap podcasts icon to open bottom sheet
    await tester.tap(find.byIcon(Icons.podcasts));
    await tester.pumpAndSettle();

    // Modal content appears
    expect(find.text('Select a station'), findsOneWidget);
  });

  testWidgets('Selecting a station does not switch to pause immediately', (tester) async {
    await tester.pumpWidget(const RadioApp());

    // Open station picker
    await tester.tap(find.byIcon(Icons.podcasts));
    await tester.pumpAndSettle();

    // Tap a station (pick Chill-Out to ensure a change)
    await tester.tap(find.text('Chill-Out'));

    // Pump to reflect immediate UI frame
    await tester.pump();

    // The main play button should still show play icon until actual stream starts
    expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    expect(find.byIcon(Icons.pause), findsNothing);
  });
}
