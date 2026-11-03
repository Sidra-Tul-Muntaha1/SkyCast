
class ApiConfig {
  ApiConfig._();

  static const String apiKey = String.fromEnvironment(
    'OPENWEATHER_API_KEY',
  );

  static const String baseUrl =
      'https://api.openweathermap.org/data/2.5';

  static bool get hasApiKey => apiKey.trim().isNotEmpty;
}
