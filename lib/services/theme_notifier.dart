import 'package:autistock/services/data_service.dart';
import 'package:flutter/material.dart';

class ThemeNotifier extends ChangeNotifier {
  final DataService dataService;
  bool _isDarkMode;
  double _textScaleFactor;

  ThemeNotifier(this.dataService)
      : _isDarkMode = false,
        _textScaleFactor = 1.0 {
    _loadFromPrefs();
  }

  bool get isDarkMode => _isDarkMode;
  double get textScaleFactor => _textScaleFactor;

  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  final ThemeData _lightTheme = ThemeData.light().copyWith(
    primaryColor: Colors.blue,
  );

  final ThemeData _darkTheme = ThemeData.dark().copyWith(
    primaryColor: Colors.blueGrey,
  );

  ThemeData get lightTheme => _lightTheme;
  ThemeData get darkTheme => _darkTheme;

  void _loadFromPrefs() async {
    _isDarkMode = await dataService.loadTheme();
    _textScaleFactor = await dataService.loadTextScaleFactor();
    notifyListeners();
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    dataService.saveTheme(_isDarkMode);
    notifyListeners();
  }

  void setTextScaleFactor(double scaleFactor) {
    _textScaleFactor = scaleFactor;
    dataService.saveTextScaleFactor(_textScaleFactor);
    notifyListeners();
  }
}
