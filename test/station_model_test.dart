import 'package:flutter_test/flutter_test.dart';
import 'package:musice/models/station.dart';

void main() {
  test('Station JSON serialization roundtrip', () {
    final s = Station('Test', 'https://example.com/stream.mp3');
    final json = s.toJson();
    final restored = Station.fromJson(json);
    expect(restored.name, equals('Test'));
    expect(restored.url, equals('https://example.com/stream.mp3'));
    expect(restored, equals(s));
  });
}

