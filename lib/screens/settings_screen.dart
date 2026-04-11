// Screen: SettingsScreen | Author: Rajat Mahajan | Date: 11 Apr 2026
// TODO: settings — theme, notifications, data management | Author: Rajat Mahajan

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/settings_provider.dart';
import '../config/theme.dart';
import '../config/constants.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, _) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // TODO: Replace with full Settings UI (Week 5)
                const Text(
                  'Settings Screen',
                  style: TextStyle(color: AppTheme.textPrimary, fontSize: 22),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text(
                    'Daily Reminder',
                    style: TextStyle(color: AppTheme.textPrimary),
                  ),
                  subtitle: Text(
                    settingsProvider.reminderTime,
                    style: const TextStyle(color: AppTheme.textSecondary),
                  ),
                  value: settingsProvider.dailyReminderEnabled,
                  onChanged: settingsProvider.toggleReminder,
                  activeColor: AppTheme.teal,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
