// TODO: settings provider | Author: Rajat Mahajan
// Provider: SettingsProvider — theme, notifications, reminder time

import 'package:flutter/foundation.dart';

import '../models/settings_model.dart';

class SettingsProvider extends ChangeNotifier {
  // Temporary placeholder until auth is implemented in Month 2
  static const String _tempUserId = 'local_user_01';

  Settings _settings = Settings.defaults(_tempUserId);

  Settings get settings => _settings;
  String get theme => _settings.theme;
  bool get dailyReminderEnabled => _settings.dailyReminderEnabled;
  String get reminderTime => _settings.reminderTime;

  void updateTheme(String theme) {
    _settings = _settings.copyWith(theme: theme);
    notifyListeners();
    // TODO: persist to database
  }

  void toggleReminder(bool enabled) {
    _settings = _settings.copyWith(dailyReminderEnabled: enabled);
    notifyListeners();
    // TODO: persist to database + schedule/cancel notification
  }

  void updateReminderTime(String time) {
    _settings = _settings.copyWith(reminderTime: time);
    notifyListeners();
    // TODO: persist to database + reschedule notification
  }
}
