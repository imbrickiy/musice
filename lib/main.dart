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
import 'package:audio_session/audio_session.dart';
import 'package:musice/constants/app_constants.dart';
import 'package:musice/config/stations.dart';
import 'package:musice/services/stations_repository.dart';
import 'package:musice/screens/stations_settings_screen.dart';

// Global navigator key for use in non-widget code (e.g. services)

final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
    await windowManager.ensureInitialized();
    const size = Size(390, 844); // iPhone 14 logical size (portrait)
    final options = WindowOptions(
      size: size,
      minimumSize: size,
      maximumSize: size,
      center: true,
      backgroundColor: AppColors.black,
      titleBarStyle: Platform.isMacOS ? TitleBarStyle.hidden : TitleBarStyle.normal,
    );
    await windowManager.waitUntilReadyToShow(options, () async {
      await windowManager.setResizable(false);
      await windowManager.show();
      await windowManager.focus();
    });
  }

  // Configure audio session for platforms that support it (iOS/macOS)
  try {
    if (Platform.isIOS || Platform.isMacOS) {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());
    }
  } catch (e) {
    // Non-fatal: continue without explicit session config
    // Useful if platform/session not available
    debugPrint('Error configuring audio session: $e');

  }

  runApp(const RadioApp());
}

class RadioApp extends StatelessWidget {
  const RadioApp({super.key});

  @override
  Widget build(BuildContext context) {
    final base = ThemeData(brightness: Brightness.dark, useMaterial3: true, fontFamily: AppFonts.primary);
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.accent,
      brightness: Brightness.dark,
    );
    final theme = base.copyWith(
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.background,
      iconTheme: const IconThemeData(color: AppColors.icon),
      textTheme: base.textTheme.copyWith(
        headlineSmall: AppTextStyles.headline,
        titleMedium: AppTextStyles.title,
        titleSmall: AppTextStyles.overline,
        bodyMedium: AppTextStyles.body,
        bodySmall: AppTextStyles.captionMuted,
        labelLarge: AppTextStyles.button,
        labelSmall: AppTextStyles.labelCaps,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(style: AppButtons.filled()),
      textButtonTheme: TextButtonThemeData(style: AppButtons.outline()),
      outlinedButtonTheme: OutlinedButtonThemeData(style: AppButtons.outline()),
      dividerColor: AppColors.divider,
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.white70,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        disabledElevation: 0,
        shape: CircleBorder(
          side: BorderSide(color: AppColors.stroke, width: AppDimens.borderThin),
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
    Future<void>.delayed(const Duration(milliseconds: 1200), () {
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
                'Musice',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.m),
              // Loader indicator
              SizedBox(
                width: AppDimens.iconM,
                height: AppDimens.iconM,
                child: const CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.white70),
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

  // Stations state and source
  late final StationsRepository _stationsRepo;
  StreamSubscription<List<Station>>? _stationsSub;
  List<Station> _stations = stations;

  double volume = 0.5;

  // Reactive level (0..1) used to modulate pulse visually
  late final AnimationController _reactCtrl;
  double _reactiveLevel = 0.0;

  StreamSubscription<PlayerState>? _playerStateSub;
  PlayerState? _lastPlayerState;

  StreamSubscription<String>? _errorsSub;

  bool get _isPlaying => _lastPlayerState?.playing == true;
  bool get _isLoading {
    final s = _lastPlayerState;
    if (s == null) return false;
    return s.processingState == ProcessingState.loading || s.processingState == ProcessingState.buffering;
  }

  bool get _showReload => !_stationsRepo.supportsWatch;

  @override
  void initState() {
    super.initState();
    _player.setVolume(volume);

    _stationsRepo = StationsRepository(fallback: stations);
    _initStations();

    // Listen for repository errors and show SnackBars
    _errorsSub = _stationsRepo.errors.listen((msg) {
      if (!mounted) return;
      final messenger = ScaffoldMessenger.maybeOf(context);
      messenger?.showSnackBar(
        SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating, duration: const Duration(seconds: 3)),
      );
    });

    _reactCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
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

  Future<void> _initStations() async {
    // Load initial set
    final initial = await _stationsRepo.load();
    if (!mounted) return;
    setState(() {
      _stations = initial;
      _ensureSelectionValid();
    });
    // Start watch stream (desktop only when enabled)
    _stationsSub = _stationsRepo.watch().listen((list) {
      if (!mounted || list.isEmpty) return;
      setState(() {
        _stations = list;
        _ensureSelectionValid();
      });
    });
  }

  void _ensureSelectionValid() {
    if (_stations.isEmpty) return; // nothing to select
    final hasCurrent = selectedStationName != null &&
        _stations.any((s) => s.name == selectedStationName);
    if (!hasCurrent) {
      // pick first available and optionally start playing
      final first = _stations.first;
      selectedStationName = first.name;
      selectedStationUrl = first.url;
    }
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
        backgroundColor: AppColors.black,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.m)),
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
            backgroundColor: AppColors.black,
            title: const Text('Select a station'),
            children: _stations.map((s) {
              final selected = s.name == current;
              return SimpleDialogOption(
                onPressed: () => Navigator.of(context).pop(s),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(s.name, style: AppTextStyles.body),
                    if (selected) const Icon(Icons.check, color: AppColors.white70),
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
      backgroundColor: AppColors.black,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.m)),
      ),
      builder: (context) => const _AboutSheet(
        appName: 'Musice',
        version: '1.0.0',
      ),
    );
  }

  Future<void> _reloadStations() async {
    final list = await _stationsRepo.load();
    if (!mounted) return;
    setState(() {
      _stations = list;
      _ensureSelectionValid();
    });
    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger?.showSnackBar(
      const SnackBar(content: Text('Stations reloaded'), behavior: SnackBarBehavior.floating, duration: Duration(seconds: 2)),
    );
  }

  Future<void> _openStationsSettings() async {
    final updated = await Navigator.of(context).push<List<Station>>(
      MaterialPageRoute(
        builder: (_) => StationsSettingsScreen(repo: _stationsRepo, initial: _stations),
        fullscreenDialog: true,
      ),
    );
    if (!mounted) return;
    if (updated != null) {
      setState(() {
        _stations = updated;
        _ensureSelectionValid();
      });
    }
  }

  @override
  void dispose() {
    _playerStateSub?.cancel();
    _reactCtrl.dispose();
    _stationsSub?.cancel();
    _errorsSub?.cancel();
    _stationsRepo.dispose();
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
              onReload: _showReload ? _reloadStations : null,
              showReload: _showReload,
              onSettings: _openStationsSettings,
              showSettings: true,
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
        padding: const EdgeInsets.fromLTRB(AppSpacing.m, AppSpacing.m, AppSpacing.m, AppSpacing.m),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title
            Center(child: Text(appName, style: theme.textTheme.titleMedium)),
            const SizedBox(height: AppSpacing.s),
            // Description
            Text(
              'Слушайте любимые станции и управляйте громкостью в реальном времени.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.white70),
            ),
            const SizedBox(height: AppSpacing.s),
            // Labels
            Center(child: Text('imbrickiy © 2025', style: theme.textTheme.bodySmall)),
            const SizedBox(height: AppSpacing.s),
            Center(child: Text('$appName v$version', style: theme.textTheme.bodySmall)),
            const SizedBox(height: AppSpacing.s),
            Align(
              alignment: Alignment.center,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
