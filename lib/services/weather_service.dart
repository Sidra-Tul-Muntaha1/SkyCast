
import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/api_config.dart';
import '../models/current_weather.dart';

class WeatherException implements Exception {
  const WeatherException(this.message);

  final String message;

  @override
  String toString() => message;
}

class WeatherService {
  WeatherService({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;

  Future<CurrentWeather> getCurrentWeather(
    String city,
  ) async {
    if (!ApiConfig.hasApiKey) {
      throw const WeatherException(
        'API key is missing. Start the app with '
        'OPENWEATHER_API_KEY configured.',
      );
    }

    final trimmedCity = city.trim();

    if (trimmedCity.isEmpty) {
      throw const WeatherException(
        'Please enter a city name.',
      );
    }

    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/weather',
    ).replace(
      queryParameters: {
        'q': trimmedCity,
        'appid': ApiConfig.apiKey,
        'units': 'metric',
      },
    );

    try {
      final response = await _client
          .get(uri)
          .timeout(const Duration(seconds: 15));

      final dynamic decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        throw const WeatherException(
          'The weather server returned an unexpected response.',
        );
      }

      if (response.statusCode == 200) {
        try {
          return CurrentWeather.fromJson(decoded);
        } on FormatException {
          throw const WeatherException(
            'Weather data could not be read. Please try again.',
          );
        }
      }

      switch (response.statusCode) {
        case 400:
          throw const WeatherException(
            'Invalid city request. Check the city name.',
          );
        case 401:
          throw const WeatherException(
            'The API key is invalid or not active yet.',
          );
        case 404:
          throw const WeatherException(
            'City not found. Try another spelling.',
          );
        case 429:
          throw const WeatherException(
            'API request limit reached. Please try later.',
          );
        default:
          throw WeatherException(
            'Weather service error (${response.statusCode}). '
            'Please try again.',
          );
      }
    } on TimeoutException {
      throw const WeatherException(
        'The request took too long. Please try again.',
      );
    } on http.ClientException {
      throw const WeatherException(
        'Unable to connect. Check your internet connection.',
      );
    } on FormatException {
      throw const WeatherException(
        'Invalid response from the weather service.',
      );
    }
  }
    
  Future<CurrentWeather> getCurrentWeatherByCoordinates({
    required double latitude,
    required double longitude,
  }) async {
    if (!ApiConfig.hasApiKey) {
      throw const WeatherException(
        'API key is missing. Start the app with '
        'OPENWEATHER_API_KEY configured.',
      );
    }

    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/weather',
    ).replace(
      queryParameters: {
        'lat': latitude.toString(),
        'lon': longitude.toString(),
        'appid': ApiConfig.apiKey,
        'units': 'metric',
      },
    );

    try {
      final response = await _client
          .get(uri)
          .timeout(const Duration(seconds: 15));

      final dynamic decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        throw const WeatherException(
          'The weather server returned an unexpected response.',
        );
      }

      if (response.statusCode == 200) {
        return CurrentWeather.fromJson(decoded);
      }

      switch (response.statusCode) {
        case 401:
          throw const WeatherException(
            'The API key is invalid or not active yet.',
          );
        case 429:
          throw const WeatherException(
            'API request limit reached. Please try later.',
          );
        default:
          throw WeatherException(
            'Weather service error (${response.statusCode}). '
            'Please try again.',
          );
      }
    } on TimeoutException {
      throw const WeatherException(
        'The request took too long. Please try again.',
      );
    } on http.ClientException {
      throw const WeatherException(
        'Unable to connect. Check your internet connection.',
      );
    } on FormatException {
      throw const WeatherException(
        'Invalid response from the weather service.',
      );
    }
  }

  void dispose() {
    _client.close();
  }
}
