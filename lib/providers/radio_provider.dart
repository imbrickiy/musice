import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:musice/models/station.dart';
import 'package:musice/constants/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:musice/settings/settings_controller.dart';
import 'package:musice/services/station_storage.dart';
import 'package:musice/services/default_stations_service.dart';
import 'package:musice/l10n/app_localizations.dart';
import 'package:musice/widgets/add_station_sheet.dart';

class PlaybackError {
  final String details;
  final DateTime time;
  const PlaybackError({required this.details, required this.time});
}

class RadioProvider with ChangeNotifier {
  static const _prefsKeyLastStation = 'last_station_name';

  final AudioPlayer _player = AudioPlayer();
  // Начинаем с пустого списка, станции загружаются асинхронно
  final List<Station> _stations = <Station>[];
  List<Station> _defaultStations = <Station>[];
  Station? _selected;
  double _volume = 0.5;
  double _reactiveLevel = 0.0;
  PlayerState? _lastPlayerState;
  Timer? _retryTimer;
  int _retryAttempts = 0;
  PlaybackError? _lastError;

  late final AnimationController _reactCtrl;

  RadioProvider(TickerProvider vsync) {
    _player.setVolume(_volume);
    _reactCtrl = AnimationController(vsync: vsync, duration: kReactionDuration)
      ..addListener(() {
        final s = (math.sin(2 * math.pi * _reactCtrl.value) + 1) / 2;
        _reactiveLevel = s * 0.8;
        notifyListeners();
      });

    _player.playerStateStream.listen((state) {
      _lastPlayerState = state;
      if (state.playing) {
        if (!_reactCtrl.isAnimating) _reactCtrl.repeat();
      } else {
        if (_reactCtrl.isAnimating) _reactCtrl.stop();
      }
      notifyListeners();
    });

    // Загружаем станции асинхронно
    _initAsync();
  }

  Future<void> _initAsync() async {
    await _loadDefaultStations();
    await _loadUserStations();
    await _loadRememberedStationIfAny();
  }

  Future<void> _loadDefaultStations() async {
    try {
      _defaultStations = await DefaultStationsService.instance.loadDefaultStations();
      _stations.addAll(_defaultStations);
      _selected ??= _stations.isNotEmpty ? _stations.first : null;
      notifyListeners();
    } catch (_) {
      // ignore
    }
  }

  Future<void> _loadUserStations() async {
    try {
      final loaded = await StationStorage.instance.loadStations();
      if (loaded.isEmpty) return;
      // Для каждой загруженной станции: если существует по имени, заменяем (переопределение URL), иначе вставляем в начало
      for (final s in loaded) {
        final idx = _stations.indexWhere((e) => e.name == s.name);
        if (idx >= 0) {
          _stations.removeAt(idx);
        }
        _stations.insert(0, s);
      }
      _selected ??= _stations.first;
      notifyListeners();
    } catch (_) {
      // ignore
    }
  }

  Future<void> _loadRememberedStationIfAny() async {
    try {
      if (!SettingsController.instance.rememberLastStation.value) return;
      final prefs = await SharedPreferences.getInstance();
      final name = prefs.getString(_prefsKeyLastStation);
      if (name == null) return;
      final found = _stations.where((s) => s.name == name);
      if (found.isNotEmpty) {
        _selected = found.first;
        notifyListeners();
      }
    } catch (_) {
      // ignore
    }
  }

  List<Station> get stations => _stations;
  List<Station> get defaultStations => _defaultStations;
  Station? get selected => _selected;
  double get volume => _volume;
  double get reactiveLevel => _reactiveLevel;
  bool get isPlaying => _lastPlayerState?.playing == true;
  bool get isLoading =>
      _lastPlayerState?.processingState == ProcessingState.loading ||
      _lastPlayerState?.processingState == ProcessingState.buffering;

  PlaybackError? takeError() {
    final err = _lastError;
    _lastError = null;
    return err;
  }

  void setVolume(double value) {
    _volume = value;
    _player.setVolume(value);
    notifyListeners();
  }

  Future<void> _persistSelectedIfNeeded() async {
    if (!SettingsController.instance.rememberLastStation.value) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_selected == null) {
        await prefs.remove(_prefsKeyLastStation);
      } else {
        await prefs.setString(_prefsKeyLastStation, _selected!.name);
      }
    } catch (_) {
      // ignore
    }
  }

  void selectStation(Station station) {
    _selected = station;
    _persistSelectedIfNeeded();
    _startStationWithBackoff(station.url);
    notifyListeners();
  }

  Future<void> play() async {
    if (selected != null) {
      await _startStationWithBackoff(selected!.url);
    }
  }

  Future<void> pause() async {
    _cancelBackoff();
    await _player.pause();
  }

  Future<void> _startStationWithBackoff(
    String url, {
    int maxAttempts = 3,
  }) async {
    _cancelBackoff();
    _retryAttempts = 0;
    await _attemptStart(url, maxAttempts);
  }

  Future<void> _attemptStart(String url, int maxAttempts) async {
    try {
      await _player.stop();
      final station = _selected;
      final source = AudioSource.uri(
        Uri.parse(url),
        tag: MediaItem(
          id: url,
          title: station?.name ?? 'Radio',
          artist: 'Live Radio',
          artUri: Uri.parse('asset:///lib/assets/screenshot_1.png'),
          extras: const {'isLiveStream': true},
        ),
      );
      await _player.setAudioSource(source);
      await _player.play();
      _cancelBackoff();
    } catch (e) {
      debugPrint('Error starting stream: $e');
      _lastError = PlaybackError(details: e.toString(), time: DateTime.now());
      if (_retryAttempts < maxAttempts - 1) {
        final backoffMs = 600 * (1 << _retryAttempts);
        _retryAttempts++;
        _retryTimer = Timer(Duration(milliseconds: backoffMs), () {
          _attemptStart(url, maxAttempts);
        });
      }
      notifyListeners();
    }
  }

  void _cancelBackoff() {
    _retryTimer?.cancel();
    _retryTimer = null;
    _retryAttempts = 0;
  }

  void _deleteStation(Station station) {
    // Проверяем является ли станция встроенной из JSON
    final isBuiltIn = _defaultStations.any((s) => s.name == station.name);
    if (isBuiltIn) return; // Нельзя удалять встроенные станции

    final wasSelected = _selected?.name == station.name;
    _stations.removeWhere((s) => s.name == station.name);
    _persistUserStations();

    if (wasSelected) {
      _selected = _stations.isNotEmpty ? _stations.first : null;
      _persistSelectedIfNeeded();
    }
    notifyListeners();
  }

  void _persistUserStations() {
    // Сохраняем пользовательские станции и переопределения (такое же имя как у встроенной, но другой URL)
    final builtInByName = {for (final b in _defaultStations) b.name: b.url};
    final List<Station> toPersist = [];
    for (final s in _stations) {
      final builtInUrl = builtInByName[s.name];
      final isBuiltIn = builtInUrl != null;
      final isOverride = isBuiltIn && builtInUrl != s.url;
      if (!isBuiltIn || isOverride) {
        // сохраняем пользовательские или переопределения
        // Избегаем дубликатов по имени в списке для сохранения
        final existingIdx = toPersist.indexWhere((e) => e.name == s.name);
        if (existingIdx >= 0) toPersist.removeAt(existingIdx);
        toPersist.add(s);
      }
    }
    // Fire-and-forget
    // ignore: discarded_futures
    StationStorage.instance.saveStations(toPersist);
  }

  void _addOrUpdateStation(Station station, {String? originalName}) {
    final keyName = originalName ?? station.name;
    final wasSelected = _selected?.name == keyName;

    // Удаляем оригинальную запись
    final index = _stations.indexWhere((s) => s.name == keyName);
    if (index >= 0) {
      _stations.removeAt(index);
    }
    // Если переименовываем, удаляем любую существующую станцию с новым именем, чтобы избежать дубликатов
    if (station.name != keyName) {
      _stations.removeWhere((s) => s.name == station.name);
    }
    _stations.insert(0, station);
    _persistUserStations();

    if (wasSelected) {
      selectStation(station);
    } else {
      notifyListeners();
    }
  }

  // UI-related actions
  Future<Station?> manageAddStation(BuildContext context) async {
    final station = await showModalBottomSheet<Station>(
      context: context,
      backgroundColor: Colors.black,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(kDefaultRadius),
        ),
      ),
      builder: (ctx) => const AddStationSheet(),
    );
    if (station != null) {
      _addOrUpdateStation(station);
      selectStation(station);
      return station;
    }
    return null;
  }

  Future<void> manageEditStation(BuildContext context, Station original) async {
    final updated = await showModalBottomSheet<Station>(
      context: context,
      backgroundColor: Colors.black,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(kDefaultRadius),
        ),
      ),
      builder: (ctx) => AddStationSheet(initial: original),
    );
    if (updated != null) {
      _addOrUpdateStation(updated, originalName: original.name);
    }
  }

  Future<void> manageDeleteStation(BuildContext context, Station station) async {
    final l10n = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.black,
        title: Text(l10n.deleteStationTitle),
        content: Text(l10n.deleteStationMessage),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(l10n.cancel)),
          FilledButton(onPressed: () => Navigator.of(ctx).pop(true), child: Text(l10n.delete)),
        ],
      ),
    );
    if (confirm == true) {
      _deleteStation(station);
    }
  }

  // Добавить или обновить станцию по имени, затем выбрать её
  void addStation(Station station) {
    final index = _stations.indexWhere((s) => s.name == station.name);
    if (index >= 0) {
      // Заменить существующую (встроенную или пользовательскую) запись с обновленным URL
      _stations.removeAt(index);
      _stations.insert(0, station);
    } else {
      _stations.insert(0, station);
    }
    _persistUserStations();
    selectStation(station);
  }

  // Обновить станцию (по имени или предоставленному originalName), не выбирать автоматически, если она не была выбрана
  void updateStation(Station updated, {String? originalName}) {
    final keyName = originalName ?? updated.name;
    final wasSelected = _selected?.name == keyName;
    // Удалить оригинальную запись
    final index = _stations.indexWhere((s) => s.name == keyName);
    if (index >= 0) {
      _stations.removeAt(index);
    }
    // Если переименовываем в имя, которое уже существует, удаляем и его, чтобы избежать дубликатов
    if (updated.name != keyName) {
      _stations.removeWhere((s) => s.name == updated.name);
    }
    _stations.insert(0, updated);
    _persistUserStations();
    if (wasSelected) {
      selectStation(updated);
    } else {
      notifyListeners();
    }
  }

  // Удалить пользовательскую станцию по имени
  void deleteStation(Station station) {
    final isBuiltIn = _defaultStations.any((s) => s.name == station.name);
    if (isBuiltIn) {
      // Не разрешаем удаление встроенных станций
      return;
    }
    final wasSelected = _selected?.name == station.name;
    _stations.removeWhere((s) => s.name == station.name);
    _persistUserStations();
    if (wasSelected) {
      // выбрать первую станцию как текущую без автоплея
      _selected = _stations.isNotEmpty ? _stations.first : null;
      _persistSelectedIfNeeded();
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _player.dispose();
    _reactCtrl.dispose();
    _cancelBackoff();
    super.dispose();
  }
}
