import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _currentLocale = const Locale('fr', 'FR');
  Locale get currentLocale => _currentLocale;

  int get currentLanguageIndex {
    switch (_currentLocale.languageCode) {
      case 'fr':
        return 0;
      case 'ar':
        return 1;
      case 'en':
        return 2;
      default:
        return 0;
    }
  }

  LanguageProvider() {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    _setLocale(prefs.getString('language_code') ?? 'fr');
    notifyListeners();
  }

  Future<void> setLanguage(int index) async {
    final codes = ['fr', 'ar', 'en'];
    final code = index < codes.length ? codes[index] : 'fr';
    _setLocale(code);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', code);
    notifyListeners();
  }

  void _setLocale(String code) {
    switch (code) {
      case 'fr':
        _currentLocale = const Locale('fr', 'FR');
        break;
      case 'ar':
        _currentLocale = const Locale('ar', 'TN');
        break;
      case 'en':
        _currentLocale = const Locale('en', 'US');
        break;
    }
  }
}
