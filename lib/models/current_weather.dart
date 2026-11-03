
class CurrentWeather {
  const CurrentWeather({
    required this.cityName,
    required this.countryCode,
    required this.temperature,
    required this.feelsLike,
    required this.minTemperature,
    required this.maxTemperature,
    required this.description,
    required this.condition,
    required this.iconCode,
    required this.humidity,
    required this.windSpeed,
    required this.pressure,
    required this.visibility,
    required this.sunrise,
    required this.sunset,
    required this.observedAt,
  });

  final String cityName;
  final String countryCode;
  final double temperature;
  final double feelsLike;
  final double minTemperature;
  final double maxTemperature;
  final String description;
  final String condition;
  final String iconCode;
  final int humidity;
  final double windSpeed;
  final int pressure;
  final int visibility;
  final DateTime sunrise;
  final DateTime sunset;
  final DateTime observedAt;

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    final main = json['main'] as Map<String, dynamic>?;
    final weatherList = json['weather'] as List<dynamic>?;
    final wind = json['wind'] as Map<String, dynamic>?;
    final system = json['sys'] as Map<String, dynamic>?;

    if (main == null ||
        weatherList == null ||
        weatherList.isEmpty ||
        wind == null ||
        system == null) {
      throw const FormatException(
        'The weather response is incomplete.',
      );
    }

    final conditionData =
        weatherList.first as Map<String, dynamic>;

    double number(
      Map<String, dynamic> source,
      String key,
    ) {
      final value = source[key];
      if (value is num) return value.toDouble();
      throw FormatException('Missing or invalid "$key".');
    }

    int integer(
      Map<String, dynamic> source,
      String key,
    ) {
      final value = source[key];
      if (value is num) return value.toInt();
      throw FormatException('Missing or invalid "$key".');
    }

    String string(
      Map<String, dynamic> source,
      String key,
    ) {
      final value = source[key];
      if (value is String && value.isNotEmpty) return value;
      throw FormatException('Missing or invalid "$key".');
    }

    final observedSeconds = integer(json, 'dt');
    final timezoneOffset = integer(json, 'timezone');

    DateTime localTime(int seconds) =>
        DateTime.fromMillisecondsSinceEpoch(
          (seconds + timezoneOffset) * 1000,
          isUtc: true,
        );

    return CurrentWeather(
      cityName: string(json, 'name'),
      countryCode: string(system, 'country'),
      temperature: number(main, 'temp'),
      feelsLike: number(main, 'feels_like'),
      minTemperature: number(main, 'temp_min'),
      maxTemperature: number(main, 'temp_max'),
      description: string(conditionData, 'description'),
      condition: string(conditionData, 'main'),
      iconCode: string(conditionData, 'icon'),
      humidity: integer(main, 'humidity'),
      windSpeed: number(wind, 'speed'),
      pressure: integer(main, 'pressure'),
      visibility: integer(json, 'visibility'),
      sunrise: localTime(integer(system, 'sunrise')),
      sunset: localTime(integer(system, 'sunset')),
      observedAt: localTime(observedSeconds),
    );
  }

  String get iconUrl =>
      'https://openweathermap.org/img/wn/$iconCode@2x.png';
}
