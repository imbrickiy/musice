// dart
import 'package:musice/models/station.dart';
import 'stations_dev.dart' as dev;

const String _appEnv = String.fromEnvironment('APP_ENV', defaultValue: 'prod');

List<Station> get envStations {
  switch (_appEnv) {
    case 'dev':
      return dev.stations;
    case 'stage':
    case 'prod':
    default:
      return dev.stations;
  }
}
