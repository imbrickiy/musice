// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get selectStation => 'Выберите станцию';

  @override
  String get volumeLabel => 'ГРОМКОСТЬ';

  @override
  String get stationsTooltip => 'Станции';

  @override
  String get stationsSemantics => 'Открыть список станций';

  @override
  String get aboutTooltip => 'О приложении';

  @override
  String get play => 'Воспроизвести';

  @override
  String get pause => 'Пауза';

  @override
  String get errorStartStream => 'Не удалось запустить поток';

  @override
  String get retry => 'Повторить';

  @override
  String get details => 'Подробнее';

  @override
  String get playbackErrorTitle => 'Ошибка воспроизведения';

  @override
  String get language => 'Язык';

  @override
  String get systemDefault => 'Язык системы';

  @override
  String get languageEnglish => 'Английский';

  @override
  String get languageRussian => 'Русский';

  @override
  String get ok => 'ОК';

  @override
  String get settings => 'Настройки';

  @override
  String get autoplayOnLaunch => 'Автовоспроизведение при запуске';

  @override
  String get rememberLastStation => 'Запоминать последнюю станцию';
}
