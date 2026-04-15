// Provider: SettingsProvider | Author: Rajat Mahajan | Date: 11 Apr 2026
// Persistence + notification wiring: Piyush Puri | Date: 13 Apr 2026
// Keeps void mutator signatures so Switch.onChanged stays compatible.

import 'package:flutter/foundation.dart';

import '../models/settings_model.dart';
import '../services/notification_service.dart';
import '../services/settings_service.dart';

class SettingsProvider extends ChangeNotifier {
  static const String _tempUserId = 'local_user_01';

  final SettingsService _settingsService = SettingsService();

  Settings _settings = Settings.defaults(_tempUserId);

  Settings get settings => _settings;
  String get theme => _settings.theme;
  bool get dailyReminderEnabled => _settings.dailyReminderEnabled;
  String get reminderTime => _settings.reminderTime;

  /// Called once from main.dart after DatabaseService.init().
  /// Falls back to Settings.defaults() silently on any error.
  Future<void> loadSettings() async {
    try {
      final saved = await _settingsService.loadSettings(_tempUserId);
      if (saved != null) {
        _settings = saved;
        notifyListeners();
      }
      // Schedule notification on app start if reminder is enabled.
      if (_settings.dailyReminderEnabled) {
        await NotificationService().scheduleDailyReminder(_settings.reminderTime);
      }
    } catch (_) {
      // defaults already set — never crash on settings load
    }
  }

  void updateTheme(String theme) {
    _settings = _settings.copyWith(theme: theme);
    notifyListeners();
    _saveQuietly();
  }

  void toggleReminder(bool enabled) {
    _settings = _settings.copyWith(dailyReminderEnabled: enabled);
    notifyListeners();
    _saveQuietly().then((_) {
      if (enabled) {
        NotificationService().scheduleDailyReminder(_settings.reminderTime);
      } else {
        NotificationService().cancelDailyReminder();
      }
    });
  }

  void updateReminderTime(String time) {
    _settings = _settings.copyWith(reminderTime: time);
    notifyListeners();
    _saveQuietly().then((_) {
      if (_settings.dailyReminderEnabled) {
        NotificationService().scheduleDailyReminder(time);
      }
    });
  }

  Future<void> _saveQuietly() async {
    try {
      await _settingsService.saveSettings(_settings);
    } catch (_) {
      // state is already updated in memory — DB failure must not block UX
    }
  }
}
