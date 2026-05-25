import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier{
  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  // func to switch UI theme from toggle button
  void setThemeMode(ThemeMode mode){
    _themeMode = mode;
    notifyListeners();
  }
}