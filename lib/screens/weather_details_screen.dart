
import 'package:flutter/material.dart';

import '../core/app_preferences.dart';
import '../core/app_translations.dart';
import '../models/current_weather.dart';
import '../models/hourly_forecast.dart';

class WeatherDetailsScreen extends StatelessWidget {
  const WeatherDetailsScreen({
    super.key,
    required this.weather,
    this.hourlyForecast = const [],
  });

  final CurrentWeather weather;
  final List<HourlyForecast> hourlyForecast;

  static const Color _blue = Color(0xFF164B87);

  static const String _backgroundUrl =
      'https://images.unsplash.com/photo-1470770841072-f978cf4d019e'
      '?auto=format&fit=crop&w=1200&q=85';

  IconData _weatherIcon(String description) {
    final text = description.toLowerCase();

    if (text.contains('thunder')) return Icons.thunderstorm_rounded;
    if (text.contains('rain') || text.contains('drizzle')) {
      return Icons.water_drop_rounded;
    }
    if (text.contains('snow')) return Icons.ac_unit_rounded;
    if (text.contains('cloud')) return Icons.cloud_rounded;
    if (text.contains('clear') || text.contains('sun')) {
      return Icons.wb_sunny_rounded;
    }

    return Icons.cloud_queue_rounded;
  }

  String _formatTime(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final isUrdu = AppPreferences.language.value == 'Urdu';
    final period = time.hour >= 12
        ? (isUrdu ? 'شام' : 'PM')
        : (isUrdu ? 'صبح' : 'AM');

    return '$hour:$minute $period';
  }

  String _temperature(num celsius) {
    return AppPreferences.formatTemperature(celsius);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isUrdu = AppPreferences.language.value == 'Urdu';

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Scenic weather header
              SizedBox(
                height: 315,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF164B87),
                            Color(0xFF347DB8),
                            Color(0xFF8DAFD6),
                          ],
                        ),
                      ),
                    ),
                    Image.network(
                      _backgroundUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const SizedBox.expand(),
                    ),
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0x55102E59),
                            Color(0x66102E59),
                            Color(0xE6102E59),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 22),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: Colors.white,
                              size: 21,
                            ),
                            tooltip: AppTranslations.text('back'),
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      weather.cityName,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 25,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.location_on_rounded,
                                          color: Colors.white70,
                                          size: 15,
                                        ),
                                        const SizedBox(width: 3),
                                        Text(
                                          weather.countryCode,
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                _weatherIcon(weather.description),
                                color: const Color(0xFFFFD15C),
                                size: 76,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _temperature(weather.temperature),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 58,
                              fontWeight: FontWeight.w300,
                              height: 1.05,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            weather.description.isEmpty
                                ? AppTranslations.text(
                                    'conditions_unavailable',
                                  )
                                : AppTranslations.weatherDescription(
                                    weather.description,
                                  ),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${AppTranslations.text('high')}: '
                            '${_temperature(weather.maxTemperature)}'
                            '   ${AppTranslations.text('low')}: '
                            '${_temperature(weather.minTemperature)}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Weather metric cards
              Transform.translate(
                offset: const Offset(0, -12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Row(
                    children: [
                      Expanded(
                        child: _metricCard(
                          context,
                          Icons.water_drop_rounded,
                          AppTranslations.text('humidity'),
                          '${weather.humidity}%',
                        ),
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: _metricCard(
                          context,
                          Icons.air_rounded,
                          AppTranslations.text('wind'),
                          '${(weather.windSpeed * 3.6).round()} km/h',
                        ),
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: _metricCard(
                          context,
                          Icons.thermostat_rounded,
                          AppTranslations.text('feels_like'),
                          _temperature(weather.feelsLike),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Hourly forecast
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 2, 18, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppTranslations.text('hourly_forecast'),
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: const Color(0xFF19345B),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (hourlyForecast.isEmpty)
                      Card(
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            AppTranslations.text(
                              'forecast_data_unavailable',
                            ),
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      )
                    else
                      SizedBox(
                        height: 112,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: hourlyForecast.length > 6
                              ? 6
                              : hourlyForecast.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(width: 9),
                          itemBuilder: (context, index) {
                            final item = hourlyForecast[index];

                            return Container(
                              width: 76,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFFE3EAF5),
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    index == 0
                                        ? AppTranslations.text('now')
                                        : _formatTime(item.time),
                                    style: const TextStyle(
                                      color: Color(0xFF64748B),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Icon(
                                    _weatherIcon(item.description),
                                    color: const Color(0xFFFFB92E),
                                    size: 23,
                                  ),
                                  Text(
                                    _temperature(item.temperature),
                                    style: const TextStyle(
                                      color: Color(0xFF19345B),
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),

                    const SizedBox(height: 20),

                    // Sunrise and sunset
                    Text(
                      AppTranslations.text('weather_details'),
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: const Color(0xFF19345B),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFE3EAF5),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _sunTime(
                              Icons.wb_twilight_rounded,
                              AppTranslations.text('sunrise'),
                              _formatTime(weather.sunrise),
                            ),
                          ),
                          Container(
                            height: 44,
                            width: 1,
                            color: const Color(0xFFE3EAF5),
                          ),
                          Expanded(
                            child: _sunTime(
                              Icons.wb_sunny_rounded,
                              AppTranslations.text('sunset'),
                              _formatTime(weather.sunset),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),
                    Text(
                      '${AppTranslations.text('last_observation')}: '
                      '${_formatTime(weather.observedAt)}',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _metricCard(
    BuildContext context,
    IconData icon,
    String title,
    String value,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFE3EAF5)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF19345B).withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: _blue, size: 22),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 5),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF19345B),
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sunTime(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: const Color(0xFFFFB92E), size: 25),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: Color(0xFF19345B),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}



/* 
import 'package:flutter/material.dart';

import '../models/current_weather.dart';
import '../models/hourly_forecast.dart';

class WeatherDetailsScreen extends StatelessWidget {
  const WeatherDetailsScreen({
    super.key,
    required this.weather,
    this.hourlyForecast = const [],
  });

  final CurrentWeather weather;
  final List<HourlyForecast> hourlyForecast;

  static const Color _blue = Color(0xFF164B87);

  static const String _backgroundUrl =
      'https://images.unsplash.com/photo-1470770841072-f978cf4d019e'
      '?auto=format&fit=crop&w=1200&q=85';

  IconData _weatherIcon(String description) {
    final text = description.toLowerCase();

    if (text.contains('thunder')) return Icons.thunderstorm_rounded;
    if (text.contains('rain') || text.contains('drizzle')) {
      return Icons.water_drop_rounded;
    }
    if (text.contains('snow')) return Icons.ac_unit_rounded;
    if (text.contains('cloud')) return Icons.cloud_rounded;
    if (text.contains('clear') || text.contains('sun')) {
      return Icons.wb_sunny_rounded;
    }
    return Icons.cloud_queue_rounded;
  }

  String _formatTime(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Scenic city header. No local image assets are required.
              SizedBox(
                height: 315,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF164B87),
                            Color(0xFF347DB8),
                            Color(0xFF8DAFD6),
                          ],
                        ),
                      ),
                    ),
                    Image.network(
                      _backgroundUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const SizedBox.expand(),
                    ),
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0x55102E59),
                            Color(0x66102E59),
                            Color(0xE6102E59),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 22),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: Colors.white,
                              size: 21,
                            ),
                            tooltip: 'Back',
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      weather.cityName,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 25,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.location_on_rounded,
                                          color: Colors.white70,
                                          size: 15,
                                        ),
                                        const SizedBox(width: 3),
                                        Text(
                                          weather.countryCode,
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                _weatherIcon(weather.description),
                                color: const Color(0xFFFFD15C),
                                size: 76,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${weather.temperature.round()}°C',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 58,
                              fontWeight: FontWeight.w300,
                              height: 1.05,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            weather.description.isEmpty
                                ? 'Conditions unavailable'
                                : weather.description[0].toUpperCase() +
                                    weather.description.substring(1),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'H: ${weather.maxTemperature.round()}°'
                            '   L: ${weather.minTemperature.round()}°',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Three compact weather metric cards.
              Transform.translate(
                offset: const Offset(0, -12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Row(
                    children: [
                      Expanded(
                        child: _metricCard(
                          context,
                          Icons.water_drop_rounded,
                          'Humidity',
                          '${weather.humidity}%',
                        ),
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: _metricCard(
                          context,
                          Icons.air_rounded,
                          'Wind',
                          '${(weather.windSpeed * 3.6).round()} km/h',
                        ),
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: _metricCard(
                          context,
                          Icons.thermostat_rounded,
                          'Feels Like',
                          '${weather.feelsLike.round()}°',
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Today's forecast uses the existing hourly data.
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 2, 18, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Today's Forecast",
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: const Color(0xFF19345B),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (hourlyForecast.isEmpty)
                      Card(
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            'Forecast data is not available yet.',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      )
                    else
                      SizedBox(
                        height: 112,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: hourlyForecast.length > 6
                              ? 6
                              : hourlyForecast.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(width: 9),
                          itemBuilder: (context, index) {
                            final item = hourlyForecast[index];

                            return Container(
                              width: 67,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFFE3EAF5),
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    index == 0
                                        ? 'Now'
                                        : _formatTime(item.time),
                                    style: const TextStyle(
                                      color: Color(0xFF64748B),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Icon(
                                    _weatherIcon(item.description),
                                    color: const Color(0xFFFFB92E),
                                    size: 23,
                                  ),
                                  Text(
                                    '${item.temperature.round()}°',
                                    style: const TextStyle(
                                      color: Color(0xFF19345B),
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),

                    const SizedBox(height: 20),

                    Text(
                      'Details',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: const Color(0xFF19345B),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFE3EAF5),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _sunTime(
                              Icons.wb_twilight_rounded,
                              'Sunrise',
                              _formatTime(weather.sunrise),
                            ),
                          ),
                          Container(
                            height: 44,
                            width: 1,
                            color: const Color(0xFFE3EAF5),
                          ),
                          Expanded(
                            child: _sunTime(
                              Icons.wb_sunny_rounded,
                              'Sunset',
                              _formatTime(weather.sunset),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),
                    Text(
                      'Last observation: ${_formatTime(weather.observedAt)}',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _metricCard(
    BuildContext context,
    IconData icon,
    String title,
    String value,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFE3EAF5)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF19345B).withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: _blue, size: 22),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 5),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF19345B),
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sunTime(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: const Color(0xFFFFB92E), size: 25),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: Color(0xFF19345B),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} */

/* 
import 'package:flutter/material.dart';

import '../core/app_constants.dart';
import '../models/current_weather.dart';

class WeatherDetailsScreen extends StatelessWidget {
  const WeatherDetailsScreen({
    super.key,
    required this.weather,
  });

  final CurrentWeather weather;

  IconData _weatherIcon(String description) {
    final text = description.toLowerCase();

    if (text.contains('thunder')) {
      return Icons.thunderstorm_rounded;
    }
    if (text.contains('rain') || text.contains('drizzle')) {
      return Icons.water_drop_rounded;
    }
    if (text.contains('snow')) {
      return Icons.ac_unit_rounded;
    }
    if (text.contains('cloud')) {
      return Icons.cloud_rounded;
    }
    if (text.contains('clear') || text.contains('sun')) {
      return Icons.wb_sunny_rounded;
    }

    return Icons.cloud_queue_rounded;
  }

  String _formatTime(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';

    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather Details'),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              padding: const EdgeInsets.all(
                AppConstants.screenPadding,
              ),
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppConstants.primaryBlue,
                        AppConstants.lightBlue,
                        AppConstants.lavender,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: AppConstants.primaryBlue
                            .withValues(alpha: 0.20),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${weather.cityName}, ${weather.countryCode}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Icon(
                        _weatherIcon(weather.description),
                        color: Colors.white,
                        size: 88,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${weather.temperature.round()}°C',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 64,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      Text(
                        weather.description.isEmpty
                            ? 'Weather conditions unavailable'
                            : '${weather.description[0].toUpperCase()}'
                                '${weather.description.substring(1)}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'High ${weather.maxTemperature.round()}°'
                        '  ·  Low ${weather.minTemperature.round()}°',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Current conditions',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 14),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.45,
                  children: [
                    _detailTile(
                      context,
                      Icons.thermostat_rounded,
                      'Feels like',
                      '${weather.feelsLike.round()}°C',
                    ),
                    _detailTile(
                      context,
                      Icons.water_drop_rounded,
                      'Humidity',
                      '${weather.humidity}%',
                    ),
                    _detailTile(
                      context,
                      Icons.air_rounded,
                      'Wind speed',
                      '${(weather.windSpeed * 3.6).round()} km/h',
                    ),
                    _detailTile(
                      context,
                      Icons.speed_rounded,
                      'Pressure',
                      '${weather.pressure} hPa',
                    ),
                    _detailTile(
                      context,
                      Icons.visibility_rounded,
                      'Visibility',
                      '${(weather.visibility / 1000).toStringAsFixed(1)} km',
                    ),
                    _detailTile(
                      context,
                      Icons.wb_twilight_rounded,
                      'Sunrise',
                      _formatTime(weather.sunrise),
                    ),
                    _detailTile(
                      context,
                      Icons.wb_sunny_rounded,
                      'Sunset',
                      _formatTime(weather.sunset),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Last observation: ${_formatTime(weather.observedAt)}',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _detailTile(
    BuildContext context,
    IconData icon,
    String title,
    String value,
  ) {
    final colors = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: colors.primary, size: 25),
            const SizedBox(height: 10),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 5),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
 */