// Screen: SettingsScreen | Author: Piyush Puri | Date: 13 Apr 2026
// Full UI implementation — Appearance, Notifications, Data, About sections
// Replaces Rajat Mahajan's shell (11 Apr 2026)

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

import '../config/constants.dart';
import '../config/theme.dart';
import '../providers/mood_provider.dart';
import '../providers/settings_provider.dart';
import '../services/pdf_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isExporting = false;

  Future<void> _exportHistoryPdf(BuildContext context) async {
    if (_isExporting) return;
    setState(() => _isExporting = true);
    try {
      final provider = context.read<MoodProvider>();
      final bytes = await PdfService.buildHistoryPdf(
        provider.entries,
        provider.currentStreak,
        provider.longestStreak,
      );
      await Printing.sharePdf(bytes: bytes, filename: 'emotrace_history.pdf');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: AppTheme.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            children: [
              _SectionCard(
                label: 'APPEARANCE',
                children: [
                  _SettingsTile(
                    icon: Icons.dark_mode_rounded,
                    iconColor: AppTheme.teal,
                    title: 'Dark Mode',
                    subtitle: 'Only dark theme available in this version',
                    trailing: Switch(
                      value: true,
                      onChanged: null, // locked — MVP dark-only
                      activeThumbColor: AppTheme.teal,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _SectionCard(
                label: 'NOTIFICATIONS',
                children: [
                  _SettingsTile(
                    icon: Icons.notifications_rounded,
                    iconColor: AppTheme.orange,
                    title: 'Daily Reminder',
                    subtitle: 'Get a nudge to log your mood every day',
                    trailing: Switch(
                      value: settings.dailyReminderEnabled,
                      onChanged: settings.toggleReminder,
                      activeThumbColor: AppTheme.teal,
                    ),
                  ),
                  if (settings.dailyReminderEnabled) ...[
                    const _Divider(),
                    _ReminderTimeTile(
                      reminderTime: settings.reminderTime,
                      onTap: () => _pickReminderTime(context, settings),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              _SectionCard(
                label: 'DATA',
                children: [
                  _SettingsTile(
                    icon: Icons.download_rounded,
                    iconColor: AppTheme.teal,
                    title: 'Export Mood History',
                    subtitle: 'Share all your mood entries as a PDF report',
                    trailing: _isExporting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppTheme.teal,
                            ),
                          )
                        : const Icon(
                            Icons.chevron_right_rounded,
                            color: AppTheme.textSecondary,
                          ),
                    onTap: _isExporting
                        ? null
                        : () => _exportHistoryPdf(context),
                  ),
                  const _Divider(),
                  _SettingsTile(
                    icon: Icons.delete_outline_rounded,
                    iconColor: AppTheme.red,
                    title: 'Clear All Data',
                    subtitle: 'Permanently delete all mood entries',
                    trailing: const Icon(
                      Icons.chevron_right_rounded,
                      color: AppTheme.textSecondary,
                    ),
                    onTap: () => _confirmClearData(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _SectionCard(
                label: 'ABOUT',
                children: [
                  _SettingsTile(
                    icon: Icons.info_outline_rounded,
                    iconColor: AppTheme.teal,
                    title: AppConstants.appName,
                    subtitle: 'Version 1.0.0 — MVP',
                  ),
                  const _Divider(),
                  _SettingsTile(
                    icon: Icons.people_outline_rounded,
                    iconColor: AppTheme.textSecondary,
                    title: 'Built by',
                    subtitle: 'Rajat Mahajan & Piyush Puri',
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }

  Future<void> _pickReminderTime(
    BuildContext context,
    SettingsProvider settings,
  ) async {
    final parts = settings.reminderTime.split(':');
    final initial = TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );

    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: AppTheme.cardBackground,
              hourMinuteColor: AppTheme.surfaceContainer,
              hourMinuteTextColor: AppTheme.textPrimary,
              dayPeriodColor: AppTheme.surfaceContainer,
              dayPeriodTextColor: AppTheme.textSecondary,
              dialBackgroundColor: AppTheme.surfaceContainer,
              dialHandColor: AppTheme.teal,
              dialTextColor: AppTheme.textPrimary,
              entryModeIconColor: AppTheme.teal,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final formatted =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      settings.updateReminderTime(formatted);
    }
  }

  Future<void> _confirmClearData(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardBackground,
        title: const Text(
          'Clear All Data?',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: const Text(
          'This will permanently delete all your mood entries and cannot be undone.',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              'Delete Everything',
              style: TextStyle(color: AppTheme.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      // TODO: call DatabaseService.clearAllEntries() — Week 5 | Author: Piyush Puri
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data cleared (coming in Week 5)'),
          backgroundColor: AppTheme.cardHigh,
        ),
      );
    }
  }

}

// ─── Section card wrapper ────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String label;
  final List<Widget> children;

  const _SectionCard({required this.label, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: const TextStyle(
              color: AppTheme.teal,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.cardBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.outlineVariant, width: 0.5),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

// ─── Generic settings tile ───────────────────────────────────────────────────

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: iconColor.withAlpha(30),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: AppTheme.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
      ),
      trailing: trailing,
    );
  }
}

// ─── Reminder time tile ──────────────────────────────────────────────────────

class _ReminderTimeTile extends StatelessWidget {
  final String reminderTime;
  final VoidCallback onTap;

  const _ReminderTimeTile({
    required this.reminderTime,
    required this.onTap,
  });

  String _formatTime(String time) {
    final parts = time.split(':');
    final hour = int.parse(parts[0]);
    final minute = parts[1];
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return _SettingsTile(
      icon: Icons.access_time_rounded,
      iconColor: AppTheme.teal,
      title: 'Reminder Time',
      subtitle: _formatTime(reminderTime),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: AppTheme.textSecondary,
      ),
      onTap: onTap,
    );
  }
}

// ─── Divider ─────────────────────────────────────────────────────────────────

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      thickness: 0.5,
      indent: 56,
      endIndent: 16,
      color: AppTheme.outlineVariant,
    );
  }
}
