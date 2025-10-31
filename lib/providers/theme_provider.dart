import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'is_dark_mode';
  bool _isDark = false;

  bool get isDark => _isDark;
  ThemeData get theme => _isDark ? _darkTheme : _lightTheme;

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDark = prefs.getBool(_themeKey) ?? false;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDark = !_isDark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, _isDark);
    notifyListeners();
  }

  static final _lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: const Color(0xFF2196F3),
    scaffoldBackgroundColor: const Color(0xFFF5F5F5),
    cardColor: Colors.white,
    dividerColor: const Color(0xFFE0E0E0),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Color(0xFF333333)),
      bodyMedium: TextStyle(color: Color(0xFF666666)),
      titleLarge: TextStyle(
        color: Color(0xFF1976D2),
        fontWeight: FontWeight.w700,
      ),
      titleMedium: TextStyle(
        color: Color(0xFF333333),
        fontWeight: FontWeight.w600,
      ),
    ),
  );

  static final _darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: const Color.fromARGB(255, 43, 92, 133),
    scaffoldBackgroundColor: const Color.fromARGB(255, 53, 50, 54),
    cardColor: const Color(0xFF1E1E1E),
    dividerColor: const Color(0xFF333333),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Color(0xFFB0B0B0)),
      titleLarge: TextStyle(
        color: Color(0xFF2196F3),
        fontWeight: FontWeight.w700,
      ),
      titleMedium: TextStyle(
        color: Colors.white70,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}
