import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:musice/models/station.dart';

class StationStorage {
  StationStorage._();
  static final StationStorage instance = StationStorage._();

  static const String _fileName = 'stations.json';

  Future<File> _file() async {
    final dir = await getApplicationDocumentsDirectory();
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return File('${dir.path}/$_fileName');
  }

  Future<File> _legacyFile() async {
    final dir = await getApplicationSupportDirectory();
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return File('${dir.path}/$_fileName');
  }

  Future<List<Station>> _readFileIfExists(File f) async {
    if (!await f.exists()) return const [];
    try {
      final content = await f.readAsString();
      final data = jsonDecode(content);
      if (data is List) {
        return data
            .whereType<Map>()
            .map((e) => Station.fromJson(Map<String, dynamic>.from(e)))
            .where((s) => s.name.trim().isNotEmpty && s.url.trim().isNotEmpty)
            .toList(growable: false);
      }
    } catch (_) {
      // ignore malformed content
    }
    return const [];
  }

  Future<List<Station>> loadStations() async {
    final currentFile = await _file();
    final legacyFile = await _legacyFile();

    final currentList = await _readFileIfExists(currentFile);
    final legacyList = await _readFileIfExists(legacyFile);

    // Merge: prefer items from current (Documents) over legacy by name
    final Map<String, Station> byName = {
      for (final s in legacyList) s.name: s,
      for (final s in currentList) s.name: s,
    };
    final merged = byName.values.toList(growable: false);

    // If there was legacy content and current is missing or different, persist merged to new location
    try {
      if (legacyList.isNotEmpty) {
        await saveStations(merged);
        // Best-effort cleanup of legacy file
        if (await legacyFile.exists()) {
          await legacyFile.delete();
        }
      }
    } catch (_) {
      // ignore IO errors
    }

    return merged;
  }

  Future<void> saveStations(List<Station> stations) async {
    try {
      final f = await _file();
      final list = stations.map((s) => s.toJson()).toList(growable: false);
      await f.writeAsString(jsonEncode(list));
    } catch (_) {
      // ignore IO errors
    }
  }
}
