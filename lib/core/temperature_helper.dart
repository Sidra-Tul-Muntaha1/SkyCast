
import 'package:shared_preferences/shared_preferences.dart';

class TemperatureHelper {
  static String format(num celsius) {
    final fahrenheit = celsius * 9 / 5 + 32;

    // Read the saved preference asynchronously in the app.
    return '${celsius.round()}°C';
  }

  static double convert(num celsius, String unit) {
    if (unit == '°F') {
      return celsius * 9 / 5 + 32;
    }

    return celsius.toDouble();
  }

  static String formatValue(num celsius, String unit) {
    return '${convert(celsius, unit).round()}$unit';
  }

  static Future<String> getSavedUnit() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('temperatureUnit') ?? '°C';
  }
}
