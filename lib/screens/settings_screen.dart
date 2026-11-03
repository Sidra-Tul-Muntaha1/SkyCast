
import 'package:Sky_Cast/core/app_preferences.dart';
import 'package:Sky_Cast/core/app_translations.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _temperatureUnit = '°C';
  String _defaultCity = 'Islamabad';
  String _currentCity = 'Lahore';
  String _language = 'English';
  String _refreshInterval = 'Every 30 minutes';

  bool _notificationsEnabled = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    AppPreferences.language.addListener(_onLanguageChanged);
    _loadSettings();
  }

  void _onLanguageChanged() {
    if (mounted) {
      setState(() {
        _language = AppPreferences.language.value;
      });
    }
  }

  @override
  void dispose() {
    AppPreferences.language.removeListener(_onLanguageChanged);
    super.dispose();
  }

  String _refreshIntervalKey(String interval) {
    switch (interval) {
      case 'Every 15 minutes':
        return 'every_15_minutes';
      case 'Every 30 minutes':
        return 'every_30_minutes';
      case 'Every hour':
        return 'every_hour';
      case 'Manual only':
        return 'manual_only';
      default:
        return interval;
    }
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (!mounted) return;

      setState(() {
        _temperatureUnit = AppPreferences.temperatureUnit.value;
        _defaultCity = prefs.getString('defaultCity') ?? 'Islamabad';
        _currentCity = prefs.getString('currentCity') ??
            prefs.getString('defaultCity') ??
            'Lahore';
        _language = AppPreferences.language.value;
        _refreshInterval =
            prefs.getString('refreshInterval') ?? 'Every 30 minutes';
        _notificationsEnabled =
            prefs.getBool('notificationsEnabled') ?? true;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveSetting(String key, Object value) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (value is String) {
        await prefs.setString(key, value);
      } else if (value is bool) {
        await prefs.setBool(key, value);
      }
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppTranslations.text('could_not_save_preference'),
          ),
        ),
      );
    }
  }

  Future<void> _editDefaultCity() async {
    final controller = TextEditingController(text: _defaultCity);

    final city = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppTranslations.text('default_city')),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            labelText: AppTranslations.text('city_name'),
            hintText: AppTranslations.text('city_hint'),
          ),
          onSubmitted: (value) {
            final trimmed = value.trim();
            if (trimmed.isNotEmpty) {
              Navigator.pop(dialogContext, trimmed);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(AppTranslations.text('cancel')),
          ),
          FilledButton(
            onPressed: () {
              final trimmed = controller.text.trim();
              if (trimmed.isNotEmpty) {
                Navigator.pop(dialogContext, trimmed);
              }
            },
            child: Text(AppTranslations.text('save')),
          ),
        ],
      ),
    );

    controller.dispose();

    if (city == null || city.isEmpty || !mounted) return;

    setState(() => _defaultCity = city);
    await _saveSetting('defaultCity', city);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      TextSnackBar.message(
        '${AppTranslations.text('default_city_saved')}: $city',
      ),
    );
  }

  Future<void> _chooseLanguage() async {
    final language = await showDialog<String>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: Text(AppTranslations.text('choose_language')),
        children: [
          for (final language in ['English', 'Urdu'])
            RadioListTile<String>(
              title: Text(
                AppTranslations.text(language.toLowerCase()),
              ),
              value: language,
              groupValue: _language,
              onChanged: (value) {
                if (value != null) {
                  Navigator.pop(dialogContext, value);
                }
              },
            ),
        ],
      ),
    );

    if (language == null || !mounted) return;

    try {
      await AppPreferences.setLanguage(language);

      if (mounted) {
        setState(() => _language = language);
      }
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppTranslations.text('could_not_save_preference'),
          ),
        ),
      );
    }
  }

  Future<void> _chooseRefreshInterval() async {
    const intervals = [
      'Every 15 minutes',
      'Every 30 minutes',
      'Every hour',
      'Manual only',
    ];

    final selected = await showDialog<String>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: Text(AppTranslations.text('refresh_preference')),
        children: [
          for (final interval in intervals)
            RadioListTile<String>(
              title: Text(
                AppTranslations.text(_refreshIntervalKey(interval)),
              ),
              value: interval,
              groupValue: _refreshInterval,
              onChanged: (value) {
                if (value != null) {
                  Navigator.pop(dialogContext, value);
                }
              },
            ),
        ],
      ),
    );

    if (selected == null || !mounted) return;

    setState(() => _refreshInterval = selected);
    await _saveSetting('refreshInterval', selected);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${AppTranslations.text('refresh_preference_saved')} '
          '${selected == 'Manual only' ? '' : AppTranslations.text('manual_refresh_note')}',
        ),
      ),
    );
  }

  void _showAbout() {
    showAboutDialog(
      context: context,
      applicationName: AppTranslations.text('skycast'),
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(
        Icons.wb_cloudy_rounded,
        size: 42,
        color: Color(0xFF2855D9),
      ),
      children: [
        Text(AppTranslations.text('your_weather_always')),
        const SizedBox(height: 8),
        Text(AppTranslations.text('about_description')),
      ],
    );
  }

  void _showAppPreferences() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppTranslations.text('app_preferences'),
                style: Theme.of(sheetContext)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.sync_rounded),
                title: Text(
                  AppTranslations.text('refresh_preference'),
                ),
                subtitle: Text(
                  AppTranslations.text(
                    _refreshIntervalKey(_refreshInterval),
                  ),
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _chooseRefreshInterval();
                },
              ),
              ListTile(
                leading: const Icon(Icons.info_outline_rounded),
                title: Text(
                  AppTranslations.text('about_skycast'),
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _showAbout();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _settingsCard({required Widget child}) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.35),
        ),
      ),
      child: child,
    );
  }

  Widget _settingRow({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 3,
      ),
      leading: Icon(
        icon,
        color: const Color(0xFF2855D9),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: subtitle == null ? null : Text(subtitle),
      trailing:
          trailing ?? const Icon(Icons.chevron_right_rounded, size: 21),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppTranslations.text('settings'),
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  AppTranslations.text('personalize_your_experience'),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 22),

                // Temperature units
                _settingsCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.thermostat_rounded,
                              color: Color(0xFF2855D9),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              AppTranslations.text('temperature_unit'),
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SegmentedButton<String>(
                          segments: const [
                            ButtonSegment(
                              value: '°C',
                              label: Text('°C'),
                            ),
                            ButtonSegment(
                              value: '°F',
                              label: Text('°F'),
                            ),
                          ],
                          selected: {_temperatureUnit},
                          onSelectionChanged: (selection) async {
                            final unit = selection.first;
                            setState(() => _temperatureUnit = unit);

                            try {
                              await AppPreferences.setTemperatureUnit(unit);
                            } catch (_) {
                              if (!mounted) return;

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    AppTranslations.text(
                                      'could_not_save_preference',
                                    ),
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Notifications preference
                _settingsCard(
                  child: SwitchListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    secondary: const Icon(
                      Icons.notifications_active_outlined,
                      color: Color(0xFF2855D9),
                    ),
                    title: Text(
                      AppTranslations.text('notifications'),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      AppTranslations.text('notification_preference'),
                    ),
                    value: _notificationsEnabled,
                    onChanged: (value) {
                      setState(() => _notificationsEnabled = value);
                      _saveSetting('notificationsEnabled', value);
                    },
                  ),
                ),
                const SizedBox(height: 14),

                // Current weather location
                _settingsCard(
                  child: _settingRow(
                    icon: Icons.location_on_outlined,
                    title: AppTranslations.text('current_location'),
                    subtitle: _currentCity,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${AppTranslations.text('current_weather_location')}: '
                            '$_currentCity. '
                            '${AppTranslations.text('change_from_home_screen')}',
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 14),

                // Default city
                _settingsCard(
                  child: _settingRow(
                    icon: Icons.location_searching_rounded,
                    title: AppTranslations.text('default_city'),
                    subtitle: _defaultCity,
                    onTap: _editDefaultCity,
                  ),
                ),
                const SizedBox(height: 14),

                // Language
                _settingsCard(
                  child: ValueListenableBuilder<String>(
                    valueListenable: AppPreferences.language,
                    builder: (context, language, child) {
                      return _settingRow(
                        icon: Icons.language_rounded,
                        title: AppTranslations.text('language'),
                        subtitle: AppTranslations.text(
                          language.toLowerCase(),
                        ),
                        onTap: _chooseLanguage,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 14),

                // App preferences
                _settingsCard(
                  child: _settingRow(
                    icon: Icons.tune_rounded,
                    title: AppTranslations.text('app_preferences'),
                    onTap: _showAppPreferences,
                  ),
                ),
                const SizedBox(height: 14),

                // About
                _settingsCard(
                  child: _settingRow(
                    icon: Icons.info_outline_rounded,
                    title: AppTranslations.text('about_app'),
                    onTap: _showAbout,
                  ),
                ),
                const SizedBox(height: 24),

                Center(
                  child: Text(
                    AppTranslations.text('skycast_your_weather_always'),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class TextSnackBar {
  static SnackBar message(String message) {
    return SnackBar(content: Text(message));
  }
}



/* 
import 'package:Sky_Cast/core/app_preferences.dart';
import 'package:Sky_Cast/core/app_translations.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _temperatureUnit = '°C';
  String _defaultCity = 'Islamabad';
  String _currentCity = 'Lahore';
  String _language = 'English';
  String _refreshInterval = 'Every 30 minutes';

  bool _notificationsEnabled = true;
  bool _isLoading = true;

  @override
void initState() {
  super.initState();

  AppPreferences.language.addListener(_onLanguageChanged);
  _loadSettings();
}
  void _onLanguageChanged() {
  if (mounted) {
    setState(() {});
  }
}
@override
void dispose() {
  AppPreferences.language.removeListener(_onLanguageChanged);
  super.dispose();
}
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      

      if (!mounted) return;

      setState(() {
       _temperatureUnit = AppPreferences.temperatureUnit.value;
        _defaultCity = prefs.getString('defaultCity') ?? 'Islamabad';
        _currentCity = prefs.getString('currentCity') ??
    prefs.getString('defaultCity') ??
    'Lahore';
        _language = AppPreferences.language.value;
        _refreshInterval =
            prefs.getString('refreshInterval') ?? 'Every 30 minutes';
        _notificationsEnabled =
            prefs.getBool('notificationsEnabled') ?? true;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveSetting(String key, Object value) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (value is String) {
        await prefs.setString(key, value);
      } else if (value is bool) {
        await prefs.setBool(key, value);
      }
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(
          content: Text(AppTranslations.text('could_not_save_preference')),
        ),
      );
    }
  }

  Future<void> _editDefaultCity() async {
    final controller = TextEditingController(text: _defaultCity);

    final city = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title:  Text(AppTranslations.text('default_city')),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration:  InputDecoration(
            labelText: AppTranslations.text('city_name'),
  hintText: AppTranslations.text('city_hint'),
          ),
          onSubmitted: (value) {
            final trimmed = value.trim();
            if (trimmed.isNotEmpty) {
              Navigator.pop(dialogContext, trimmed);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child:  Text(AppTranslations.text('cancel')),
          ),
          FilledButton(
            onPressed: () {
              final trimmed = controller.text.trim();
              if (trimmed.isNotEmpty) {
                Navigator.pop(dialogContext, trimmed);
              }
            },
            child:  Text(AppTranslations.text('save')),
          ),
        ],
      ),
    );

    controller.dispose();

    if (city == null || city.isEmpty || !mounted) return;

    setState(() => _defaultCity = city);
    await _saveSetting('defaultCity', city);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      TextSnackBar.message(AppTranslations.text('default_city_saved')),
    );
  }

  Future<void> _chooseLanguage() async {
    final language = await showDialog<String>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: Text(AppTranslations.text('choose_language')),
        children: [
          for (final language in ['English', 'Urdu'])
            RadioListTile<String>(
              title: Text(
  AppTranslations.text(language.toLowerCase()),
),
              value: language,
              groupValue: _language,
              onChanged: (value) {
                if (value != null) {
                  Navigator.pop(dialogContext, value);
                }
              },
            ),
        ],
      ),
    );

   if (language == null || !mounted) return;

setState(() => _language = language);

try {
  await AppPreferences.setLanguage(language);
} catch (_) {
  if (!mounted) return;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        AppTranslations.text('could_not_save_preference')),
    ),
  );
}
  }

  Future<void> _chooseRefreshInterval() async {
    const intervals = [
      'Every 15 minutes',
      'Every 30 minutes',
      'Every hour',
      'Manual only',
    ];

    final selected = await showDialog<String>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: Text(AppTranslations.text('refresh_preference')),
        children: [
          for (final interval in intervals)
            RadioListTile<String>(
              title: Text(AppTranslations.text(interval)),
              value: interval,
              groupValue: _refreshInterval,
              onChanged: (value) {
                if (value != null) {
                  Navigator.pop(dialogContext, value);
                }
              },
            ),
        ],
      ),
    );

    if (selected == null || !mounted) return;

    setState(() => _refreshInterval = selected);
    await _saveSetting('refreshInterval', selected);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppTranslations.text('refresh_preference_saved')),
      ),
    );
  }

  void _showAbout() {
    showAboutDialog(
      context: context,
      applicationName: AppTranslations.text('skycast'),
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(
        Icons.wb_cloudy_rounded,
        size: 42,
        color: Color(0xFF2855D9),
      ),
      children: const [
        Text('Your Weather, Always'),
        SizedBox(height: 8),
        Text(
          'SkyCast provides weather information, '
          'hourly forecasts, and five-day forecasts.',
        ),
      ],
    );
  }

  void _showAppPreferences() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppTranslations.text('app_preferences'),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.sync_rounded),
                title: Text(AppTranslations.text('refresh_preference')),
                subtitle: Text(AppTranslations.text(_refreshInterval)),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  Navigator.pop(context);
                  _chooseRefreshInterval();
                },
              ),
              ListTile(
                leading: const Icon(Icons.info_outline_rounded),
                title: Text(AppTranslations.text('about_skycast')),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  Navigator.pop(context);
                  _showAbout();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _settingsCard({
    required Widget child,
  }) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.35),
        ),
      ),
      child: child,
    );
  }

  Widget _settingRow({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 3,
      ),
      leading: Icon(
        icon,
        color: const Color(0xFF2855D9),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: subtitle == null ? null : Text(subtitle),
      trailing: trailing ??
          const Icon(Icons.chevron_right_rounded, size: 21),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppTranslations.text('settings'),
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  AppTranslations.text('personalize_your_experience'),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 22),

                // Temperature units
                _settingsCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.thermostat_rounded,
                              color: Color(0xFF2855D9),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              AppTranslations.text('temperature_unit'),
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SegmentedButton<String>(
                          segments: const [
                            ButtonSegment(
                              value: '°C',
                              label: Text('°C'),
                            ),
                            ButtonSegment(
                              value: '°F',
                              label: Text('°F'),
                            ),
                          ],
                          selected: {_temperatureUnit},
                          onSelectionChanged: (selection) async {
  final unit = selection.first;

  setState(() => _temperatureUnit = unit);

  try {
    await AppPreferences.setTemperatureUnit(unit);
  } catch (_) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Could not save temperature preference.'),
      ),
    );
  }
},
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Notifications
                _settingsCard(
                  child: SwitchListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    secondary: const Icon(
                      Icons.notifications_active_outlined,
                      color: Color(0xFF2855D9),
                    ),
                    title: Text(
                      AppTranslations.text('notifications'),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      AppTranslations.text('notification_preference'),
                    ),
                    value: _notificationsEnabled,
                    onChanged: (value) {
                      setState(() => _notificationsEnabled = value);
                      _saveSetting('notificationsEnabled', value);
                    },
                  ),
                ),
                const SizedBox(height: 14),

                // Location
                // Location
_settingsCard(
  child: _settingRow(
    icon: Icons.location_on_outlined,
    title: AppTranslations.text('current_location'),
    subtitle: AppTranslations.text(_currentCity),
    onTap: () {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${AppTranslations.text('current_weather_location')}: ${AppTranslations.text(_currentCity)}. '
            '${AppTranslations.text('change_from_home_screen')}.',
          ),
        ),
      );
    },
  ),
),
const SizedBox(height: 14),

_settingsCard(
  child: _settingRow(
    icon: Icons.location_searching_rounded,
    title: AppTranslations.text('default_city'),
    subtitle: AppTranslations.text(_defaultCity),
    onTap: _editDefaultCity,
  ),
),
                const SizedBox(height: 14),

                // Language
               
 // Language
_settingsCard(
  child: ValueListenableBuilder<String>(
    valueListenable: AppPreferences.language,
    builder: (context, language, child) {
      return _settingRow(
        icon: Icons.language_rounded,
        title: AppTranslations.text('language'),
        subtitle: AppTranslations.text(language),
        onTap: _chooseLanguage,
      );
    },
  ),
),

                const SizedBox(height: 14),

                // App preferences
                _settingsCard(
                  child: _settingRow(
                    icon: Icons.tune_rounded,
                    title: AppTranslations.text('app_preferences'),
                    onTap: _showAppPreferences,
                  ),
                ),
                const SizedBox(height: 14),

                // About
                _settingsCard(
                  child: _settingRow(
                    icon: Icons.info_outline_rounded,
                    title: AppTranslations.text('about_app'),
                    onTap: _showAbout,
                  ),
                ),
                const SizedBox(height: 24),

                Center(
                  child: Text(
                    AppTranslations.text('skycast_your_weather_always'),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class TextSnackBar {
  static SnackBar message(String message) {
    return SnackBar(content: Text(message));
  }
} */