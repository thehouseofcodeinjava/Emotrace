import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'accent_theme.dart';

class ThemeProvider extends ChangeNotifier {
  static const _prefsKey = 'accent_theme';

  AccentTheme _current = AccentTheme.gold;
  AccentTheme get current => _current;
  AccentColors get colors => AccentColors.fromEnum(_current);

  ThemeProvider() { _load(); }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefsKey);
    if (saved != null) {
      _current = AccentTheme.values.firstWhere(
        (t) => t.name == saved,
        orElse: () => AccentTheme.gold,
      );
      notifyListeners();
    }
  }

  Future<void> setTheme(AccentTheme t) async {
    if (_current == t) return;
    _current = t;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, t.name);
  }
}
