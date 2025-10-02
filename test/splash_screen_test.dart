import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:musice/widgets/splash_screen.dart';

void main() {
  testWidgets('SplashScreen shows loader and navigates after delay', (tester) async {
    bool navigated = false;
    await tester.pumpWidget(
      MaterialApp(
        home: SplashScreen(nextPageBuilder: (_) {
          navigated = true;
          return const Scaffold(body: Text('NextPage'));
        }),
      ),
    );
    // Loader is visible
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    // Not navigated yet
    expect(navigated, isFalse);
    // Wait for splash duration + settle
    await tester.pump(const Duration(milliseconds: 1300));
    await tester.pumpAndSettle();
    // Navigated
    expect(navigated, isTrue);
    expect(find.text('NextPage'), findsOneWidget);
  });
}

