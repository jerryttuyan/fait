import 'package:flutter/material.dart';

enum Units { metric, imperial }

enum AppThemeMode { system, light, dark }

class AppSettings extends ChangeNotifier {
  Units _units = Units.metric;
  AppThemeMode _themeMode = AppThemeMode.system;

  Units get units => _units;
  AppThemeMode get themeMode => _themeMode;

  void setUnits(Units value) {
    if (_units != value) {
      _units = value;
      notifyListeners();
    }
  }

  void setThemeMode(AppThemeMode value) {
    if (_themeMode != value) {
      _themeMode = value;
      notifyListeners();
    }
  }
}
