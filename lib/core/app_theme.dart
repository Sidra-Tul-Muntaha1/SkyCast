
import 'package:flutter/material.dart';
import 'app_constants.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppConstants.primaryBlue,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppConstants.primaryBlue,
      secondary: AppConstants.lavender,
      surface: Colors.white,
    );

    return _buildTheme(
      scheme: scheme,
      background: AppConstants.lightBackground,
      cardColor: Colors.white,
      brightness: Brightness.light,
    );
  }

  static ThemeData get darkTheme {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppConstants.primaryBlue,
      brightness: Brightness.dark,
    ).copyWith(
      primary: const Color(0xFF83A5FF),
      secondary: const Color(0xFFB3A5FF),
      surface: AppConstants.darkSurface,
    );

    return _buildTheme(
      scheme: scheme,
      background: AppConstants.darkBackground,
      cardColor: AppConstants.darkSurface,
      brightness: Brightness.dark,
    );
  }

  static ThemeData _buildTheme({
    required ColorScheme scheme,
    required Color background,
    required Color cardColor,
    required Brightness brightness,
  }) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      brightness: brightness,
      scaffoldBackgroundColor: background,
      fontFamily: 'Roboto',
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            AppConstants.cardRadius,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          minimumSize: const Size(0, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: scheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: scheme.primary,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}
