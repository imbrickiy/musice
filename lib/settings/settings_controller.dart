import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsController {
  static final SettingsController instance = SettingsController._();
  SettingsController._();

  static const _keyAutoplay = 'autoplay_on_launch';
  static const _keyRememberStation = 'remember_last_station';
  static const _keyAutoplayOnSwitch = 'autoplay_on_switch';
  static const _keyKeepPlayingOnSwitch = 'keep_playing_on_switch';

  final ValueNotifier<bool> autoplayOnLaunch = ValueNotifier<bool>(false);
  final ValueNotifier<bool> rememberLastStation = ValueNotifier<bool>(true);
  final ValueNotifier<bool> autoplayOnSwitch = ValueNotifier<bool>(true);
  final ValueNotifier<bool> keepPlayingOnSwitch = ValueNotifier<bool>(true);

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    autoplayOnLaunch.value = prefs.getBool(_keyAutoplay) ?? false;
    rememberLastStation.value = prefs.getBool(_keyRememberStation) ?? true;
    autoplayOnSwitch.value = prefs.getBool(_keyAutoplayOnSwitch) ?? true;
    keepPlayingOnSwitch.value = prefs.getBool(_keyKeepPlayingOnSwitch) ?? true;
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

  Future<void> setAutoplayOnSwitch(bool value) async {
    autoplayOnSwitch.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAutoplayOnSwitch, value);
  }

  Future<void> setKeepPlayingOnSwitch(bool value) async {
    keepPlayingOnSwitch.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyKeepPlayingOnSwitch, value);
  }
}
