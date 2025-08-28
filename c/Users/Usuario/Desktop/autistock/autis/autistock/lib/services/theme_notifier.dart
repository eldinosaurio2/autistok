import 'package:autistock/services/data_service.dart';
import 'package:flutter/material.dart';

class ThemeNotifier extends ChangeNotifier {
  final DataService _dataService;
  ThemeMode _themeMode = ThemeMode.system;
  double _textScaleFactor = 1.0;

  ThemeNotifier(this._dataService) {
    loadThemeMode();
    _loadTextScaleFactor();
  }

  ThemeMode get themeMode => _themeMode;
  double get textScaleFactor => _textScaleFactor;

  Future<void> loadThemeMode() async {
    final isDarkMode = await _dataService.loadThemeMode();
    _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  Future<void> _loadTextScaleFactor() async {
    _textScaleFactor = await _dataService.loadTextScaleFactor();
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    _dataService.saveThemeMode(mode == ThemeMode.dark);
    notifyListeners();
  }

  void setTextScaleFactor(double scaleFactor) {
    _textScaleFactor = scaleFactor;
    _dataService.saveTextScaleFactor(scaleFactor);
    notifyListeners();
  }
}
