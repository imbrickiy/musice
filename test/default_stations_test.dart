import 'package:flutter_test/flutter_test.dart';
import 'package:musice/services/default_stations_service.dart';

void main() {
  test('DefaultStationsService returns fallback when asset missing', () async {
    final svc = DefaultStationsService.instance;
    svc.clearCache();
    final list = await svc.loadDefaultStations();
    expect(list, isNotEmpty);
    expect(list.any((s) => s.name == 'Deep'), isTrue);
    expect(list.any((s) => s.name == 'Chill-Out'), isTrue);
  });
}

