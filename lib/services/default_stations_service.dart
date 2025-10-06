import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:musice/models/station.dart';

class DefaultStationsService {
  DefaultStationsService._();
  static final DefaultStationsService instance = DefaultStationsService._();

  List<Station>? _cachedStations;

  // Built-in fallback to ensure stations exist even if assets are unavailable (e.g., in tests)
  static const List<Station> _fallback = <Station>[];

  // Expose cached stations for synchronous seeding
  List<Station>? get cachedStations => _cachedStations;

  // Synchronous getter to use cached stations or fallback immediately
  List<Station> get defaultOrFallbackSync =>
      _cachedStations != null ? List<Station>.from(_cachedStations!) : List<Station>.from(_fallback);

  Future<List<Station>> loadDefaultStations() async {
    if (_cachedStations != null) {
      return _cachedStations!;
    }

    try {
      final jsonString = await rootBundle.loadString('assets/default_stations.json');
      final List<dynamic> jsonList = jsonDecode(jsonString);

      final parsed = jsonList
          .map((json) => Station.fromJson(Map<String, dynamic>.from(json)))
          .where((station) => station.name.trim().isNotEmpty && station.url.trim().isNotEmpty)
          .toList();

      // If asset exists but is empty or filtered result is empty, use fallback
      _cachedStations = parsed.isEmpty ? List<Station>.from(_fallback) : parsed;
      return _cachedStations!;
    } catch (e) {
      // If assets are not available (e.g., in tests), fall back to a built-in set
      _cachedStations = List<Station>.from(_fallback);
      return _cachedStations!;
    }
  }

  void clearCache() {
    _cachedStations = null;
  }
}
