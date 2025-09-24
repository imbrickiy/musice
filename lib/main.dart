import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:math' as math;
import 'dart:io' show Platform;
import 'package:window_manager/window_manager.dart';
import 'package:musice/widgets/radio_header.dart';
import 'package:musice/widgets/play_section.dart';
import 'package:musice/widgets/volume_section.dart';
import 'package:musice/widgets/station_picker_sheet.dart';
import 'package:musice/models/station.dart';
import 'dart:async';
import 'package:musice/constants/app_constants.dart';

final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
    await windowManager.ensureInitialized();
    const size = kWindowSize; // iPhone 14 logical size (portrait)
    final options = WindowOptions(
      size: size,
      minimumSize: size,
      maximumSize: size,
      center: true,
      backgroundColor: Colors.black,
      titleBarStyle: Platform.isMacOS ? TitleBarStyle.hidden : TitleBarStyle.normal,
    );
    await windowManager.waitUntilReadyToShow(options, () async {
      await windowManager.setResizable(false);
      await windowManager.show();
      await windowManager.focus();
    });
  }
  runApp(const RadioApp());
}

class RadioApp extends StatelessWidget {
  const RadioApp({super.key});

  @override
  Widget build(BuildContext context) {
    final base = ThemeData(brightness: Brightness.dark, useMaterial3: true, fontFamily: 'SFPro');
    final scheme = ColorScheme.fromSeed(
      seedColor: kSeedColor,
      brightness: Brightness.dark,
    );
    final theme = base.copyWith(
      colorScheme: scheme,
      scaffoldBackgroundColor: kScaffoldBackgroundColor,
      iconTheme: const IconThemeData(color: kIconColor),
      textTheme: base.textTheme.copyWith(
        titleMedium: base.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, letterSpacing: 0.2),
        bodyMedium: base.textTheme.bodyMedium?.copyWith(height: 1.2),
      ),
      dividerColor: kDividerColor,
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Colors.transparent,
        foregroundColor: kIconColor,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        disabledElevation: 0,
        shape: CircleBorder(
          side: BorderSide(color: kBorderColor, width: 1),
        ),
      ),
    );

    return MaterialApp(
      navigatorKey: appNavigatorKey,
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: const SplashScreen(),
    );
  }
}

// Simple splash/loader screen shown at app startup
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Small delay to show the loader, then navigate to the home page
    Future<void>.delayed(kSplashDuration, () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const RadioHomePage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // App name / logo placeholder
              Text(
                kAppName,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 16),
              // Loader indicator
              const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(kIconColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RadioHomePage extends StatefulWidget {
  const RadioHomePage({super.key});

  @override
  State<RadioHomePage> createState() => _RadioHomePageState();
}

class _RadioHomePageState extends State<RadioHomePage> with SingleTickerProviderStateMixin {
  final AudioPlayer _player = AudioPlayer();

  String? selectedStationName = "Deep";
  String? selectedStationUrl = "https://hls-01-radiorecord.hostingradio.ru/record-deep/playlist.m3u8";

  // Available stations for selection
  final List<Station> _stations = kStations;

  double volume = 0.5;

  // Reactive level (0..1) used to modulate pulse visually
  late final AnimationController _reactCtrl;
  double _reactiveLevel = 0.0;

  StreamSubscription<PlayerState>? _playerStateSub;
  PlayerState? _lastPlayerState;

  bool get _isPlaying => _lastPlayerState?.playing == true;
  bool get _isLoading {
    final s = _lastPlayerState;
    if (s == null) return false;
    return s.processingState == ProcessingState.loading || s.processingState == ProcessingState.buffering;
  }

  @override
  void initState() {
    super.initState();
    _player.setVolume(volume);
    _reactCtrl = AnimationController(vsync: this, duration: kReactionDuration)
      ..addListener(() {
        final s = (math.sin(2 * math.pi * _reactCtrl.value) + 1) / 2; // 0..1
        _reactiveLevel = s * 0.8;
        if (mounted) setState(() {});
      });

    _playerStateSub = _player.playerStateStream.listen((state) {
      if (!mounted) return;
      setState(() {
        _lastPlayerState = state;
      });
      // Control wave animation based on playing
      if (state.playing) {
        if (!_reactCtrl.isAnimating) _reactCtrl.repeat();
      } else {
        if (_reactCtrl.isAnimating) _reactCtrl.stop();
      }
    });
  }

  // Show station picker modal
  Future<void> _showStationPicker() async {
    final current = selectedStationName;

    // If the widget is no longer mounted, do not proceed.
    if (!mounted) return;

    Station? chosen;
    bool sheetThrew = false;
    try {
      chosen = await showModalBottomSheet<Station>(
        context: context, // Use the 'context' from the mounted State.
        useRootNavigator: true,
        backgroundColor: Colors.black,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(kDefaultRadius)),
        ),
        builder: (context) => StationPickerSheet(stations: _stations, current: current),
      );
    } catch (e) {
      sheetThrew = true;
      debugPrint('Bottom sheet failed: $e');
    }

    // If the widget got disposed while awaiting the sheet, bail out.
    if (!mounted) return;

    // Fallback dialog only if presenting sheet actually failed.
    if (sheetThrew && chosen == null) {
      try {
        chosen = await showDialog<Station>(
          context: context, // Use the 'context' from the mounted State.
          barrierDismissible: true,
          builder: (context) => SimpleDialog(
            backgroundColor: Colors.black,
            title: const Text('Select a station'),
            children: _stations.map((s) {
              final selected = s.name == current;
              return SimpleDialogOption(
                onPressed: () => Navigator.of(context).pop(s),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(s.name, style: const TextStyle(color: Colors.white)),
                    if (selected) const Icon(Icons.check, color: Colors.white70),
                  ],
                ),
              );
            }).toList(),
          ),
        );
      } catch (e) {
        debugPrint('Dialog fallback failed: $e');
      }
    }

    // If the widget got disposed while awaiting the dialog, bail out.
    if (!mounted) return;

    if (chosen != null) {
      // Update station selection.
      setState(() {
        selectedStationName = chosen!.name;
        selectedStationUrl = chosen.url;
      });
      // Start playing the newly selected station.
      await _startStation(chosen.url);
    }
  }



  Future<void> _startStation(String url) async {
    try {
      await _player.stop();
      await _player.setUrl(url);
      await _player.play();
      // playerStateStream will flip UI to playing on success
    } catch (e) {
      debugPrint('Error starting stream: $e');
      // Keep UI in non-playing state; stream will reflect idle/ready not playing
    }
  }

  Future<void> _pause() async {
    await _player.pause();
    // playerStateStream will update UI to not playing and stop waves
  }

  void _showAbout() {
    if (!mounted) return;
    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.black,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(kDefaultRadius)),
      ),
      builder: (context) => const _AboutSheet(
        appName: kAppName,
        version: kAppVersion,
      ),
    );
  }

  @override
  void dispose() {
    _playerStateSub?.cancel();
    _reactCtrl.dispose();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        tooltip: 'О приложении',
        onPressed: _showAbout,
        child: const Icon(Icons.info_outline),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Header
            RadioHeader(
              title: selectedStationName ?? "Select a station",
              onStationsTap: _showStationPicker,
            ),

            // Play Button Section
            Expanded(
              child: PlaySection(
                isPlaying: _isPlaying,
                isLoading: _isLoading,
                volume: volume,
                reactiveLevel: _reactiveLevel,
                onPlay: () {
                  if (_isLoading) return; // ignore while loading
                  if (selectedStationUrl != null) {
                    _startStation(selectedStationUrl!);
                  }
                },
                onPause: () {
                  if (_isLoading) return; // ignore while loading
                  _pause();
                },
              ),
            ),

            // Volume Control Section
            VolumeSection(
              value: volume,
              onChanged: (value) {
                setState(() {
                  volume = value;
                });
              },
              onAnimated: (v) => _player.setVolume(v),
            ),
          ],
        ),
      ),
    );
  }
}

class _AboutSheet extends StatelessWidget {
  final String appName;
  final String version;
  const _AboutSheet({required this.appName, required this.version});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(kDefaultPadding, kDefaultPadding, kDefaultPadding, kDefaultPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              'Слушайте любимые станции и управляйте громкостью в реальном времени.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70, height: 1.25),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(kCopyright,
                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.white54)),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text('$appName v$version',
                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.white54)),
            ),
          ],
        ),
      ),
    );
  }
}
