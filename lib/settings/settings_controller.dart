import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsController {
  static final SettingsController instance = SettingsController._();
  SettingsController._();

  static const _keyAutoplay = 'autoplay_on_launch';
  static const _keyRememberStation = 'remember_last_station';

  final ValueNotifier<bool> autoplayOnLaunch = ValueNotifier<bool>(false);
  final ValueNotifier<bool> rememberLastStation = ValueNotifier<bool>(true);

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    autoplayOnLaunch.value = prefs.getBool(_keyAutoplay) ?? false;
    rememberLastStation.value = prefs.getBool(_keyRememberStation) ?? true;
  }

  Future<void> setAutoplayOnLaunch(bool value) async {
    autoplayOnLaunch.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAutoplay, value);
  }

  Future<void> setRememberLastStation(bool value) async {
    rememberLastStation.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyRememberStation, value);
  }
}

