
import 'package:flutter/material.dart';

import '../core/app_preferences.dart';
import '../core/app_translations.dart';

class SearchScreen extends StatefulWidget {
  final Future<void> Function(String city) onCitySelected;

  const SearchScreen({
    super.key,
    required this.onCitySelected,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _PopularCity {
  final String name;
  final String countryKey;
  final String query;
  final String imageUrl;

  const _PopularCity({
    required this.name,
    required this.countryKey,
    required this.query,
    required this.imageUrl,
  });
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();

  bool _isSearching = false;
  String? _errorKey;

  static const List<_PopularCity> _popularCities = [
    _PopularCity(
      name: 'Lahore',
      countryKey: 'pakistan',
      query: 'Lahore,PK',
      imageUrl:
          'https://images.unsplash.com/photo-1577083552431-6e5fd01aa342?w=160&h=160&fit=crop',
    ),
    _PopularCity(
      name: 'Karachi',
      countryKey: 'pakistan',
      query: 'Karachi,PK',
      imageUrl:
          'https://images.unsplash.com/photo-1519501025264-65ba15a82390?w=160&h=160&fit=crop',
    ),
    _PopularCity(
      name: 'Islamabad',
      countryKey: 'pakistan',
      query: 'Islamabad,PK',
      imageUrl:
          'https://images.unsplash.com/photo-1519608487953-e999c86e7455?w=160&h=160&fit=crop',
    ),
    _PopularCity(
      name: 'Peshawar',
      countryKey: 'pakistan',
      query: 'Peshawar,PK',
      imageUrl:
          'https://images.unsplash.com/photo-1518005020951-eccb494ad742?w=160&h=160&fit=crop',
    ),
    _PopularCity(
      name: 'London',
      countryKey: 'united_kingdom',
      query: 'London,GB',
      imageUrl:
          'https://images.unsplash.com/photo-1513635269975-59663e0ac1ad?w=160&h=160&fit=crop',
    ),
    _PopularCity(
      name: 'Dubai',
      countryKey: 'united_arab_emirates',
      query: 'Dubai,AE',
      imageUrl:
          'https://images.unsplash.com/photo-1512453979798-5ea266f8880c?w=160&h=160&fit=crop',
    ),
    _PopularCity(
      name: 'New York',
      countryKey: 'united_states',
      query: 'New York,US',
      imageUrl:
          'https://images.unsplash.com/photo-1496588152823-86ff7695e68f?w=160&h=160&fit=crop',
    ),
  ];

  Future<void> _searchCity(String city) async {
    if (_isSearching) return;

    final value = city.trim();

    if (value.isEmpty) {
      setState(() => _errorKey = 'empty_city_error');
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isSearching = true;
      _errorKey = null;
    });

    try {
      await widget.onCitySelected(value);

      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _errorKey = 'city_search_error';
      });
    } finally {
      if (mounted) {
        setState(() => _isSearching = false);
      }
    }
  }

  Widget _cityThumbnail(_PopularCity city) {
    return ClipOval(
      child: Image.network(
        city.imageUrl,
        width: 54,
        height: 54,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) {
          return Container(
            width: 54,
            height: 54,
            color: const Color(0xFFE7EEFA),
            alignment: Alignment.center,
            child: const Icon(
              Icons.location_city_rounded,
              color: Color(0xFF2855D9),
              size: 25,
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Rebuild this screen when the selected language changes.
    return ValueListenableBuilder<String>(
      valueListenable: AppPreferences.language,
      builder: (context, language, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              tooltip: AppTranslations.text('back'),
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 20,
              ),
            ),
            title: Text(
              AppTranslations.text('search_city'),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            centerTitle: true,
          ),
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                  children: [
                    Text(
                      AppTranslations.text('find_your_city'),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: const Color(0xFF1B3154),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      AppTranslations.text('search_city_description'),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF78869B),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // City search field.
                    TextField(
                      controller: _controller,
                      enabled: !_isSearching,
                      textInputAction: TextInputAction.search,
                      onSubmitted: _searchCity,
                      decoration: InputDecoration(
                        hintText: AppTranslations.text('search_city_hint'),
                        hintStyle: const TextStyle(
                          color: Color(0xFF9AA7B8),
                          fontSize: 14,
                        ),
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          color: Color(0xFF2855D9),
                        ),
                        suffixIcon: IconButton(
                          tooltip: AppTranslations.text('search'),
                          onPressed: _isSearching
                              ? null
                              : () => _searchCity(_controller.text),
                          icon: const Icon(
                            Icons.arrow_forward_rounded,
                            color: Color(0xFF2855D9),
                          ),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF5F7FB),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 17,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(17),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(17),
                          borderSide: const BorderSide(
                            color: Color(0xFFE7ECF4),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(17),
                          borderSide: const BorderSide(
                            color: Color(0xFF2855D9),
                            width: 1.4,
                          ),
                        ),
                      ),
                    ),

                    if (_isSearching) ...[
                      const SizedBox(height: 20),
                      const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ],

                    if (_errorKey != null) ...[
                      const SizedBox(height: 14),
                      Text(
                        AppTranslations.text(_errorKey!),
                        style: TextStyle(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ],

                    const SizedBox(height: 30),

                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            AppTranslations.text('popular_cities'),
                            style: const TextStyle(
                              color: Color(0xFF1B3154),
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        Text(
                          '${_popularCities.length} '
                          '${AppTranslations.text('cities')}',
                          style: const TextStyle(
                            color: Color(0xFF8794A8),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    ..._popularCities.map((city) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: Material(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(17),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(17),
                            onTap: _isSearching
                                ? null
                                : () => _searchCity(city.query),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 10,
                              ),
                              child: Row(
                                children: [
                                  _cityThumbnail(city),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          city.name,
                                          style: const TextStyle(
                                            color: Color(0xFF243957),
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          AppTranslations.text(
                                            city.countryKey,
                                          ),
                                          style: const TextStyle(
                                            color: Color(0xFF8491A5),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    Icons.chevron_right_rounded,
                                    color: Color(0xFF9AA7B8),
                                    size: 23,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}



/* 
import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  final Future<void> Function(String city) onCitySelected;

  const SearchScreen({
    super.key,
    required this.onCitySelected,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _PopularCity {
  final String name;
  final String country;
  final String query;
  final String imageUrl;

  const _PopularCity({
    required this.name,
    required this.country,
    required this.query,
    required this.imageUrl,
  });
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();

  bool _isSearching = false;
  String? _error;

  static const List<_PopularCity> _popularCities = [
    _PopularCity(
      name: 'Lahore',
      country: 'Pakistan',
      query: 'Lahore,PK',
      imageUrl:
          'https://images.unsplash.com/photo-1577083552431-6e5fd01aa342?w=160&h=160&fit=crop',
    ),
    _PopularCity(
      name: 'Karachi',
      country: 'Pakistan',
      query: 'Karachi,PK',
      imageUrl:
          'https://images.unsplash.com/photo-1519501025264-65ba15a82390?w=160&h=160&fit=crop',
    ),
    _PopularCity(
      name: 'Islamabad',
      country: 'Pakistan',
      query: 'Islamabad,PK',
      imageUrl:
          'https://images.unsplash.com/photo-1519608487953-e999c86e7455?w=160&h=160&fit=crop',
    ),
    _PopularCity(
      name: 'Peshawar',
      country: 'Pakistan',
      query: 'Peshawar,PK',
      imageUrl:
          'https://images.unsplash.com/photo-1518005020951-eccb494ad742?w=160&h=160&fit=crop',
    ),
    _PopularCity(
      name: 'London',
      country: 'United Kingdom',
      query: 'London,GB',
      imageUrl:
          'https://images.unsplash.com/photo-1513635269975-59663e0ac1ad?w=160&h=160&fit=crop',
    ),
    _PopularCity(
      name: 'Dubai',
      country: 'United Arab Emirates',
      query: 'Dubai,AE',
      imageUrl:
          'https://images.unsplash.com/photo-1512453979798-5ea266f8880c?w=160&h=160&fit=crop',
    ),
    _PopularCity(
      name: 'New York',
      country: 'United States',
      query: 'New York,US',
      imageUrl:
          'https://images.unsplash.com/photo-1496588152823-86ff7695e68f?w=160&h=160&fit=crop',
    ),
  ];

  Future<void> _searchCity(String city) async {
    final value = city.trim();

    if (value.isEmpty) {
      setState(() => _error = 'Please enter a city name.');
      return;
    }

    setState(() {
      _isSearching = true;
      _error = null;
    });

    try {
      await widget.onCitySelected(value);

      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _error = 'Unable to search this city. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() => _isSearching = false);
      }
    }
  }

  Widget _cityThumbnail(_PopularCity city) {
    return ClipOval(
      child: Image.network(
        city.imageUrl,
        width: 54,
        height: 54,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) {
          return Container(
            width: 54,
            height: 54,
            color: const Color(0xFFE7EEFA),
            alignment: Alignment.center,
            child: const Icon(
              Icons.location_city_rounded,
              color: Color(0xFF2855D9),
              size: 25,
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          tooltip: 'Back',
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
          ),
        ),
        title: const Text(
          'Search City',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              children: [
                Text(
                  'Find your city',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: const Color(0xFF1B3154),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  'Check the weather anywhere in the world.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF78869B),
                  ),
                ),
                const SizedBox(height: 24),

                // Rounded city search field.
                TextField(
                  controller: _controller,
                  enabled: !_isSearching,
                  textInputAction: TextInputAction.search,
                  onSubmitted: _searchCity,
                  decoration: InputDecoration(
                    hintText: 'Search city name...',
                    hintStyle: const TextStyle(
                      color: Color(0xFF9AA7B8),
                      fontSize: 14,
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: Color(0xFF2855D9),
                    ),
                    suffixIcon: IconButton(
                      tooltip: 'Search',
                      onPressed: _isSearching
                          ? null
                          : () => _searchCity(_controller.text),
                      icon: const Icon(
                        Icons.arrow_forward_rounded,
                        color: Color(0xFF2855D9),
                      ),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF5F7FB),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 17,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(17),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(17),
                      borderSide: const BorderSide(
                        color: Color(0xFFE7ECF4),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(17),
                      borderSide: const BorderSide(
                        color: Color(0xFF2855D9),
                        width: 1.4,
                      ),
                    ),
                  ),
                ),

                if (_isSearching) ...[
                  const SizedBox(height: 20),
                  const Center(
                    child: CircularProgressIndicator(),
                  ),
                ],

                if (_error != null) ...[
                  const SizedBox(height: 14),
                  Text(
                    _error!,
                    style: TextStyle(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ],

                const SizedBox(height: 30),

                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Popular Cities',
                        style: TextStyle(
                          color: Color(0xFF1B3154),
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Text(
                      '${_popularCities.length} cities',
                      style: const TextStyle(
                        color: Color(0xFF8794A8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                ..._popularCities.map((city) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(17),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(17),
                        onTap: _isSearching
                            ? null
                            : () => _searchCity(city.query),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 10,
                          ),
                          child: Row(
                            children: [
                              _cityThumbnail(city),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      city.name,
                                      style: const TextStyle(
                                        color: Color(0xFF243957),
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      city.country,
                                      style: const TextStyle(
                                        color: Color(0xFF8491A5),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right_rounded,
                                color: Color(0xFF9AA7B8),
                                size: 23,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
 */

/* 
import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  final Future<void> Function(String city) onCitySelected;

  const SearchScreen({
    super.key,
    required this.onCitySelected,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isSearching = false;
  String? _error;

  final List<String> _popularCities = [
    'Lahore,PK',
    'Karachi,PK',
    'Islamabad,PK',
    'Peshawar,PK',
    'London,GB',
    'Dubai,AE',
    'New York,US',
  ];

  Future<void> _searchCity(String city) async {
    final value = city.trim();

    if (value.isEmpty) {
      setState(() => _error = 'Please enter a city name.');
      return;
    }

    setState(() {
      _isSearching = true;
      _error = null;
    });

    try {
      await widget.onCitySelected(value);

      if (!mounted) return;
      Navigator.pop(context);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Unable to search this city. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() => _isSearching = false);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search city'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Find your weather',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Search for a city to check its current weather.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _controller,
              autofocus: true,
              textInputAction: TextInputAction.search,
              onSubmitted: _isSearching
                  ? null
                  : _searchCity,
              decoration: InputDecoration(
                hintText: 'Enter city, e.g. Karachi',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: IconButton(
                  tooltip: 'Search',
                  onPressed: _isSearching
                      ? null
                      : () => _searchCity(_controller.text),
                  icon: const Icon(Icons.arrow_forward_rounded),
                ),
              ),
            ),
            if (_isSearching) ...[
              const SizedBox(height: 20),
              const Center(child: CircularProgressIndicator()),
            ],
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ],
            const SizedBox(height: 28),
            Text(
              'Popular cities',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ..._popularCities.map((city) {
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  Icons.location_on_outlined,
                  color: theme.colorScheme.primary,
                ),
                title: Text(city.split(',').first),
                subtitle: Text(city),
                trailing: const Icon(Icons.chevron_right_rounded),
                enabled: !_isSearching,
                onTap: () => _searchCity(city),
              );
            }),
          ],
        ),
      ),
    );
  }
}
 */