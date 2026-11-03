
import '../models/hourly_forecast.dart';
import '../models/daily_forecast.dart';

class DailyForecastService {
  DailyForecastService._();

  static List<DailyForecast> fromHourlyForecasts(
    List<HourlyForecast> forecasts,
  ) {
    if (forecasts.isEmpty) {
      return [];
    }

    final Map<DateTime, List<HourlyForecast>> grouped = {};

    for (final forecast in forecasts) {
      final date = DateTime.utc(
        forecast.time.year,
        forecast.time.month,
        forecast.time.day,
      );

      grouped.putIfAbsent(date, () => []).add(forecast);
    }

    final days = grouped.entries.map((entry) {
      final items = List<HourlyForecast>.from(entry.value);

      if (items.isEmpty) {
        return null;
      }

      final temperatures =
          items.map((item) => item.temperature).toList();

      // Select the forecast closest to midday.
      items.sort((a, b) {
        final aDistance = (a.time.hour - 12).abs();
        final bDistance = (b.time.hour - 12).abs();
        return aDistance.compareTo(bDistance);
      });

      final representative = items.first;

      return DailyForecast(
        date: entry.key,
        highTemperature: temperatures.reduce(
          (a, b) => a > b ? a : b,
        ),
        lowTemperature: temperatures.reduce(
          (a, b) => a < b ? a : b,
        ),
        description: representative.description,
        icon: representative.icon,
      );
    }).whereType<DailyForecast>().toList();

    days.sort((a, b) => a.date.compareTo(b.date));

    return days.take(5).toList();
  }
}


/* 
import '../models/hourly_forecast.dart';
import '../models/daily_forecast.dart';

class DailyForecastService {
  DailyForecastService._();

  static List<DailyForecast> fromHourlyForecasts(
    List<HourlyForecast> forecasts,
  ) {
    final Map<DateTime, List<HourlyForecast>> grouped = {};

    for (final forecast in forecasts) {
      final date = DateTime.utc(
        forecast.time.year,
        forecast.time.month,
        forecast.time.day,
      );

      grouped.putIfAbsent(date, () => []).add(forecast);
    }

    final days = grouped.entries.map((entry) {
      final items = entry.value;

      final temperatures =
          items.map((item) => item.temperature).toList();

      // Use the forecast closest to midday for the daily condition.
      items.sort((a, b) {
        final aDistance = (a.time.hour - 12).abs();
        final bDistance = (b.time.hour - 12).abs();
        return aDistance.compareTo(bDistance);
      });

      final representative = items.first;

      return DailyForecast(
        date: entry.key,
        highTemperature: temperatures.reduce(
          (a, b) => a > b ? a : b,
        ),
        lowTemperature: temperatures.reduce(
          (a, b) => a < b ? a : b,
        ),
        description: representative.description,
        icon: representative.icon,
      );
    }).toList();

    days.sort((a, b) => a.date.compareTo(b.date));

    // Show today and the next four forecast days.
    return days.take(5).toList();
  }
}
 */