import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:window_manager/window_manager.dart';
import 'package:musice/widgets/radio_header.dart';
import 'package:musice/widgets/play_section.dart';
import 'package:musice/widgets/volume_section.dart';
import 'package:musice/widgets/station_picker_sheet.dart';
import 'package:musice/models/station.dart';
import 'dart:async';
import 'package:musice/constants/app_constants.dart';
import 'package:musice/widgets/about_sheet.dart';
import 'package:musice/l10n/app_localizations.dart';
import 'package:musice/locale/locale_controller.dart';
import 'package:musice/widgets/language_picker_sheet.dart';
import 'package:musice/icons/app_icons.dart';
import 'package:provider/provider.dart';
import 'package:musice/providers/radio_provider.dart';

final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

Future<void> _activateDesktopWindow() async {
  try {
    // Make sure window is visible and focused
    await windowManager.show();
    await windowManager.focus();

    // Temporarily set always-on-top to help macOS bring the app forward
    await windowManager.setAlwaysOnTop(true);

    // Small delays to allow the window server to process focus changes
    await Future<void>.delayed(const Duration(milliseconds: 120));
    await windowManager.focus();

    // Remove always-on-top after activation
    await windowManager.setAlwaysOnTop(false);
  } catch (_) {
    // Best effort; ignore
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocaleController.instance.init();
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
      await _activateDesktopWindow();
      // Schedule another activation attempt shortly after to catch edge cases
      Future<void>.delayed(const Duration(milliseconds: 250), _activateDesktopWindow);
    });
  }
  runApp(const RadioApp());

  // As a final fallback, try to activate after the first frame is rendered.
  if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Fire-and-forget, no await inside post-frame
      _activateDesktopWindow();
    });
  }
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

    return ValueListenableBuilder<Locale?>(
      valueListenable: LocaleController.instance.locale,
      builder: (context, locale, _) {
        return MaterialApp(
          navigatorKey: appNavigatorKey,
          debugShowCheckedModeBanner: false,
          theme: theme,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: locale,
          home: const SplashScreen(),
        );
      },
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
        MaterialPageRoute(builder: (_) => const RadioScope()),
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

class RadioScope extends StatefulWidget {
  const RadioScope({super.key});
  @override
  State<RadioScope> createState() => _RadioScopeState();
}

class _RadioScopeState extends State<RadioScope> with SingleTickerProviderStateMixin {
  late final RadioProvider _radio;
  @override
  void initState() {
    super.initState();
    _radio = RadioProvider(this);
  }
  @override
  void dispose() {
    _radio.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<RadioProvider>.value(
      value: _radio,
      child: const RadioHomePage(),
    );
  }
}

class RadioHomePage extends StatefulWidget {
  const RadioHomePage({super.key});
  @override
  State<RadioHomePage> createState() => _RadioHomePageState();
}

class _RadioHomePageState extends State<RadioHomePage> {
  void _showErrorIfAny(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.read<RadioProvider>();
    final err = p.takeError();
    if (err == null) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(l10n.errorStartStream),
        action: SnackBarAction(
          label: l10n.retry,
          onPressed: () {
            p.play();
          },
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 6),
      ),
    );

    // Optional: provide a secondary way to see details
    // Long-press on the snackbar content is not feasible, so add a floating button in context menu
    // Here, we add a second snackbar with a "Details" action chained via closed callback if needed
    // but to keep UX simple, expose details via an alert if user taps the Retry button while it's still failing.
    // For explicit Details button in the UI header, we could add an overflow menu in future.

    // Alternatively, show a details dialog immediately as an optional second action using another snackbar.
    messenger.showSnackBar(
      SnackBar(
        content: Text(l10n.playbackErrorTitle),
        action: SnackBarAction(
          label: l10n.details,
          onPressed: () async {
            if (!mounted) return;
            final text = err.details;
            await showDialog<void>(
              context: context,
              builder: (ctx) => AlertDialog(
                backgroundColor: Colors.black,
                title: Text(l10n.playbackErrorTitle),
                content: SingleChildScrollView(child: Text(text, style: const TextStyle(color: Colors.white70))),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: Text(l10n.ok),
                  )
                ],
              ),
            );
          },
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 8),
      ),
    );
  }

  Future<void> _showStationPicker() async {
    final l10n = AppLocalizations.of(context)!;
    final p = context.read<RadioProvider>();
    final current = p.selected?.name;

    if (!mounted) return;

    Station? chosen;
    bool sheetThrew = false;
    try {
      chosen = await showModalBottomSheet<Station>(
        context: context,
        useRootNavigator: true,
        backgroundColor: Colors.black,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(kDefaultRadius)),
        ),
        builder: (context) => StationPickerSheet(stations: p.stations, current: current),
      );
    } catch (e) {
      sheetThrew = true;
      debugPrint('Bottom sheet failed: $e');
    }

    if (!mounted) return;

    if (sheetThrew && chosen == null) {
      try {
        chosen = await showDialog<Station>(
          context: context,
          barrierDismissible: true,
          builder: (context) => SimpleDialog(
            backgroundColor: Colors.black,
            title: Text(l10n.selectStation),
            children: p.stations.map((s) {
              final selected = s.name == current;
              return SimpleDialogOption(
                onPressed: () => Navigator.of(context).pop(s),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(s.name, style: const TextStyle(color: Colors.white)),
                    if (selected) const Icon(AppIcons.check, color: Colors.white70),
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

    if (!mounted) return;

    if (chosen != null) {
      context.read<RadioProvider>().selectStation(chosen);
    }
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
      builder: (context) => const AboutSheet(
        appName: kAppName,
        version: kAppVersion,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.watch<RadioProvider>();

    // Post-frame error check to surface playback errors via SnackBar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _showErrorIfAny(context);
    });

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        tooltip: l10n.aboutTooltip,
        onPressed: _showAbout,
        child: const Icon(AppIcons.info),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            RadioHeader(
              onStationsTap: _showStationPicker,
              onLanguageTap: () async {
                final current = LocaleController.instance.locale.value;
                final locale = await showModalBottomSheet<Locale?>(
                  context: context,
                  useRootNavigator: true,
                  backgroundColor: Colors.black,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(kDefaultRadius)),
                  ),
                  builder: (context) => LanguagePickerSheet(current: current),
                );
                if (!mounted) return;
                await LocaleController.instance.setLocale(locale);
              },
            ),
            Text(
              p.selected?.name ?? l10n.selectStation,
              style: const TextStyle(
                fontSize: kHeaderTitleFontSize,
                fontWeight: kHeaderTitleFontWeight,
              ),
            ),
            Expanded(
              child: PlaySection(
                isPlaying: p.isPlaying,
                isLoading: p.isLoading,
                volume: p.volume,
                reactiveLevel: p.reactiveLevel,
                onPlay: p.play,
                onPause: p.pause,
              ),
            ),
            VolumeSection(
              value: p.volume,
              onChanged: p.setVolume,
              onAnimated: p.setVolume,
            ),
          ],
        ),
      ),
    );
  }
}
