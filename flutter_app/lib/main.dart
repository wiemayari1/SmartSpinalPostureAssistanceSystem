import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'providers/posture_provider.dart';
import 'providers/chatbot_provider.dart';
import 'providers/language_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/splash_screen.dart';
import 'utils/app_localizations.dart';
import 'utils/app_colors.dart';

void main() {
  runApp(const SpineGuardApp());
}

// ─── ThemeData sombre ─────────────────────────────────────────
ThemeData _darkTheme() => ThemeData(
      brightness: Brightness.dark,
      primaryColor: AppColors.dark.primary,
      scaffoldBackgroundColor: AppColors.dark.scaffold,
      colorScheme: ColorScheme.dark(
        primary:   AppColors.dark.primary,
        secondary: AppColors.dark.primaryDark,
        surface:   AppColors.dark.card,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
      ),
      extensions: const [AppColors.dark],
    );

// ─── ThemeData clair ──────────────────────────────────────────
ThemeData _lightTheme() => ThemeData(
      brightness: Brightness.light,
      primaryColor: AppColors.light.primary,
      scaffoldBackgroundColor: AppColors.light.scaffold,
      colorScheme: ColorScheme.light(
        primary:   AppColors.light.primary,
        secondary: AppColors.light.primaryDark,
        surface:   AppColors.light.card,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.light.textPrimary),
        titleTextStyle: TextStyle(
          color: AppColors.light.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      extensions: const [AppColors.light],
    );

class SpineGuardApp extends StatelessWidget {
  const SpineGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => PostureProvider()),
        ChangeNotifierProvider(create: (_) => ChatbotProvider()),
      ],
      child: Consumer2<LanguageProvider, ThemeProvider>(
        builder: (context, langProvider, themeProvider, _) {
          return MaterialApp(
            title: 'SpineGuard',
            debugShowCheckedModeBanner: false,
            themeMode: themeProvider.themeMode,
            theme:     _lightTheme(),
            darkTheme: _darkTheme(),
            locale: langProvider.currentLocale,
            supportedLocales: const [
              Locale('fr', 'FR'),
              Locale('ar', 'TN'),
              Locale('en', 'US'),
            ],
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
