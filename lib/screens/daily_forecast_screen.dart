
import 'package:flutter/material.dart';

import '../core/app_preferences.dart';
import '../core/app_translations.dart';
import '../models/daily_forecast.dart';

class DailyForecastScreen extends StatelessWidget {
  final List<DailyForecast> forecasts;
  final bool isDemo;
  final String city;

  const DailyForecastScreen({
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

  String _dayName(DateTime date, int index) {
    if (index == 0) return AppTranslations.text('today');

    const dayKeys = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday',
    ];

    return AppTranslations.text(dayKeys[date.weekday - 1]);
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
                              AppTranslations.text('five_day_forecast'),
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
                                'daily_forecast_unavailable',
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
                                    final day = entry.value;
                                    final description =
                                        day.description.isEmpty
                                            ? AppTranslations.text(
                                                'conditions_unavailable',
                                              )
                                            : AppTranslations
                                                .weatherDescription(
                                                day.description,
                                              );

                                    final rawDescription =
                                        day.description.toLowerCase();

                                    final isSunny =
                                        rawDescription.contains('clear') ||
                                        rawDescription.contains('sun');

                                    return Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 19,
                                          ),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                flex: 5,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      _dayName(day.date, index),
                                                      style: const TextStyle(
                                                        color: Color(
                                                          0xFF243957,
                                                        ),
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 6),
                                                    Text(
                                                      description,
                                                      style: const TextStyle(
                                                        color: Color(
                                                          0xFF64748B,
                                                        ),
                                                        fontSize: 11,
                                                      ),
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Expanded(
                                                flex: 2,
                                                child: Icon(
                                                  _weatherIcon(
                                                    day.description,
                                                  ),
                                                  size: 27,
                                                  color: isSunny
                                                      ? const Color(
                                                          0xFFFFB92E,
                                                        )
                                                      : const Color(
                                                          0xFF7BA9E8,
                                                        ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 3,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: [
                                                    Text(
                                                      AppPreferences
                                                          .formatTemperature(
                                                        day.highTemperature,
                                                      ),
                                                      style: const TextStyle(
                                                        color: Color(
                                                          0xFF243957,
                                                        ),
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w800,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      AppPreferences
                                                          .formatTemperature(
                                                        day.lowTemperature,
                                                      ),
                                                      style: const TextStyle(
                                                        color: Color(
                                                          0xFF94A3B8,
                                                        ),
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (index != forecasts.length - 1)
                                          const Divider(
                                            height: 1,
                                            indent: 16,
                                            endIndent: 16,
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

import '../models/daily_forecast.dart';

class DailyForecastScreen extends StatelessWidget {
  final List<DailyForecast> forecasts;
  final bool isDemo;
  final String city;

  const DailyForecastScreen({
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

  String _dayName(DateTime date, int index) {
    if (index == 0) return 'Today';

    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    return days[date.weekday - 1];
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
              child: Row(
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
                          '5 Day Forecast',
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
            ),
            Expanded(
              child: forecasts.isEmpty
                  ? Center(
                      child: Text(
                        'Daily forecast is not available.',
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
                                final day = entry.value;
                                final description =
                                    day.description.isEmpty
                                        ? 'Conditions unavailable'
                                        : day.description;

                                final isSunny =
                                    description.toLowerCase().contains(
                                          'clear',
                                        ) ||
                                    description.toLowerCase().contains('sun');

                                return Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 19,
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            flex: 5,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  _dayName(day.date, index),
                                                  style: const TextStyle(
                                                    color: Color(0xFF243957),
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                                const SizedBox(height: 6),
                                                Text(
                                                  description[0].toUpperCase() +
                                                      description.substring(1),
                                                  style: const TextStyle(
                                                    color: Color(0xFF64748B),
                                                    fontSize: 11,
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Icon(
                                              _weatherIcon(description),
                                              size: 27,
                                              color: isSunny
                                                  ? const Color(0xFFFFB92E)
                                                  : const Color(0xFF7BA9E8),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 3,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                Text(
                                                  '${day.highTemperature.round()}°',
                                                  style: const TextStyle(
                                                    color: Color(0xFF243957),
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w800,
                                                  ),
                                                ),
                                                const SizedBox(width: 9),
                                                Text(
                                                  '${day.lowTemperature.round()}°',
                                                  style: const TextStyle(
                                                    color: Color(0xFF94A3B8),
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (index != forecasts.length - 1)
                                      const Divider(
                                        height: 1,
                                        indent: 16,
                                        endIndent: 16,
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

import '../models/daily_forecast.dart';

class DailyForecastScreen extends StatelessWidget {
  final List<DailyForecast> forecasts;
  final bool isDemo;

  const DailyForecastScreen({
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

  String _formatDay(DateTime date) {
    final now = DateTime.now();

    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return 'Today';
    }

    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    return weekdays[date.weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          '5-Day Forecast',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Plan ahead with daily temperatures and weather conditions.',
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
          const Center(child: Text('Daily forecast is not available.'))
        else
          ...forecasts.map((day) {
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 18,
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 78,
                      child: Text(
                        _formatDay(day.date),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Icon(
                      _weatherIcon(day.description),
                      color: colors.primary,
                      size: 30,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        day.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${day.highTemperature.round()}°',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          '${day.lowTemperature.round()}°',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }
} */