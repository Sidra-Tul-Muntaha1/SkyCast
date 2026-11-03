
class HourlyForecast {
  const HourlyForecast({
    required this.time,
    required this.temperature,
    required this.description,
    required this.icon,
  });

  final DateTime time;
  final double temperature;
  final String description;
  final String icon;

  
factory HourlyForecast.fromJson(
  Map<String, dynamic> json, {
  int timezoneOffsetSeconds = 0,
}) {
  final weatherList = json['weather'] as List<dynamic>? ?? [];
  final weather = weatherList.isNotEmpty
      ? weatherList.first as Map<String, dynamic>
      : <String, dynamic>{};

  final main = json['main'] as Map<String, dynamic>? ?? {};

  return HourlyForecast(
    time: DateTime.fromMillisecondsSinceEpoch(
      (((json['dt'] as num).toInt()) + timezoneOffsetSeconds) * 1000,
      isUtc: true,
    ),
    temperature: (main['temp'] as num).toDouble(),
    description: weather['description'] as String? ?? 'Unknown',
    icon: weather['icon'] as String? ?? '02d',
  );
}


  String get iconUrl =>
      'https://openweathermap.org/img/wn/$icon@2x.png';
}
