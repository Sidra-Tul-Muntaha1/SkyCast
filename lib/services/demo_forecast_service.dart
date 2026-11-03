
import '../models/hourly_forecast.dart';

class DemoForecastService {
  DemoForecastService._();

  static List<HourlyForecast> getHourlyForecast() {
    final now = DateTime.now();
    final currentHour = DateTime(
      now.year,
      now.month,
      now.day,
      now.hour,
    );

    const temperatures = [29.0, 28.0, 27.0, 26.0, 25.0, 25.0, 27.0, 30.0];
    const descriptions = [
      'Partly cloudy',
      'Cloudy',
      'Cloudy',
      'Clear sky',
      'Clear sky',
      'Clear sky',
      'Sunny',
      'Sunny',
    ];
    const icons = ['02d', '03d', '03n', '01n', '01n', '01d', '01d', '01d'];

    return List.generate(8, (index) {
      return HourlyForecast(
        time: currentHour.add(Duration(hours: index)),
        temperature: temperatures[index],
        description: descriptions[index],
        icon: icons[index],
      );
    });
  }
}
