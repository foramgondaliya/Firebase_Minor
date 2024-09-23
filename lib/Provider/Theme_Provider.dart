import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  bool isDarkTheme = false;

  void changetheme() {
    isDarkTheme = !isDarkTheme;
    notifyListeners();
  }
}
