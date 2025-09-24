import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:musice/models/station.dart';
import 'package:musice/config/stations.dart' as cfg;
import 'fs/stations_fs.dart' as fs;

// Compile-time flags for JSON source
const String kStationsFilePath = String.fromEnvironment('STATIONS_FILE', defaultValue: '');
const bool kStationsWatch = bool.fromEnvironment('STATIONS_WATCH', defaultValue: false);
const String kStationsAsset = String.fromEnvironment('STATIONS_ASSET', defaultValue: 'lib/assets/stations.json');

class StationsRepository {
  final List<Station> _fallback;
  final _controller = StreamController<List<Station>>.broadcast();
  final _errors = StreamController<String>.broadcast();
  StreamSubscription<void>? _watchSub;
  String? lastError;

  String? _overridePath;

  StationsRepository({List<Station>? fallback}) : _fallback = fallback ?? cfg.stations;

  // State
  List<Station> get fallback => List.unmodifiable(_fallback);
  Stream<String> get errors => _errors.stream;
  Stream<List<Station>> get stream => _controller.stream;

  String? get currentFilePath => _overridePath?.isNotEmpty == true ? _overridePath : (kStationsFilePath.isNotEmpty ? kStationsFilePath : null);
  bool get hasFile => currentFilePath != null && currentFilePath!.isNotEmpty;
  bool get isDesktop => fs.fsIsDesktopPlatform();
  bool get supportsWatch => hasFile && kStationsWatch && fs.fsSupportsWatchPlatform();

  void setFilePath(String? path) {
    _overridePath = path;
  }

  Future<List<Station>> load() async {
    lastError = null;
    final path = currentFilePath;
    if (path != null) {
      try {
        final exists = await fs.fsFileExists(path);
        if (!exists) {
          _signalError('Stations file not found: $path');
          return _fallback;
        }
        final raw = await fs.fsReadAsString(path);
        final data = json.decode(raw);
        return _parse(data) ?? _fallback;
      } catch (e) {
        _signalError('Failed to load stations from file: $e');
        return _fallback;
      }
    }

    // Fallback to asset (useful on mobile/web)
    try {
      final raw = await rootBundle.loadString(kStationsAsset);
      final data = json.decode(raw);
      return _parse(data) ?? _fallback;
    } catch (e) {
      _signalError('Failed to load stations asset ($kStationsAsset): $e');
      return _fallback;
    }
  }

  Stream<List<Station>> watch() {
    final path = currentFilePath;
    if (!supportsWatch || path == null) return _controller.stream;
    () async {
      final initial = await load();
      _controller.add(initial);
      try {
        _watchSub?.cancel();
        final stream = fs.fsWatchFile(path);
        if (stream != null) {
          _watchSub = stream.listen((_) async {
            final list = await load();
            _controller.add(list);
          });
        }
      } catch (e) {
        _signalError('Failed to watch stations file: $e');
      }
    }();
    return _controller.stream;
  }

  Future<void> saveToFile(List<Station> stations, {String? path}) async {
    final target = path ?? currentFilePath;
    if (target == null || target.isEmpty) {
      _signalError('No target file path provided for saving.');
      return;
    }
    try {
      final jsonStr = json.encode(stations.map((s) => { 'name': s.name, 'url': s.url }).toList());
      await fs.fsWriteString(target, jsonStr);
    } catch (e) {
      _signalError('Failed to save stations to $target: $e');
      rethrow;
    }
  }

  void dispose() {
    _watchSub?.cancel();
    _controller.close();
    _errors.close();
  }

  List<Station>? _parse(dynamic data) {
    if (data is List) {
      final out = <Station>[];
      for (final e in data) {
        if (e is Map && e['name'] is String && e['url'] is String) {
          out.add(Station(e['name'] as String, e['url'] as String));
        }
      }
      if (out.isEmpty) {
        _signalError('Stations JSON is empty or invalid format');
        return null;
      }
      return out;
    }
    _signalError('Stations JSON root is not a list');
    return null;
  }

  void _signalError(String message) {
    lastError = message;
    debugPrint(message);
    if (!_errors.isClosed) {
      _errors.add(message);
    }
  }
}
