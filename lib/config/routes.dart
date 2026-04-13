// Config: AppRoutes | Author: Rajat Mahajan | Date: 11 Apr 2026
// Updated: Piyush Puri | Date: 13 Apr 2026
// Note: '/' intentionally excluded from routes map —
//       handled by MaterialApp(home: MainNavigation()).

import 'package:flutter/material.dart';

import '../screens/mood_entry_screen.dart';

class AppRoutes {
  static const String home      = '/';
  static const String moodEntry = '/mood-entry';
  static const String calendar  = '/calendar';
  static const String insights  = '/insights';
  static const String settings  = '/settings';

  /// Named routes registered with MaterialApp.routes.
  /// Only push-navigated screens go here.
  /// Bottom-nav screens (Calendar, Insights, Settings) are handled by
  /// MainNavigation and don't need named routes.
  static Map<String, WidgetBuilder> get routes => {
    moodEntry: (_) => const MoodEntryScreen(),
  };
}
