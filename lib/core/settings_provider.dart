import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  Locale _currentLocale = const Locale('en');
  ThemeMode _currentThemeMode = ThemeMode.light;

  SettingsProvider() {
    _loadSettings();
  }

  Locale get currentLocale => _currentLocale;
  ThemeMode get currentThemeMode => _currentThemeMode;

  bool get isArabic => _currentLocale.languageCode == 'ar';
  bool get isDarkMode => _currentThemeMode == ThemeMode.dark;

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load language
    String? lang = prefs.getString('language');
    if (lang != null) {
      _currentLocale = Locale(lang);
    }

    // Load theme
    String? theme = prefs.getString('theme');
    if (theme == 'dark') {
      _currentThemeMode = ThemeMode.dark;
    } else {
      _currentThemeMode = ThemeMode.light;
    }
    
    notifyListeners();
  }

  Future<void> changeLanguage(String langCode) async {
    _currentLocale = Locale(langCode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', langCode);
    notifyListeners();
  }

  Future<void> changeTheme(ThemeMode themeMode) async {
    _currentThemeMode = themeMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme', themeMode == ThemeMode.dark ? 'dark' : 'light');
    notifyListeners();
  }
}
