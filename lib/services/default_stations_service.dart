import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:musice/models/station.dart';

class DefaultStationsService {
  DefaultStationsService._();
  static final DefaultStationsService instance = DefaultStationsService._();

  List<Station>? _cachedStations;

  Future<List<Station>> loadDefaultStations() async {
    if (_cachedStations != null) {
      return _cachedStations!;
    }

    try {
      final jsonString = await rootBundle.loadString('assets/default_stations.json');
      final List<dynamic> jsonList = jsonDecode(jsonString);

      _cachedStations = jsonList
          .map((json) => Station.fromJson(Map<String, dynamic>.from(json)))
          .where((station) => station.name.trim().isNotEmpty && station.url.trim().isNotEmpty)
          .toList();

      return _cachedStations!;
    } catch (e) {
      // В случае ошибки возвращаем пустой список
      _cachedStations = const [];
      return _cachedStations!;
    }
  }

  void clearCache() {
    _cachedStations = null;
  }
}
