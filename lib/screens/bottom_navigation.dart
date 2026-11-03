
import 'package:Sky_Cast/models/daily_forecast.dart';
import 'package:Sky_Cast/models/hourly_forecast.dart';
import 'package:Sky_Cast/screens/daily_forecast_screen.dart';
import 'package:Sky_Cast/screens/hourly_forecast_screen.dart';
import 'package:flutter/material.dart';

import 'home_screen.dart';
import 'search_screen.dart';
import 'settings_screen.dart';

class BottomNavigationScreen extends StatefulWidget {
  const BottomNavigationScreen({super.key});

  @override
  State<BottomNavigationScreen> createState() =>
      _BottomNavigationScreenState();
}

class _BottomNavigationScreenState
    extends State<BottomNavigationScreen> {
  int _selectedIndex = 0;

  // HomeScreen currently owns the weather-loading logic.
  // Keep one HomeScreen instance so its state is preserved.
  final GlobalKey<HomeScreenState> _homeKey =
    GlobalKey<HomeScreenState>();

late final Widget _homeScreen;

@override
void initState() {
  super.initState();
  _homeScreen = HomeScreen(key: _homeKey);
}

  void _selectTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _homeScreen,

          _ForecastTab(
  hourlyForecast:
      _homeKey.currentState?.hourlyForecast ??
          const <HourlyForecast>[],
  dailyForecast:
      _homeKey.currentState?.dailyForecast ??
          const <DailyForecast>[],
  isDemo:
      _homeKey.currentState?.isDailyForecastDemo ?? true,
    city: _homeKey.currentState?.selectedCity ?? 'Your City',
),

          // SearchScreen requires a weather callback.
          // It will be connected to HomeScreen in the next step.
          _SearchTab(
  onCitySelected: (city) async {
    await _homeKey.currentState?.loadWeather(city);

    if (mounted) {
      setState(() {
        _selectedIndex = 0;
      });
    }
  },
),

          const SettingsScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _selectTab,
        backgroundColor: theme.colorScheme.surface,
        indicatorColor:
            theme.colorScheme.primary.withValues(alpha: 0.12),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.wb_cloudy_outlined),
            selectedIcon: Icon(Icons.wb_cloudy_rounded),
            label: 'Forecast',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_rounded),
            label: 'Search',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class _ForecastTab extends StatelessWidget {
  final List<HourlyForecast> hourlyForecast;
  final List<DailyForecast> dailyForecast;
  final bool isDemo;
  final String city;

  const _ForecastTab({
    required this.hourlyForecast,
    required this.dailyForecast,
    required this.isDemo,
    required this.city,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Forecast'),
          bottom: const TabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.schedule_rounded),
                text: 'Hourly',
              ),
              Tab(
                icon: Icon(Icons.calendar_month_rounded),
                text: '5 Days',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            HourlyForecastScreen(
  forecasts: hourlyForecast,
  isDemo: isDemo,
  city: city,
),
            DailyForecastScreen(
  forecasts: dailyForecast,
  isDemo: isDemo,
  city: city,
),
          ],
        ),
      ),
    );
  }
}

class _SearchTab extends StatelessWidget {
  final Future<void> Function(String city) onCitySelected;

  const _SearchTab({
    required this.onCitySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SearchScreen(
      onCitySelected: onCitySelected,
    );
  }
}