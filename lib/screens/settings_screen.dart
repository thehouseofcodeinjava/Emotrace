// Screen: SettingsScreen | Author: Piyush Puri | Date: 13 Apr 2026
// Sanctuary redesign: Piyush Puri | Date: 15 Apr 2026
// Editorial sections, custom animated toggle, serif section titles

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
          provider.entries, provider.currentStreak, provider.longestStreak);
      await Printing.sharePdf(bytes: bytes, filename: 'emotrace_history.pdf');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e'),
              backgroundColor: AppTheme.errorContainer),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Consumer<SettingsProvider>(
          builder: (context, settings, _) {
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
              children: [
                // Editorial header
                Text('Settings', style: AppTheme.displaySerif.copyWith(fontSize: 40)),
                Text('Curate your experience',
                    style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary)),
                const SizedBox(height: 32),

                // Appearance
                const _SectionTitle(title: 'Appearance'),
                const SizedBox(height: 12),
                const _SectionCard(children: [
                  _SettingsTile(
                    icon: Icons.dark_mode_rounded,
                    title: 'Dark Mode',
                    subtitle: 'Only dark theme in this version',
                    trailing: _SanctuaryToggle(value: true, onChanged: null),
                  ),
                ]),
                const SizedBox(height: 24),

                // Notifications
                const _SectionTitle(title: 'Notifications'),
                const SizedBox(height: 12),
                _SectionCard(children: [
                  _SettingsTile(
                    icon: Icons.notifications_none_rounded,
                    title: 'Daily Reminder',
                    subtitle: 'Get a nudge to log your mood every day',
                    trailing: _SanctuaryToggle(
                      value: settings.dailyReminderEnabled,
                      onChanged: (v) => settings.toggleReminder(v),
                    ),
                  ),
                  if (settings.dailyReminderEnabled) ...[
                    _Divider(),
                    _SettingsTile(
                      icon: Icons.access_time_rounded,
                      title: 'Reminder Time',
                      subtitle: _formatTime(settings.reminderTime),
                      trailing: const Icon(Icons.chevron_right,
                          color: AppTheme.textSecondary, size: 18),
                      onTap: () => _pickReminderTime(context, settings),
                    ),
                  ],
                ]),
                const SizedBox(height: 24),

                // Data & Privacy
                const _SectionTitle(title: 'Data & Privacy'),
                const SizedBox(height: 12),
                _SectionCard(children: [
                  _SettingsTile(
                    icon: Icons.download_rounded,
                    title: 'Export Mood History',
                    subtitle: 'Share all entries as a PDF report',
                    trailing: _isExporting
                        ? const SizedBox(
                            width: 20, height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: AppTheme.primary))
                        : const Icon(Icons.chevron_right,
                            color: AppTheme.textSecondary, size: 18),
                    onTap: _isExporting ? null : () => _exportHistoryPdf(context),
                  ),
                  _Divider(),
                  _SettingsTile(
                    icon: Icons.delete_outline_rounded,
                    title: 'Clear All Data',
                    subtitle: 'Permanently delete all mood entries',
                    titleColor: AppTheme.red,
                    trailing: const Icon(Icons.chevron_right,
                        color: AppTheme.textSecondary, size: 18),
                    onTap: () => _confirmClearData(context),
                  ),
                ]),
                const SizedBox(height: 24),

                // About
                const _SectionTitle(title: 'About'),
                const SizedBox(height: 12),
                _SectionCard(children: [
                  const _SettingsTile(
                    icon: Icons.info_outline_rounded,
                    title: AppConstants.appName,
                    subtitle: 'Version 1.0.0 — MVP',
                  ),
                  _Divider(),
                  const _SettingsTile(
                    icon: Icons.people_outline_rounded,
                    title: 'Built by',
                    subtitle: 'Rajat Mahajan & Piyush Puri',
                  ),
                ]),
                const SizedBox(height: 40),

                // Footer
                Center(
                  child: Text(
                    'Built by EMOTRACE',
                    style: AppTheme.headlineSerifItalic.copyWith(
                        fontSize: 16, color: AppTheme.primary),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _formatTime(String time) {
    final parts = time.split(':');
    final hour = int.parse(parts[0]);
    final minute = parts[1];
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }

  Future<void> _pickReminderTime(BuildContext context, SettingsProvider settings) async {
    final parts = settings.reminderTime.split(':');
    final initial = TimeOfDay(
        hour: int.parse(parts[0]), minute: int.parse(parts[1]));

    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          timePickerTheme: const TimePickerThemeData(
            backgroundColor: AppTheme.surfaceContainerLow,
            hourMinuteColor: AppTheme.surfaceContainerHighest,
            hourMinuteTextColor: AppTheme.textPrimary,
            dialBackgroundColor: AppTheme.surfaceContainerHighest,
            dialHandColor: AppTheme.primary,
            dialTextColor: AppTheme.textPrimary,
            entryModeIconColor: AppTheme.primary,
          ),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      settings.updateReminderTime(
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}');
    }
  }

  Future<void> _confirmClearData(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceContainerLow,
        title: Text('Clear All Data?',
            style: AppTheme.headlineSerifMedium),
        content: Text(
            'This will permanently delete all your mood entries and cannot be undone.',
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Cancel', style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('Delete Everything',
                style: AppTheme.bodyMedium.copyWith(color: AppTheme.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      // TODO: call DatabaseService.clearAllEntries() — Week 5 | Author: Piyush Puri
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data cleared (coming in Week 5)'),
          backgroundColor: AppTheme.surfaceContainerHigh,
        ),
      );
    }
  }
}

// ─── Section title ────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) => Text(
        title,
        style: AppTheme.headlineSerifMedium.copyWith(
            fontSize: 22, color: AppTheme.primary),
      );
}

// ─── Section card ─────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final List<Widget> children;
  const _SectionCard({required this.children});

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.outlineVariant.withValues(alpha: 0.4)),
        ),
        child: Column(children: children),
      );
}

// ─── Settings tile ────────────────────────────────────────────────────────────

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? titleColor;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) => ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: AppTheme.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppTheme.primary, size: 20),
        ),
        title: Text(title,
            style: AppTheme.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: titleColor ?? AppTheme.textPrimary)),
        subtitle: Text(subtitle, style: AppTheme.bodySmall),
        trailing: trailing,
      );
}

// ─── Custom Sanctuary toggle ──────────────────────────────────────────────────

class _SanctuaryToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  const _SanctuaryToggle({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onChanged != null ? () => onChanged!(!value) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 48,
        height: 26,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(13),
          gradient: value
              ? const LinearGradient(
                  colors: [Color(0xFFe9c176), Color(0xFFc5a059)])
              : null,
          color: value ? null : AppTheme.surfaceContainerHighest,
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              left: value ? 24 : 2,
              top: 2,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: value ? AppTheme.onPrimary : AppTheme.outline,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Divider ──────────────────────────────────────────────────────────────────

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => const Divider(
        height: 1, thickness: 0.5,
        indent: 56, endIndent: 16,
        color: AppTheme.outlineVariant,
      );
}
