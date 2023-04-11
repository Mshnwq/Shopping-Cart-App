import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ThemeController with ChangeNotifier {
  bool isDark = false;

  void changeTheme() {
    isDark = !isDark;
    notifyListeners();
  }
}

final themeModeProvider = StateProvider<ThemeMode>(
  (ref) {
    return ThemeMode.dark;
  },
);
