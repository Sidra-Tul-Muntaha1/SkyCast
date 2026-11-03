
import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/api_config.dart';
import '../models/hourly_forecast.dart';

class ForecastService {
  ForecastService({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;

  Future<List<HourlyForecast>> getForecast(String city) async {
    if (!ApiConfig.hasApiKey) {
      throw Exception('OpenWeather API key is missing.');
    }

    if (city.trim().isEmpty) {
      throw Exception('Please enter a city name.');
    }

    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/forecast',
    ).replace(
      queryParameters: {
        'q': city.trim(),
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
        throw Exception('Unexpected forecast response.');
      }

      if (response.statusCode != 200) {
        final message = decoded['message']?.toString();

        switch (response.statusCode) {
          case 401:
            throw Exception('API key is invalid or inactive.');
          case 404:
            throw Exception('City not found.');
          case 429:
            throw Exception('Forecast request limit reached.');
          default:
            throw Exception(
              message ?? 'Forecast request failed '
                  '(${response.statusCode}).',
            );
        }
      }

      final entries = decoded['list'];

      if (entries is! List) {
        throw Exception('Forecast data is unavailable.');
      }

      final cityInfo = decoded['city'];
      final timezoneOffset = cityInfo is Map<String, dynamic>
          ? (cityInfo['timezone'] as num?)?.toInt() ?? 0
          : 0;

      return entries
          .whereType<Map<String, dynamic>>()
          .map(
            (entry) => HourlyForecast.fromJson(
              entry,
              timezoneOffsetSeconds: timezoneOffset,
            ),
          )
          .toList();
    } on TimeoutException {
      throw Exception('Forecast request timed out. Try again.');
    } on http.ClientException {
      throw Exception('Could not connect to the weather service.');
    } on FormatException {
      throw Exception('Invalid forecast response.');
    }
  }
  
Future<List<HourlyForecast>> getForecastByCoordinates({
  required double latitude,
  required double longitude,
}) async {
  if (!ApiConfig.hasApiKey) {
    throw Exception('OpenWeather API key is missing.');
  }

  final uri = Uri.parse(
    '${ApiConfig.baseUrl}/forecast',
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
      throw Exception('Unexpected forecast response.');
    }

    if (response.statusCode != 200) {
      final message = decoded['message']?.toString();

      switch (response.statusCode) {
        case 401:
          throw Exception('API key is invalid or inactive.');
        case 429:
          throw Exception('Forecast request limit reached.');
        default:
          throw Exception(
            message ?? 'Forecast request failed '
                '(${response.statusCode}).',
          );
      }
    }

    final entries = decoded['list'];

    if (entries is! List) {
      throw Exception('Forecast data is unavailable.');
    }

    final cityInfo = decoded['city'];
    final timezoneOffset = cityInfo is Map<String, dynamic>
        ? (cityInfo['timezone'] as num?)?.toInt() ?? 0
        : 0;

    return entries
        .whereType<Map<String, dynamic>>()
        .map(
          (entry) => HourlyForecast.fromJson(
            entry,
            timezoneOffsetSeconds: timezoneOffset,
          ),
        )
        .toList();
  } on TimeoutException {
    throw Exception('Forecast request timed out. Try again.');
  } on http.ClientException {
    throw Exception('Could not connect to the weather service.');
  } on FormatException {
    throw Exception('Invalid forecast response.');
  }
}


  void dispose() {
    _client.close();
  }
}
