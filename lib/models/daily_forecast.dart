
class DailyForecast {
  const DailyForecast({
    required this.date,
    required this.highTemperature,
    required this.lowTemperature,
    required this.description,
    required this.icon,
  });

  final DateTime date;
  final double highTemperature;
  final double lowTemperature;
  final String description;
  final String icon;
}
