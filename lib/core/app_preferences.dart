
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  AppPreferences._();

  static final ValueNotifier<String> temperatureUnit =
      ValueNotifier<String>('°C');

  static final ValueNotifier<String> language =
      ValueNotifier<String>('English');

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    temperatureUnit.value =
        prefs.getString('temperatureUnit') ?? '°C';

    language.value =
        prefs.getString('language') ?? 'English';
  }

  static Future<void> setTemperatureUnit(String unit) async {
    temperatureUnit.value = unit;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('temperatureUnit', unit);
  }

  static Future<void> setLanguage(String selectedLanguage) async {
    language.value = selectedLanguage;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', selectedLanguage);
  }

  static double convertTemperature(num celsius) {
    if (temperatureUnit.value == '°F') {
      return celsius * 9 / 5 + 32;
    }

    return celsius.toDouble();
  }

  static String formatTemperature(num celsius) {
    final value = convertTemperature(celsius);
    return '${value.round()}${temperatureUnit.value}';
  }
}
