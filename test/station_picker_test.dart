import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:musice/widgets/station_picker_sheet.dart';
import 'package:musice/models/station.dart';
import 'package:musice/l10n/app_localizations.dart';
import 'package:musice/providers/radio_provider.dart';
import 'package:just_audio/just_audio.dart';

class FakeAudioPlayer extends AudioPlayer {
  final StreamController<PlayerState> _stateCtrl = StreamController<PlayerState>.broadcast();

  FakeAudioPlayer() {
    // initial state: not playing
    _stateCtrl.add(PlayerState(false, ProcessingState.idle));
  }

  @override
  Stream<PlayerState> get playerStateStream => _stateCtrl.stream;

  @override
  Future<void> setVolume(double volume) async {}

  @override
  Future<void> stop() async {}

  @override
  Future<Duration?> setAudioSource(AudioSource source, {bool preload = true, int? initialIndex, Duration? initialPosition}) async {
    // simulate immediate readiness with null duration
    return null;
  }

  @override
  Future<void> play() async {
    _stateCtrl.add(PlayerState(true, ProcessingState.ready));
  }

  @override
  Future<void> pause() async {
    _stateCtrl.add(PlayerState(false, ProcessingState.ready));
  }

  @override
  Future<void> dispose() async {
    await _stateCtrl.close();
    return super.dispose();
  }
}

class TestHost extends StatefulWidget {
  final Widget child;
  final List<Station> initialStations;
  const TestHost({super.key, required this.child, required this.initialStations});
  @override
  State<TestHost> createState() => _TestHostState();
}

class _TestHostState extends State<TestHost> with SingleTickerProviderStateMixin {
  late final RadioProvider radio;

  @override
  void initState() {
    super.initState();
    radio = RadioProvider(this, audioPlayer: FakeAudioPlayer(), initialDefaultStations: widget.initialStations);
  }

  @override
  void dispose() {
    radio.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: ChangeNotifierProvider<RadioProvider>.value(
        value: radio,
        child: Scaffold(body: widget.child),
      ),
    );
  }
}

void main() {
  testWidgets('StationPickerSheet shows stations and edit icon', (tester) async {
    final stations = [
      const Station('Deep', 'https://example.com/deep.m3u8'),
      const Station('Chill-Out', 'https://example.com/chill.m3u8'),
    ];

    await tester.pumpWidget(
      TestHost(
        initialStations: stations,
        child: const StationPickerSheet(),
      ),
    );

    // Let provider initialize
    await tester.pumpAndSettle();

    // Station names present
    expect(find.text('Deep'), findsOneWidget);
    expect(find.text('Chill-Out'), findsOneWidget);

    // There should be at least one edit icon (Icons.edit)
    expect(find.byIcon(Icons.edit), findsWidgets);
  });
}
