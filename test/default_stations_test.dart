import 'package:flutter_test/flutter_test.dart';
import 'package:musice/services/default_stations_service.dart';

void main() {
  test('DefaultStationsService sync fallback returns a list without throwing', () {
    DefaultStationsService.instance.clearCache();
    final list = DefaultStationsService.instance.defaultOrFallbackSync;
    expect(list, isA<List>());
  });

  test('DefaultStationsService async load returns a list and caches it', () async {
    final svc = DefaultStationsService.instance;
    svc.clearCache();
    final loaded = await svc.loadDefaultStations();
    expect(loaded, isA<List>());
    final cached = svc.cachedStations;
    expect(cached, isNotNull);
    final loadedAgain = await svc.loadDefaultStations();
    expect(identical(cached, loadedAgain), isTrue);
  });
}
