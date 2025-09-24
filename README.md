# Musice — минималистичное радио на Flutter

Musice — это небольшой кроссплатформенный радио‑плеер на Flutter. Приложение воспроизводит интернет‑радио (HLS), позволяет выбрать станцию, управлять воспроизведением и громкостью, а также показывает «реактивную» анимацию, которая пульсирует в такт проигрыванию.


## Возможности
- Выбор радиостанции через нижний модальный лист (с безопасным запасным диалогом, если лист не открылся)
- Воспроизведение потоков HLS с помощью `just_audio`
- Кнопка Play/Pause с отображением статусов загрузки/буферизации
- Плавный регулятор громкости
- Реактивная анимация «волн» во время проигрывания
- Тёмная тема, шрифт SF Pro
- Для desktop (macOS/Windows/Linux) — фиксированное окно 390×844 (как iPhone 14) через `window_manager`


## Скриншоты

- Главный экран:  
  ![Скриншот 1](lib/assets/screenshot_1.png)
- Выбор станции:  
  ![Скриншот 2](lib/assets/screenshot_2.png)
- Проигрывание и громкость:  
  ![Скриншот 3](lib/assets/screenshot_3.png)


## Технологии
- Flutter (Material 3)
- Dart (см. ограничения SDK в `pubspec.yaml`)
- just_audio
- window_manager


## Быстрый старт

Требования:
- Установленный Flutter SDK (stable)
- Для iOS/macOS: Xcode, CocoaPods
- Для Windows: инструменты сборки Flutter Desktop

Установка зависимостей:
```zsh
flutter pub get
```

Запуск:
- macOS (desktop):
  ```zsh
  flutter run -d macos
  ```
- iOS (симулятор/устройство):
  ```zsh
  flutter run -d ios
  ```
  Примечание: для реального устройства настройте подпись в Xcode (открыть `ios/Runner.xcworkspace`).
- Windows (desktop):
  ```zsh
  flutter run -d windows
  ```

Сборка релиза (примеры):
- macOS:
  ```zsh
  flutter build macos
  ```
- iOS (архив через Xcode рекомендуется):
  ```zsh
  flutter build ipa
  ```
- Windows:
  ```zsh
  flutter build windows
  ```


## Тесты
Запустить все unit/widget тесты:
```zsh
flutter test
```
Тестовые файлы: `test/widget_test.dart`, `test/radio_home_page_test.dart`, `test/about_sheet_test.dart`, `test/settings_sheet_test.dart`.


## Структура проекта (основное)
- `lib/main.dart` — входная точка приложения (сплэш → домашний экран), настройка темы/локализации, фиксированное desktop‑окно
- `lib/constants/app_constants.dart` — все ключевые константы UI и список станций `kStations`
- `lib/models/station.dart` — модель радиостанции
- `lib/providers/radio_provider.dart` — состояние и логика плеера (`just_audio`, громкость, выбор станции)
- `lib/settings/settings_controller.dart` — настройки (автозапуск, запоминание станции)
- `lib/locale/locale_controller.dart` — смена локали и сохранение выбора
- `lib/l10n/` — локализации (ARB и сгенерированный код)
- `lib/icons/app_icons.dart` — централизованные иконки приложения
- `lib/widgets/` — UI‑компоненты:
  - `radio_header.dart` — заголовок с кнопками станций и настроек
  - `play_section.dart` — секция с Play/Pause и анимацией волн
  - `volume_section.dart` — регулятор громкости
  - `station_picker_sheet.dart` — модальный лист выбора станции
  - `about_sheet.dart`, `settings_sheet.dart` — листы «О приложении» и «Настройки»
  - `wave_pulse.dart` — визуализация «волн»
- `lib/assets/` — изображения/скриншоты
- `lib/fonts/` — шрифт SF Pro (подключён как `family: SFPro` в `pubspec.yaml`)
- `test/` — тесты


## Как добавить/изменить радиостанции
Станции определены в `lib/constants/app_constants.dart` в списке `kStations`. Пример элемента:
```text
const Station('Deep', 'https://example.com/playlist.m3u8')
```
Добавьте новую станцию по аналогии — она появится в списке выбора при следующем запуске.


## Поведение на разных платформах
- Desktop (macOS/Windows/Linux): окно фиксированного размера 390×844. Задаётся при старте через `window_manager` и соответствует портретной ориентации телефона.
- iOS: полноэкранный мобильный режим.


## Нюансы и советы
- Потоки HLS должны быть доступны из вашей сети. Если воспроизведение не начинается, проверьте доступность URL и сетевые ограничения/VPN/файрвол.
- Ошибки старта/буферизации логируются через `debugPrint` (см. консоль).
- Если при выборе станции нижний лист не открылся (редко), сработает запасной диалог.


## Частые проблемы (Release) и их решение
- macOS: приложение в Release не воспроизводит поток.
  - Причина: в режиме sandbox по умолчанию запрещены исходящие сетевые соединения.
  - Решение: в `macos/Runner/Release.entitlements` добавлен ключ `<key>com.apple.security.network.client</key><true/>` (разрешение на исходящие соединения). После изменения пересоберите приложение.
  - Сборка и запуск релизной версии для проверки:
    ```zsh
    flutter build macos
    open build/macos/Build/Products/Release/musice.app
    ```
- iOS: не стартует поток в релизе.
  - Убедитесь, что в `ios/Runner/Info.plist` есть `NSAppTransportSecurity -> NSAllowsArbitraryLoads = true` или включён HTTPS у потоков (указанные HLS‑URL уже `https`).
  - Для фонового воспроизведения включите в Xcode Background Modes -> Audio (необязательно для работы на экране).

Если проблема сохраняется, запустите релизную сборку из консоли и приложите логи:
```zsh
flutter run -d macos --release
```


## Константы интерфейса (app_constants.dart)
Все основные значения собраны в `lib/constants/app_constants.dart` и сгруппированы по назначению:
- Окно: `kWindowSize`
- Цвета: `kSeedColor`, `kScaffoldBackgroundColor`, `kIconColor`, `kDividerColor`, `kBorderColor`, др.
- Длительности: `kSplashDuration`, `kReactionDuration`, `kAnimationDuration`, `kWaveAnimDuration`
- Инфо о приложении: `kAppName`, `kAppVersion`, `kCopyright`
- Станции: `kStations` (список `List<Station>`) — редактируйте его для добавления/удаления станций
- UI‑токены:
  - Заголовок: `kHeaderHPad`, `kHeaderVPad`, `kHeaderButtonSize`, `kHeaderIconSize`, др.
  - Секция воспроизведения: размеры окружностей, толщина волн и т.д.
  - Секция громкости: высота, трек, цвета и т.п.

В теме приложения (`ThemeData`) эти константы используются для настройки цветовой схемы и базовой типографики (семейство шрифтов `SFPro`, Material 3).


## Лицензия
MIT — см. файл `LICENSE` в корне репозитория.

© 2025 imbrickiy


## Git hooks и CI

В репозитории настроены локальные pre-commit хуки и CI, которые помогают держать код в порядке.

- Pre-commit хук (локально): выполняет генерацию локализаций, кастомный линт (запрещает прямые `Icons.*` в `lib/`), `flutter analyze` и тесты.
- CI (GitHub Actions): запускается для веток `main` и `master` на push/PR и повторяет те же проверки.

Настройка pre-commit:
```zsh
# из корня репозитория
./scripts/setup-git-hooks.sh
```
После этого при каждом коммите автоматически выполнятся проверки:
- `flutter gen-l10n`
- `dart run custom_lint` (запрещает прямые `Icons.*` — используйте `AppIcons`)
- `flutter analyze`
- `flutter test -r compact`

Полезно знать:
- Можно временно пропустить тесты: `SKIP_TESTS=1 git commit -m "msg"`
- Полностью обойти хуки (не рекомендуется): `git commit --no-verify -m "msg"`

CI-триггеры:
- Файл: `.github/workflows/ci.yml`
- По умолчанию триггеры настроены на ветки `main` и `master`.
- Чтобы изменить список веток, отредактируйте секции `on.push.branches` и `on.pull_request.branches` в workflow, например:
```yaml
on:
  push:
    branches: [ develop ]
  pull_request:
    branches: [ develop ]
```
