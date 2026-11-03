
import 'package:Sky_Cast/core/app_preferences.dart';
import 'package:Sky_Cast/core/app_translations.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/app_constants.dart';
import '../models/current_weather.dart';
import '../models/hourly_forecast.dart';
import '../models/daily_forecast.dart';
import '../services/weather_service.dart';
import '../services/forecast_service.dart';
import '../services/demo_forecast_service.dart';
import '../services/daily_forecast_service.dart';
import '../widgets/skycast_logo.dart';
import 'weather_details_screen.dart';
import 'search_screen.dart';
import 'settings_screen.dart';
import '../services/location_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final LocationService _locationService = LocationService();
  final WeatherService _weatherService = WeatherService();
  final ForecastService _forecastService = ForecastService();

  final TextEditingController _cityController =
      TextEditingController(text: 'Lahore,PK');

  CurrentWeather? _weather;
  String? _error;

  String _selectedCity = 'Lahore,PK';
  bool _isLoading = false;
  bool _isDemoData = false;
  bool _isDailyForecastDemo = false;

  List<HourlyForecast> _hourlyForecast = [];
  List<DailyForecast> _dailyForecast = [];

  List<HourlyForecast> get hourlyForecast =>
      List.unmodifiable(_hourlyForecast);

  List<DailyForecast> get dailyForecast =>
      List.unmodifiable(_dailyForecast);

  bool get isDailyForecastDemo => _isDailyForecastDemo;

  String get selectedCity => _selectedCity;
  void _onLanguageChanged() {
  if (mounted) {
    setState(() {});
  }
}

Future<void> _loadCurrentLocationWeather() async {
  setState(() {
    _isLoading = true;
    _error = null;
  });

  try {
    final position =
        await _locationService.getCurrentPosition();

    final result =
        await _weatherService.getCurrentWeatherByCoordinates(
      latitude: position.latitude,
      longitude: position.longitude,
    );

    if (!mounted) return;

    setState(() {
      _weather = result;
      _selectedCity = result.cityName;
      _cityController.text = result.cityName;
      _isDemoData = false;
      _error = null;
    });

   final prefs = await SharedPreferences.getInstance();
await prefs.setString('currentCity', result.cityName);
final forecasts =
    await _forecastService.getForecastByCoordinates(
  latitude: position.latitude,
  longitude: position.longitude,
);

if (!mounted) return;

setState(() {
  _hourlyForecast = forecasts;
  _dailyForecast =
      DailyForecastService.fromHourlyForecasts(forecasts);
  _isDailyForecastDemo = false;
});

  } catch (error) {
    if (!mounted) return;

    setState(() {
      _error = error.toString();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Could not get weather for your location: $error',
        ),
      ),
    );
  } finally {
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }
}

  @override
void initState() {
  super.initState();

  AppPreferences.language.addListener(_onLanguageChanged);

  _hourlyForecast = DemoForecastService.getHourlyForecast();
  _loadWeather();
}

  String _greeting() {
  final hour = DateTime.now().hour;

  if (hour < 12) {
    return AppTranslations.text('good_morning');
  }

  if (hour < 17) {
    return AppTranslations.text('good_afternoon');
  }

  return AppTranslations.text('good_evening');
}
  String _formatForecastHour(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final period = time.hour >= 12 ? 'PM' : 'AM';

    return '$hour $period';
  }

  String _formatTime(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';

    return '$hour:$minute $period';
  }

  String _formatDay(DateTime date) {
    final now = DateTime.now();

    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return AppTranslations.text('today');
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

  IconData _forecastIcon(String description) {
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

  CurrentWeather _createDemoWeather(String city) {
    final now =
        DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;

    return CurrentWeather.fromJson({
      'name': city.split(',').first.trim(),
      'sys': {
        'country': 'PK',
        'sunrise': now - 21600,
        'sunset': now + 21600,
      },
      'main': {
        'temp': 29.0,
        'feels_like': 32.0,
        'temp_min': 26.0,
        'temp_max': 33.0,
        'humidity': 65,
        'pressure': 1008,
      },
      'weather': [
        {
          'main': 'Clouds',
          'description': 'partly cloudy',
          'icon': '02d',
        },
      ],
      'wind': {'speed': 3.5},
      'visibility': 10000,
      'dt': now,
      'timezone': 18000,
    });
  }

  Future<void> loadWeather(String city) {
    return _loadWeather(city);
  }

  Future<void> _loadWeather([String? city]) async {
    final requestedCity = (city ?? _selectedCity).trim();

    if (requestedCity.isEmpty) {
      setState(() {
        _error = 'Please enter a city name.';
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await _weatherService.getCurrentWeather(
        requestedCity,
      );

      if (!mounted) return;

      setState(() {
  _weather = result;
  _selectedCity = result.cityName;
  _cityController.text = result.cityName;
  _isDemoData = false;
  _error = null;
});

final prefs = await SharedPreferences.getInstance();
await prefs.setString('currentCity', result.cityName);

      await _loadHourlyForecast(requestedCity);
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _weather = _createDemoWeather(requestedCity);
        _selectedCity = requestedCity;
        _cityController.text = requestedCity;
        _hourlyForecast = DemoForecastService.getHourlyForecast();
        _dailyForecast =
            DailyForecastService.fromHourlyForecasts(_hourlyForecast);
        _isDailyForecastDemo = true;
        _isDemoData = true;
        _error = null;
      });

      debugPrint('Weather unavailable; using demo data: $error');
      await _loadHourlyForecast(requestedCity);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadHourlyForecast(String city) async {
    try {
      final forecast = await _forecastService.getForecast(city);

      if (!mounted) return;

      setState(() {
        _hourlyForecast = forecast;
        _dailyForecast =
            DailyForecastService.fromHourlyForecasts(forecast);
        _isDailyForecastDemo = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _hourlyForecast = DemoForecastService.getHourlyForecast();
        _dailyForecast =
            DailyForecastService.fromHourlyForecasts(_hourlyForecast);
        _isDailyForecastDemo = true;
      });

      debugPrint('Forecast unavailable: $error');
    }
  }

  @override
void dispose() {
  AppPreferences.language.removeListener(_onLanguageChanged);

  _cityController.dispose();
  _weatherService.dispose();
  _forecastService.dispose();

  super.dispose();
}

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final weather = _weather;

    return Scaffold(
      appBar: AppBar(
        title: const SkyCastLogo(
          size: 38,
          showTitle: true,
        ),
        actions: [
          IconButton(
            tooltip: 'Search cities',
            icon: const Icon(Icons.location_city_rounded),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => SearchScreen(
                    onCitySelected: (city) => _loadWeather(city),
                  ),
                ),
              );
            },
          ),
          IconButton(
            tooltip: 'Toggle light/dark theme',
            onPressed: () {
              SkyCastThemeController.toggle(
                isDark ? ThemeMode.light : ThemeMode.dark,
              );
            },
            icon: Icon(
              isDark
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded,
            ),
          ),
          IconButton(
            tooltip: 'Refresh weather',
            onPressed: _isLoading ? null : () => _loadWeather(),
            icon: const Icon(Icons.refresh_rounded),
          ),
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_rounded),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: RefreshIndicator(
              onRefresh: () => _loadWeather(),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
                children: [
                  
ValueListenableBuilder<String>(
  valueListenable: AppPreferences.language,
  builder: (context, language, child) {
    return Text(
      _greeting(),
      style: theme.textTheme.headlineSmall?.copyWith(
        color: isDark
            ? colors.onSurface
            : const Color(0xFF173665),
        fontWeight: FontWeight.w800,
      ),
    );
  },
),

                  const SizedBox(height: 5),
                  
Row(
  children: [
    const Icon(
      Icons.location_on_rounded,
      size: 17,
      color: Color(0xFF2855D9),
    ),
    const SizedBox(width: 4),
    Expanded(
      child: Text(
        weather?.cityName ?? _selectedCity.split(',').first,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: colors.onSurfaceVariant,
        ),
      ),
    ),
    IconButton(
      tooltip: 'Use my current location',
      onPressed: _isLoading
          ? null
          : _loadCurrentLocationWeather,
      icon: const Icon(
        Icons.my_location_rounded,
        color: Color(0xFF2855D9),
      ),
    ),
    if (_isLoading)
      const SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
  ],
),
                  const SizedBox(height: 18),

                  if (weather == null && _isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 70),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (weather == null && _error != null)
                    _buildError(context)
                  else if (weather != null) ...[
                    if (_isDemoData)
                      Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colors.secondaryContainer,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.science_outlined),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                '${AppTranslations.text('demo_mode')}',
                              ),
                            ),
                          ],
                        ),
                      ),

                    if (_error != null) ...[
                      _buildInlineError(context),
                      const SizedBox(height: 12),
                    ],

                    // Main weather card
                    _buildClickableWeatherCard(context, weather),
                    const SizedBox(height: 12),

                    // Compact weather metrics
                    _buildQuickWeatherDetails(context, weather),
                    const SizedBox(height: 24),

                    // Hourly forecast
                    _buildHourlyForecast(context),
                    const SizedBox(height: 22),

                    // Five-day forecast
                    _buildDailyForecast(context),
                    const SizedBox(height: 22),

                    // Extra weather details
                    ValueListenableBuilder<String>(
  valueListenable: AppPreferences.language,
  builder: (context, language, child) {
    return Text(
      AppTranslations.text('weather_details'),
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w800,
      ),
    );
  },
),
                    const SizedBox(height: 12),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.6,
                      children: [
                        _metricCard(
                          context,
                          icon: Icons.speed_rounded,
                          title: AppTranslations.text('pressure'),
                          value: '${weather.pressure} hPa',
                        ),
                        _metricCard(
                          context,
                          icon: Icons.visibility_rounded,
                          title: AppTranslations.text('visibility'),
                          value:
                              '${(weather.visibility / 1000).toStringAsFixed(1)} km',
                        ),
                        _metricCard(
                          context,
                          icon: Icons.thermostat_auto_rounded,
                          title: AppTranslations.text('high') + ' / ' + AppTranslations.text('low'),
                          value:
                              '${AppPreferences.formatTemperature(weather.maxTemperature)} / '
    '${AppPreferences.formatTemperature(weather.minTemperature)}',
                        ),
                        _metricCard(
                          context,
                          icon: Icons.water_drop_rounded,
                          title: AppTranslations.text('humidity'),
                          value: '${weather.humidity}%',
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppTranslations.text('sunrise_sunset'),
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 18),
                            Row(
                              children: [
                                Expanded(
                                  child: _sunTime(
                                    context,
                                    Icons.wb_twilight_rounded,
                                    AppTranslations.text('sunrise'),
                                    _formatTime(weather.sunrise),
                                  ),
                                ),
                                Expanded(
                                  child: _sunTime(
                                    context,
                                    Icons.wb_sunny_rounded,
                                    'Sunset',
                                    _formatTime(weather.sunset),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                     SizedBox(height: 18),
                    Text(
                      '${AppTranslations.text('last_observation')}: '
'${_formatTime(weather.observedAt)}',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildClickableWeatherCard(
    BuildContext context,
    CurrentWeather weather,
  ) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => WeatherDetailsScreen(
              weather: weather,
              hourlyForecast: _hourlyForecast,
            ),
          ),
        );
      },
      child: _buildWeatherCard(context, weather),
    );
  }

  Widget _buildWeatherCard(
    BuildContext context,
    CurrentWeather weather,
  ) {
    final description = weather.description.isEmpty
    ? AppTranslations.text('weather_unavailable')
    : AppTranslations.weatherDescription(weather.description);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2855D9).withValues(alpha: 0.18),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.network(
                'https://images.unsplash.com/photo-1470770841072-f978cf4d019e?w=900&h=600&fit=crop',
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF174A91),
                        Color(0xFF2855D9),
                        Color(0xFF7561D8),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF123C78).withValues(alpha: 0.35),
                      const Color(0xFF102B57).withValues(alpha: 0.82),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          '${weather.cityName}, ${weather.countryCode}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.wb_sunny_rounded,
                        color: Color(0xFFFFCA55),
                        size: 23,
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ValueListenableBuilder<String>(
  valueListenable: AppPreferences.temperatureUnit,
  builder: (context, unit, child) {
    return Text(
      AppPreferences.formatTemperature(weather.temperature),
      style: const TextStyle(
        color: Colors.white,
        fontSize: 52,
        fontWeight: FontWeight.w700,
        height: 1.1,
      ),
    );
  },
),
                            const SizedBox(height: 6),
                            Text(
                              description,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'H: ${AppPreferences.formatTemperature(weather.maxTemperature)}  '
                              'L: ${AppPreferences.formatTemperature(weather.minTemperature)}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        _forecastIcon(weather.description),
                        color: const Color(0xFFFFCA55),
                        size: 66,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickWeatherDetails(
    BuildContext context,
    CurrentWeather weather,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark
        ? Theme.of(context).colorScheme.onSurface
        : const Color(0xFF173665);

    Widget item(String label, String value, IconData icon) {
      return Expanded(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: const Color(0xFF2855D9),
              size: 22,
            ),
            const SizedBox(height: 7),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF78869B),
              ),
            ),
            const SizedBox(height: 4),
            FittedBox(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE5ECF8),
        ),
      ),
      child: Row(
        children: [
          item(
            'Humidity',
            '${weather.humidity}%',
            Icons.water_drop_rounded,
          ),
          item(
            'Wind',
            '${weather.windSpeed.toStringAsFixed(1)} m/s',
            Icons.air_rounded,
          ),
          ValueListenableBuilder<String>(
  valueListenable: AppPreferences.temperatureUnit,
  builder: (context, unit, child) {
    return item(
      'Feels like',
      AppPreferences.formatTemperature(weather.feelsLike),
      Icons.thermostat_rounded,
    );
  },
),
        ],
      ),
    );
  }

  Widget _buildHourlyForecast(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: const BorderSide(color: Color(0xFFE5ECF8)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: ValueListenableBuilder<String>(
  valueListenable: AppPreferences.language,
  builder: (context, language, child) {
    return Text(
      AppTranslations.text('hourly_forecast'),
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w800,
      ),
    );
  },
),
                ),
                Icon(
                  Icons.schedule_rounded,
                  color: colors.primary,
                ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              _isDemoData
    ? AppTranslations.text('sample_hourly')
    : AppTranslations.text('weather_throughout_day'),
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 112,
              child: _hourlyForecast.isEmpty
                  ?  Center(
  child: Text(
    AppTranslations.text('forecast_unavailable'),
  ),
)
                  : ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _hourlyForecast.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        final forecast = _hourlyForecast[index];

                        return Container(
                          width: 68,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: colors.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                               index == 0
    ? AppTranslations.text('now')
    : _formatForecastHour(forecast.time),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontSize: 11,
                                ),
                              ),
                              Icon(
                                _forecastIcon(forecast.description),
                                size: 25,
                                color: colors.primary,
                              ),
                              ValueListenableBuilder<String>(
  valueListenable: AppPreferences.temperatureUnit,
  builder: (context, unit, child) {
    return Text(
      AppPreferences.formatTemperature(forecast.temperature),
      style: theme.textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w800,
      ),
    );
  },
),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyForecast(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: const BorderSide(color: Color(0xFFE5ECF8)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: ValueListenableBuilder<String>(
  valueListenable: AppPreferences.language,
  builder: (context, language, child) {
    return Text(
      AppTranslations.text('daily_forecast'),
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w800,
      ),
    );
  },
),
                ),
                Icon(
                  Icons.calendar_month_rounded,
                  color: colors.primary,
                ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              _isDailyForecastDemo
    ? AppTranslations.text('sample_forecast')
    : AppTranslations.text('upcoming_weather'),
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            if (_dailyForecast.isEmpty)
               Padding(
                padding: EdgeInsets.all(16),
                child: Center(
  child: Text(
    AppTranslations.text('daily_unavailable'),
  ),
)
              )
            else
              ..._dailyForecast.map((day) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 75,
                        child: Text(
                          _formatDay(day.date),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Icon(
                        _forecastIcon(AppTranslations.weatherDescription(day.description),),
                        color: colors.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          day.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                      
ValueListenableBuilder<String>(
  valueListenable: AppPreferences.temperatureUnit,
  builder: (context, unit, child) {
    return Text(
      AppPreferences.formatTemperature(day.highTemperature),
      style: theme.textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w800,
      ),
    );
  },
),

                      const SizedBox(width: 12),
                      SizedBox(
                        width: 30,
                        child: 
ValueListenableBuilder<String>(
  valueListenable: AppPreferences.temperatureUnit,
  builder: (context, unit, child) {
    return Text(
      AppPreferences.formatTemperature(day.lowTemperature),
      textAlign: TextAlign.end,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: colors.onSurfaceVariant,
      ),
    );
  },
),

                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _metricCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
  }) {
    final colors = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Color(0xFFE5ECF8)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: colors.primary,
              size: 23,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sunTime(
    BuildContext context,
    IconData icon,
    String title,
    String value,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 28,
          color: AppConstants.sunshineYellow,
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildError(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Icon(
            Icons.cloud_off_rounded,
            size: 64,
            color: colors.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Weather unavailable',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _error ?? 'Please try again.',
            textAlign: TextAlign.center,
            style: TextStyle(color: colors.onSurfaceVariant),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: _isLoading ? null : () => _loadWeather(),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Try again'),
          ),
        ],
      ),
    );
  }

  Widget _buildInlineError(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.errorContainer,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.info_outline_rounded),
            const SizedBox(width: 10),
            Expanded(child: Text(_error!)),
            TextButton(
              onPressed: () => _loadWeather(),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Controls the app theme without changing existing AppBar actions.
class SkyCastThemeController {
  SkyCastThemeController._();

  static void toggle(ThemeMode mode) {
    SkyCastAppState.themeMode.value = mode;
  }
}

class SkyCastAppState {
  SkyCastAppState._();

  static final ValueNotifier<ThemeMode> themeMode =
      ValueNotifier<ThemeMode>(ThemeMode.system);
}






/* 
import 'package:flutter/material.dart';

import '../core/app_constants.dart';
import '../models/current_weather.dart';
import '../services/weather_service.dart';
import '../widgets/skycast_logo.dart';
import '../models/hourly_forecast.dart';
import '../services/demo_forecast_service.dart';
import '../services/forecast_service.dart';
import '../models/daily_forecast.dart';
import '../services/daily_forecast_service.dart';
import 'weather_details_screen.dart';
import 'search_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  List<HourlyForecast> _hourlyForecast = [];
  List<DailyForecast> _dailyForecast = [];
  List<HourlyForecast> get hourlyForecast =>
    List.unmodifiable(_hourlyForecast);

List<DailyForecast> get dailyForecast =>
    List.unmodifiable(_dailyForecast);

bool get isDailyForecastDemo => _isDailyForecastDemo;

String get selectedCity => _selectedCity;
bool _isDailyForecastDemo = false;
  final ForecastService _forecastService = ForecastService();
  final WeatherService _weatherService = WeatherService();
  final TextEditingController _cityController =
      TextEditingController(text: 'Lahore,PK');
      
      
String _formatForecastHour(DateTime time) {
  final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
  final period = time.hour >= 12 ? 'PM' : 'AM';

  return '$hour $period';
}

IconData _forecastIcon(String description) {
  final text = description.toLowerCase();

  if (text.contains('rain') || text.contains('drizzle')) {
    return Icons.water_drop_rounded;
  }
  if (text.contains('thunder')) {
    return Icons.thunderstorm_rounded;
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


  /* CurrentWeather? _weather;
  String? _error;
  String _selectedCity = 'Lahore,PK';
  bool _isLoading = false; */
CurrentWeather? _weather;
String? _error;
String _selectedCity = 'Lahore,PK';
bool _isLoading = false;
bool _isDemoData = false;

  @override
  void initState() {
    super.initState();
    _hourlyForecast = DemoForecastService.getHourlyForecast();
    _loadWeather();
    _loadHourlyForecast(_selectedCity);
  }
CurrentWeather _createDemoWeather(String city) {
  final now = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;

  return CurrentWeather.fromJson({
    'name': city.split(',').first.trim(),
    'sys': {
      'country': 'PK',
      'sunrise': now - 21600,
      'sunset': now + 21600,
    },
    'main': {
      'temp': 29.0,
      'feels_like': 32.0,
      'temp_min': 26.0,
      'temp_max': 33.0,
      'humidity': 65,
      'pressure': 1008,
    },
    'weather': [
      {
        'main': 'Clouds',
        'description': 'partly cloudy',
        'icon': '02d',
      },
    ],
    'wind': {'speed': 3.5},
    'visibility': 10000,
    'dt': now,
    'timezone': 18000,
  });
}

Future<void> _loadHourlyForecast(String city) async {
  try {
    final forecast = await _forecastService.getForecast(city);

    if (!mounted) return;

    setState(() {
  _hourlyForecast = forecast;
  _dailyForecast =
      DailyForecastService.fromHourlyForecasts(forecast);
  _isDailyForecastDemo = false;
});
  } catch (error) {
    if (!mounted) return;

    // Keep the existing sample forecast as a fallback.
    setState(() {
  _hourlyForecast = DemoForecastService.getHourlyForecast();
  _dailyForecast =
      DailyForecastService.fromHourlyForecasts(_hourlyForecast);
  _isDailyForecastDemo = true;
});

    debugPrint('Forecast unavailable: $error');
  }
}
Future<void> loadWeather(String city) {
  return _loadWeather(city);
}

  Future<void> _loadWeather([String? city]) async {
    final requestedCity = (city ?? _selectedCity).trim();

    if (requestedCity.isEmpty) {
      setState(() {
        _error = 'Please enter a city name.';
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await _weatherService.getCurrentWeather(
        requestedCity,
      );

      if (!mounted) return;

      /* setState(() {
        _weather = result;
        _selectedCity = requestedCity;
        _cityController.text = requestedCity;
        _error = null;
      }); */
      setState(() {
  _weather = result;
  _loadHourlyForecast(requestedCity);
  _selectedCity = requestedCity;
  _cityController.text = requestedCity;
  _error = null;
  _isDemoData = false;
});
    } 
    /* on WeatherException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error =
            'Something went wrong. Please try again.';
      }); */
       catch (_) {
  if (!mounted) return;

  setState(() {
    _weather = _createDemoWeather(requestedCity);
    _loadHourlyForecast(requestedCity);
    _hourlyForecast = DemoForecastService.getHourlyForecast();
    _selectedCity = requestedCity;
    _cityController.text = requestedCity;
    _isDemoData = true;
    _error = null;
  });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _cityController.dispose();
    _weatherService.dispose();
    _forecastService.dispose();
    super.dispose();
  }

  String _formatTime(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';

    return '$hour:$minute $period';
  }
  
String _formatDay(DateTime date) {
  final now = DateTime.now();

  if (date.year == now.year &&
      date.month == now.month &&
      date.day == now.day) {
    return 'Today';
  }

  const weekdays = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday',
    'Friday', 'Saturday', 'Sunday',
  ];

  return weekdays[date.weekday - 1];
}

Widget _buildDailyForecast(BuildContext context) {
  final theme = Theme.of(context);
  final colors = theme.colorScheme;

  return Card(
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '5-day forecast',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Icon(Icons.calendar_month_rounded),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            _isDailyForecastDemo
                ? 'Sample forecast · Not live data'
                : 'Daily outlook · Live forecast',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          if (_dailyForecast.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: Text('Daily forecast is not available.'),
              ),
            )
          else
            ..._dailyForecast.map((day) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    SizedBox(
                      width: 92,
                      child: Text(
                        _formatDay(day.date),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Icon(
                      _forecastIcon(day.description),
                      color: colors.primary,
                      size: 25,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        day.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                    Text(
                      '${day.highTemperature.round()}°',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 34,
                      child: Text(
                        '${day.lowTemperature.round()}°',
                        textAlign: TextAlign.end,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    ),
  );
}


 
@override
Widget build(BuildContext context) {
  final theme = Theme.of(context);
  final colors = theme.colorScheme;
  final isDark = theme.brightness == Brightness.dark;
  final weather = _weather;

  return Scaffold(
    appBar: AppBar(
      title: const SkyCastLogo(
        size: 38,
        showTitle: true,
      ),
      actions: [
        IconButton(
          tooltip: 'Search cities',
          icon: const Icon(Icons.location_city_rounded),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => SearchScreen(
                  onCitySelected: (city) => _loadWeather(city),
                ),
              ),
            );
          },
        ),
        IconButton(
          tooltip: 'Toggle light/dark theme',
          onPressed: () {
            SkyCastThemeController.toggle(
              isDark ? ThemeMode.light : ThemeMode.dark,
            );
          },
          icon: Icon(
            isDark
                ? Icons.light_mode_rounded
                : Icons.dark_mode_rounded,
          ),
        ),
        IconButton(
          tooltip: 'Refresh weather',
          onPressed: _isLoading ? null : () => _loadWeather(),
          icon: const Icon(Icons.refresh_rounded),
        ),
        IconButton(
  tooltip: 'Settings',
  icon: const Icon(Icons.settings_rounded),
  onPressed: () {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const SettingsScreen(),
      ),
    );
  },
),
      ],
    ),
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: RefreshIndicator(
            onRefresh: () => _loadWeather(),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(
                AppConstants.screenPadding,
              ),
              children: [
                Text(
                  'Your weather, at a glance',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Discover the weather wherever you are.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 22),

                TextField(
                  controller: _cityController,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (value) => _loadWeather(value),
                  decoration: InputDecoration(
                    hintText: 'Search a city, e.g. Karachi',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: IconButton(
                      tooltip: 'Search',
                      onPressed: _isLoading
                          ? null
                          : () => _loadWeather(_cityController.text),
                      icon: const Icon(Icons.arrow_forward_rounded),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                if (_isLoading && weather == null)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 72),
                    child: Center(
                      child: Column(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 18),
                          Text('Fetching live weather...'),
                        ],
                      ),
                    ),
                  )
                else if (_error != null && weather == null)
                  _buildError(context)
                else if (weather != null) ...[
                  if (_isDemoData)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: colors.secondaryContainer,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.science_outlined),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Demo mode: sample weather data, '
                              'not live conditions.',
                            ),
                          ),
                        ],
                      ),
                    ),

                  if (_error != null) ...[
                    _buildInlineError(context),
                    const SizedBox(height: 12),
                  ],

                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Hourly forecast',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const Icon(Icons.schedule_rounded),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Forecast intervals · 3-hour steps',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 130,
                            child: _hourlyForecast.isEmpty
                                ? const Center(
                                    child: Text(
                                      'Hourly forecast unavailable',
                                    ),
                                  )
                                : ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: _hourlyForecast.length,
                                    separatorBuilder: (_, _) =>
                                        const SizedBox(width: 12),
                                    itemBuilder: (context, index) {
                                      final forecast =
                                          _hourlyForecast[index];

                                      return Container(
                                        width: 82,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color: colors.surfaceContainerHighest,
                                          borderRadius:
                                              BorderRadius.circular(18),
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              index == 0
                                                  ? 'Now'
                                                  : _formatForecastHour(
                                                      forecast.time,
                                                    ),
                                              style:
                                                  theme.textTheme.bodySmall,
                                            ),
                                            Icon(
                                              _forecastIcon(
                                                forecast.description,
                                              ),
                                              size: 27,
                                              color: colors.primary,
                                            ),
                                            Text(
                                              '${forecast.temperature.round()}°',
                                              style: theme
                                                  .textTheme.titleMedium
                                                  ?.copyWith(
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),

                  _buildDailyForecast(context),
                  const SizedBox(height: 22),

                  _buildClickableWeatherCard(context, weather),
                  const SizedBox(height: 22),

                  Text(
                    'Weather details',
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
                      _metricCard(
                        context,
                        icon: Icons.thermostat_rounded,
                        title: 'Feels like',
                        value: '${weather.feelsLike.round()}°C',
                      ),
                      _metricCard(
                        context,
                        icon: Icons.water_drop_rounded,
                        title: 'Humidity',
                        value: '${weather.humidity}%',
                      ),
                      _metricCard(
                        context,
                        icon: Icons.air_rounded,
                        title: 'Wind speed',
                        value:
                            '${(weather.windSpeed * 3.6).round()} km/h',
                      ),
                      _metricCard(
                        context,
                        icon: Icons.speed_rounded,
                        title: 'Pressure',
                        value: '${weather.pressure} hPa',
                      ),
                      _metricCard(
                        context,
                        icon: Icons.visibility_rounded,
                        title: 'Visibility',
                        value:
                            '${(weather.visibility / 1000).toStringAsFixed(1)} km',
                      ),
                      _metricCard(
                        context,
                        icon: Icons.thermostat_auto_rounded,
                        title: 'High / Low',
                        value:
                            '${weather.maxTemperature.round()}° / '
                            '${weather.minTemperature.round()}°',
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),

                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sunrise & sunset',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              Expanded(
                                child: _sunTime(
                                  context,
                                  Icons.wb_twilight_rounded,
                                  'Sunrise',
                                  _formatTime(weather.sunrise),
                                ),
                              ),
                              Expanded(
                                child: _sunTime(
                                  context,
                                  Icons.wb_sunny_rounded,
                                  'Sunset',
                                  _formatTime(weather.sunset),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Text(
                    'Last weather observation: '
                    '${_formatTime(weather.observedAt)}',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),

                  if (_isLoading) ...[
                    const SizedBox(height: 12),
                    const LinearProgressIndicator(),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

  
Widget _buildClickableWeatherCard(
  BuildContext context,
  CurrentWeather weather,
) {
  return GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: () {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => WeatherDetailsScreen(
  weather: weather,
  hourlyForecast: _hourlyForecast,
)
        ),
      );
    },
    child: _buildWeatherCard(context, weather),
  );
}

  Widget _buildWeatherCard(
    BuildContext context,
    CurrentWeather weather,
  ) {
    final theme = Theme.of(context);

    return Container(
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
            color: AppConstants.primaryBlue.withValues(alpha: 0.20),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.location_on_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '${weather.cityName}, ${weather.countryCode}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Icon(
                Icons.public_rounded,
                color: Colors.white70,
              ),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${weather.temperature.round()}°',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 72,
                        fontWeight: FontWeight.w300,
                        height: 1.05,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      weather.description[0].toUpperCase() +
                          weather.description.substring(1),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'H: ${weather.maxTemperature.round()}°  '
                      'L: ${weather.minTemperature.round()}°',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
  _forecastIcon(weather.description),
  size: 88,
  color: Colors.white,
)
            ],
          ),
        ],
      ),
    );
  }

  Widget _metricCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
  }) {
    final colors = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
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

  Widget _sunTime(
    BuildContext context,
    IconData icon,
    String title,
    String value,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 28,
          color: AppConstants.sunshineYellow,
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildError(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Icon(
            Icons.cloud_off_rounded,
            size: 64,
            color: colors.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Weather unavailable',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _error ?? 'Please try again.',
            textAlign: TextAlign.center,
            style: TextStyle(color: colors.onSurfaceVariant),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: _isLoading ? null : () => _loadWeather(),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Try again'),
          ),
        ],
      ),
    );
  }

  Widget _buildInlineError(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.errorContainer,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.info_outline_rounded),
            const SizedBox(width: 10),
            Expanded(child: Text(_error!)),
            TextButton(
              onPressed: () => _loadWeather(),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Temporary theme controller; we'll improve persistence in a later step.
class SkyCastThemeController {
  SkyCastThemeController._();

  static void toggle(ThemeMode mode) {
    SkyCastAppState.themeMode.value = mode;
  }
}

class SkyCastAppState {
  SkyCastAppState._();

  static final ValueNotifier<ThemeMode> themeMode =
      ValueNotifier<ThemeMode>(ThemeMode.system);
}
 */