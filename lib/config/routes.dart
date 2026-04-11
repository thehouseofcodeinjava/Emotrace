// Config: AppRoutes | Author: Rajat Mahajan | Date: 11 Apr 2026
// NOTE: Recreated by Piyush Puri (11 Apr 2026) — original was missing from Rajat's commit.

import 'package:flutter/material.dart';

import '../screens/home_screen.dart';
import '../screens/mood_entry_screen.dart';
import '../screens/calendar_screen.dart';
import '../screens/insights_screen.dart';
import '../screens/settings_screen.dart';

class AppRoutes {
  static const String home       = '/';
  static const String moodEntry  = '/mood-entry';
  static const String calendar   = '/calendar';
  static const String insights   = '/insights';
  static const String settings   = '/settings';

  static Map<String, WidgetBuilder> get routes => {
    home:      (_) => const HomeScreen(),
    moodEntry: (_) => const MoodEntryScreen(),
    calendar:  (_) => const CalendarScreen(),
    insights:  (_) => const InsightsScreen(),
    settings:  (_) => const SettingsScreen(),
  };
}
