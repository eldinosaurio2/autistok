import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.blue,
    colorScheme: const ColorScheme.light(
      primary: Colors.blue,
      secondary: Colors.blueAccent,
      surface: Colors.white,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.black,
    ),
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
      elevation: 0,
      titleTextStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    ),
    textTheme: const TextTheme(
      headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
      titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      bodyLarge: TextStyle(fontSize: 18),
      bodyMedium: TextStyle(fontSize: 16),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(Colors.blue),
        foregroundColor: WidgetStateProperty.all(Colors.white),
        minimumSize: WidgetStateProperty.all(const Size(200, 56)),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        textStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    ),
    iconTheme: const IconThemeData(size: 36, color: Colors.blue),
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.blueGrey,
    colorScheme: const ColorScheme.dark(
      primary: Color.fromARGB(255, 38, 183, 255),
      secondary: Colors.blueAccent,
      surface: Color(0xFF121212),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.white,
    ),
    scaffoldBackgroundColor: const Color(0xFF121212),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color.fromARGB(255, 64, 191, 255),
      foregroundColor: Colors.white,
      elevation: 0,
      titleTextStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    ),
    textTheme: const TextTheme(
      headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
      titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      bodyLarge: TextStyle(fontSize: 18),
      bodyMedium: TextStyle(fontSize: 16),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor:
            WidgetStateProperty.all(const Color.fromARGB(255, 86, 199, 255)),
        foregroundColor: WidgetStateProperty.all(Colors.white),
        minimumSize: WidgetStateProperty.all(const Size(200, 56)),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        textStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF232323),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    ),
    iconTheme: const IconThemeData(size: 36, color: Colors.blueAccent),
  );
}

class ThemeNotifier extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  double _textScaleFactor = 1.0;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  double get textScaleFactor => _textScaleFactor;

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  void toggleTheme() {
    _themeMode = isDarkMode ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }

  void setTextScaleFactor(double factor) {
    _textScaleFactor = factor;
    notifyListeners();
  }
}
