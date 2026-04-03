import 'package:flutter/material.dart';

class SettingsProvider extends ChangeNotifier {
  Locale _currentLocale = const Locale('en');
  ThemeMode _currentThemeMode = ThemeMode.light;

  Locale get currentLocale => _currentLocale;
  ThemeMode get currentThemeMode => _currentThemeMode;

  bool get isArabic => _currentLocale.languageCode == 'ar';
  bool get isDarkMode => _currentThemeMode == ThemeMode.dark;

  void changeLanguage(String langCode) {
    _currentLocale = Locale(langCode);
    notifyListeners();
  }

  void changeTheme(ThemeMode themeMode) {
    _currentThemeMode = themeMode;
    notifyListeners();
  }
}
