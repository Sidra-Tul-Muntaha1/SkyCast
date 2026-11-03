
import 'package:flutter/material.dart';

import '../core/app_preferences.dart';
import '../core/app_translations.dart';
import '../models/hourly_forecast.dart';

class HourlyForecastScreen extends StatelessWidget {
  final List<HourlyForecast> forecasts;
  final bool isDemo;
  final String city;

  const HourlyForecastScreen({
    super.key,
    required this.forecasts,
    required this.isDemo,
    this.city = 'Your City',
  });

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
    final isUrdu = AppPreferences.language.value == 'Urdu';
    final period = time.hour >= 12
        ? (isUrdu ? 'شام' : 'PM')
        : (isUrdu ? 'صبح' : 'AM');

    return '$hour $period';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ValueListenableBuilder<String>(
      valueListenable: AppPreferences.language,
      builder: (context, language, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFF3F6FB),
          body: SafeArea(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 26),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF174B85),
                        Color(0xFF367DB8),
                      ],
                    ),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        tooltip: AppTranslations.text('back'),
                        onPressed: () =>
                            Navigator.of(context).maybePop(),
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 19,
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              city,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 19,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              AppTranslations.text('hourly_forecast_title'),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 44),
                    ],
                  ),
                ),
                Expanded(
                  child: forecasts.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Text(
                              AppTranslations.text(
                                'hourly_forecast_unavailable',
                              ),
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                        )
                      : SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(
                            12, 0, 12, 20,
                          ),
                          child: Transform.translate(
                            offset: const Offset(0, -12),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(22),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF173D6B)
                                        .withValues(alpha: 0.07),
                                    blurRadius: 16,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  if (isDemo)
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Text(
                                        AppTranslations.text(
                                          'sample_forecast_not_live',
                                        ),
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: Color(0xFF64748B),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ...forecasts.asMap().entries.map((entry) {
                                    final index = entry.key;
                                    final forecast = entry.value;
                                    final isSunny = forecast.description
                                        .toLowerCase()
                                        .contains('clear');

                                    return Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 18,
                                            vertical: 14,
                                          ),
                                          child: Row(
                                            children: [
                                              SizedBox(
                                                width: 64,
                                                child: Text(
                                                  index == 0
                                                      ? AppTranslations.text(
                                                          'now',
                                                        )
                                                      : _formatTime(
                                                          forecast.time,
                                                        ),
                                                  style: const TextStyle(
                                                    color: Color(0xFF243957),
                                                    fontSize: 13,
                                                    fontWeight:
                                                        FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Align(
                                                  alignment: Alignment.center,
                                                  child: Icon(
                                                    _weatherIcon(
                                                      forecast.description,
                                                    ),
                                                    size: 23,
                                                    color: isSunny
                                                        ? const Color(
                                                            0xFFFFB92E,
                                                          )
                                                        : const Color(
                                                            0xFF7BA9E8,
                                                          ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                width: 58,
                                                child: Text(
                                                  AppPreferences
                                                      .formatTemperature(
                                                    forecast.temperature,
                                                  ),
                                                  textAlign: TextAlign.end,
                                                  style: const TextStyle(
                                                    color: Color(0xFF243957),
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.w700,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (index != forecasts.length - 1)
                                          const Divider(
                                            height: 1,
                                            indent: 18,
                                            endIndent: 18,
                                            color: Color(0xFFEDF1F7),
                                          ),
                                      ],
                                    );
                                  }),
                                ],
                              ),
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}



/* 
import 'package:flutter/material.dart';

import '../models/hourly_forecast.dart';

class HourlyForecastScreen extends StatelessWidget {
  final List<HourlyForecast> forecasts;
  final bool isDemo;
  final String city;

  const HourlyForecastScreen({
    super.key,
    required this.forecasts,
    required this.isDemo,
    this.city = 'Your City',
  });

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
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour $period';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FB),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 26),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF174B85),
                    Color(0xFF367DB8),
                  ],
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 19,
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              city,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 19,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 5),
                            const Text(
                              'Hourly Forecast',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 44),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: forecasts.isEmpty
                  ? Center(
                      child: Text(
                        'Hourly forecast is not available.',
                        style: theme.textTheme.bodyMedium,
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
                      child: Transform.translate(
                        offset: const Offset(0, -12),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF173D6B)
                                    .withValues(alpha: 0.07),
                                blurRadius: 16,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              if (isDemo)
                                const Padding(
                                  padding: EdgeInsets.all(12),
                                  child: Text(
                                    'Sample forecast · Not live data',
                                    style: TextStyle(
                                      color: Color(0xFF64748B),
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ...forecasts.asMap().entries.map((entry) {
                                final index = entry.key;
                                final forecast = entry.value;
                                final isSunny =
                                    forecast.description.toLowerCase().contains(
                                      'clear',
                                    );

                                return Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 18,
                                        vertical: 14,
                                      ),
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            width: 64,
                                            child: Text(
                                              index == 0
                                                  ? 'Now'
                                                  : _formatTime(forecast.time),
                                              style: const TextStyle(
                                                color: Color(0xFF243957),
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Align(
                                              alignment: Alignment.center,
                                              child: Icon(
                                                _weatherIcon(
                                                  forecast.description,
                                                ),
                                                size: 23,
                                                color: isSunny
                                                    ? const Color(0xFFFFB92E)
                                                    : const Color(0xFF7BA9E8),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 48,
                                            child: Text(
                                              '${forecast.temperature.round()}°',
                                              textAlign: TextAlign.end,
                                              style: const TextStyle(
                                                color: Color(0xFF243957),
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (index != forecasts.length - 1)
                                      const Divider(
                                        height: 1,
                                        indent: 18,
                                        endIndent: 18,
                                        color: Color(0xFFEDF1F7),
                                      ),
                                  ],
                                );
                              }),
                            ],
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
} */

/* import 'package:flutter/material.dart';

import '../models/hourly_forecast.dart';

class HourlyForecastScreen extends StatelessWidget {
  final List<HourlyForecast> forecasts;
  final bool isDemo;

  const HourlyForecastScreen({
    super.key,
    required this.forecasts,
    required this.isDemo,
  });

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
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:${time.minute.toString().padLeft(2, '0')} $period';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Hourly Forecast',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Temperature and conditions throughout the forecast period.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
        if (isDemo) ...[
          const SizedBox(height: 16),
          const Text('Sample forecast · Not live data'),
        ],
        const SizedBox(height: 20),
        if (forecasts.isEmpty)
          const Center(child: Text('Hourly forecast is not available.'))
        else
          ...forecasts.asMap().entries.map((entry) {
            final index = entry.key;
            final forecast = entry.value;

            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                leading: Icon(
                  _weatherIcon(forecast.description),
                  color: colors.primary,
                  size: 30,
                ),
                title: Text(
                  index == 0 ? 'Next forecast' : _formatTime(forecast.time),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  forecast.description.isEmpty
                      ? 'Weather conditions unavailable'
                      : forecast.description,
                ),
                trailing: Text(
                  '${forecast.temperature.round()}°C',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            );
          }),
      ],
    );
  }
} */