import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:musice/models/station.dart';
import 'package:musice/constants/app_constants.dart';

class PlaybackError {
  final String details;
  final DateTime time;
  const PlaybackError({required this.details, required this.time});
}

class RadioProvider with ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();
  final List<Station> _stations = kStations;
  Station? _selected;
  double _volume = 0.5;
  double _reactiveLevel = 0.0;
  PlayerState? _lastPlayerState;
  Timer? _retryTimer;
  int _retryAttempts = 0;
  PlaybackError? _lastError;

  late final AnimationController _reactCtrl;

  RadioProvider(TickerProvider vsync) {
    _selected = _stations.isNotEmpty ? _stations.first : null;
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
  }

  List<Station> get stations => _stations;
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

  void selectStation(Station station) {
    _selected = station;
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

  Future<void> _startStationWithBackoff(String url, {int maxAttempts = 3}) async {
    _cancelBackoff();
    _retryAttempts = 0;
    await _attemptStart(url, maxAttempts);
  }

  Future<void> _attemptStart(String url, int maxAttempts) async {
    try {
      await _player.stop();
      await _player.setAudioSource(AudioSource.uri(Uri.parse(url)));
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

  @override
  void dispose() {
    _player.dispose();
    _reactCtrl.dispose();
    _cancelBackoff();
    super.dispose();
  }
}
