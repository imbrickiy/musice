import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleController {
  static const _prefsKey = 'selected_locale_code';
  static final LocaleController instance = LocaleController._();
  LocaleController._();

  final ValueNotifier<Locale?> locale = ValueNotifier<Locale?>(null);

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_prefsKey);
    if (code != null && code.isNotEmpty) {
      locale.value = Locale(code);
    }
  }

  Future<void> setLocale(Locale? value) async {
    locale.value = value;
    final prefs = await SharedPreferences.getInstance();
    if (value == null) {
      await prefs.remove(_prefsKey);
    } else {
      await prefs.setString(_prefsKey, value.languageCode);
    }
  }
}

