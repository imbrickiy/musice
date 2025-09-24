// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get selectStation => 'Select a station';

  @override
  String get volumeLabel => 'VOLUME';

  @override
  String get stationsTooltip => 'Stations';

  @override
  String get stationsSemantics => 'Open stations';

  @override
  String get aboutTooltip => 'About';

  @override
  String get play => 'Play';

  @override
  String get pause => 'Pause';

  @override
  String get errorStartStream => 'Failed to start stream';

  @override
  String get retry => 'Retry';

  @override
  String get details => 'Details';

  @override
  String get playbackErrorTitle => 'Playback error';

  @override
  String get language => 'Language';

  @override
  String get systemDefault => 'System default';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageRussian => 'Russian';

  @override
  String get ok => 'OK';
}
