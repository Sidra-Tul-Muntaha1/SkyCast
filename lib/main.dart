
import 'package:Sky_Cast/core/app_preferences.dart';
import 'package:flutter/material.dart';
import 'core/app_constants.dart';
import 'core/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (FlutterErrorDetails details) {
  FlutterError.presentError(details);
  debugPrint('SKYCAST FLUTTER ERROR: ${details.exception}');
  debugPrintStack(stackTrace: details.stack);
};

  await AppPreferences.load();

  runApp(const SkyCastApp());
}

class SkyCastApp extends StatelessWidget {
  const SkyCastApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: SkyCastAppState.themeMode,
      builder: (context, themeMode, _) {
        return MaterialApp(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
          home: const SplashScreen(),
        );
      },
    );
  }
}
