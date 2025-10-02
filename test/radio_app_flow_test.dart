import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:musice/widgets/radio_header.dart';
import 'package:musice/widgets/play_section.dart';
import 'package:musice/models/station.dart';
import 'package:musice/l10n/app_localizations.dart';

class FakeRadioProvider extends ChangeNotifier {
  final List<Station> _stations;
  Station? _selected;
  bool _isPlaying = false;
  bool _isLoading = false;
  double _volume = 0.5;
  double _reactive = 0.0;

  FakeRadioProvider(List<Station> stations)
      : _stations = List<Station>.from(stations) {
    if (_stations.isNotEmpty) _selected = _stations.first;
  }

  List<Station> get stations => _stations;
  List<Station> get defaultStations => _stations;
  Station? get selected => _selected;
  double get volume => _volume;
  double get reactiveLevel => _reactive;
  bool get isPlaying => _isPlaying;
  bool get isLoading => _isLoading;

  void selectStation(Station s) {
    _selected = s;
    notifyListeners();
  }

  Future<void> play() async {
    _isPlaying = true;
    notifyListeners();
  }

  Future<void> pause() async {
    _isPlaying = false;
    notifyListeners();
  }

  void setVolume(double v) {
    _volume = v;
    notifyListeners();
  }
}

void main() {
  testWidgets('Radio flow with fake provider: select station and play', (tester) async {
    final stations = [
      const Station('Deep', 'https://example.com/deep.m3u8'),
      const Station('Chill-Out', 'https://example.com/chill.m3u8'),
    ];

    final provider = FakeRadioProvider(stations);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ChangeNotifierProvider<FakeRadioProvider>.value(
          value: provider,
          child: Scaffold(
            body: Column(
              children: [
                RadioHeader(onStationsTap: () {}, onSettingsTap: null),
                // Show current station name
                Builder(builder: (ctx) {
                  final p = ctx.watch<FakeRadioProvider>();
                  return Text(p.selected?.name ?? 'No station');
                }),
                PlaySection(
                  isPlaying: provider.isPlaying,
                  isLoading: provider.isLoading,
                  volume: provider.volume,
                  reactiveLevel: provider.reactiveLevel,
                  onPlay: provider.play,
                  onPause: provider.pause,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // initial station shown
    expect(find.text('Deep'), findsOneWidget);

    // Simulate user selecting Chill-Out via provider (avoid pumping StationPickerSheet)
    provider.selectStation(stations[1]);
    await tester.pumpAndSettle();

    // selection reflected in UI
    expect(find.text('Chill-Out'), findsOneWidget);

    // test play/pause
    expect(provider.isPlaying, isFalse);
    await tester.tap(find.byIcon(Icons.play_arrow));
    await tester.pumpAndSettle();
    expect(provider.isPlaying, isTrue);
  });
}
