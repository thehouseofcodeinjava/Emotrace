// Screen: SettingsScreen | Author: Piyush Puri | Date: 13 Apr 2026
// Sanctuary redesign + S3 overhaul: accent selector, functional delete, no dark mode toggle

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/constants.dart';
import '../config/theme.dart';
import '../providers/mood_provider.dart';
import '../providers/settings_provider.dart';
import '../services/pdf_service.dart';
import '../theme/accent_theme.dart';
import '../theme/theme_provider.dart';

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
    final colors = context.watch<ThemeProvider>().colors;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Consumer<SettingsProvider>(
          builder: (context, settings, _) {
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
              children: [
                Text('Settings', style: AppTheme.displaySerif.copyWith(fontSize: 40)),
                Text('Curate your experience',
                    style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary)),
                const SizedBox(height: 32),

                // ── Appearance: Accent Theme ──
                _SectionTitle(title: 'Appearance', color: colors.accent),
                const SizedBox(height: 12),
                _SectionCard(borderColor: colors.line, children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: _AccentThemeSelector(),
                  ),
                ]),
                const SizedBox(height: 24),

                // ── Notifications ──
                _SectionTitle(title: 'Notifications', color: colors.accent),
                const SizedBox(height: 12),
                _SectionCard(borderColor: colors.line, children: [
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
                    _Divider(color: colors.line),
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

                // ── Data & Privacy ──
                _SectionTitle(title: 'Data & Privacy', color: colors.accent),
                const SizedBox(height: 12),
                _SectionCard(borderColor: colors.line, children: [
                  _SettingsTile(
                    icon: Icons.download_rounded,
                    title: 'Export Mood History',
                    subtitle: 'Share all entries as a PDF report',
                    trailing: _isExporting
                        ? SizedBox(
                            width: 20, height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: colors.accent))
                        : const Icon(Icons.chevron_right,
                            color: AppTheme.textSecondary, size: 18),
                    onTap: _isExporting ? null : () => _exportHistoryPdf(context),
                  ),
                  _Divider(color: colors.line),
                  _SettingsTile(
                    icon: Icons.delete_outline_rounded,
                    title: 'Delete Data',
                    subtitle: 'Remove mood entries or reset everything',
                    titleColor: AppTheme.red,
                    trailing: const Icon(Icons.chevron_right,
                        color: AppTheme.textSecondary, size: 18),
                    onTap: () => _showDeleteOptions(context),
                  ),
                ]),
                const SizedBox(height: 24),

                // ── About ──
                _SectionTitle(title: 'About', color: colors.accent),
                const SizedBox(height: 12),
                _SectionCard(borderColor: colors.line, children: [
                  const _SettingsTile(
                    icon: Icons.info_outline_rounded,
                    title: AppConstants.appName,
                    subtitle: 'Version 1.0.0 — MVP',
                  ),
                  _Divider(color: colors.line),
                  const _SettingsTile(
                    icon: Icons.people_outline_rounded,
                    title: 'Built by',
                    subtitle: 'Rajat Mahajan & Piyush Puri',
                  ),
                ]),
                const SizedBox(height: 40),
                Center(
                  child: Text(
                    'Built by EMOTRACE',
                    style: AppTheme.headlineSerifItalic.copyWith(
                        fontSize: 16, color: colors.accent),
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

  // ── Delete Data — 3-option bottom sheet ──

  void _showDeleteOptions(BuildContext context) {
    final colors = context.read<ThemeProvider>().colors;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.outlineVariant,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Delete Data', style: AppTheme.headlineSerifMedium),
            const SizedBox(height: 4),
            Text('Choose what to remove',
                style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary)),
            const SizedBox(height: 24),
            _DeleteOption(
              icon: Icons.date_range_rounded,
              title: 'Delete entries from a date range',
              subtitle: 'Pick a start and end date',
              onTap: () {
                Navigator.pop(ctx);
                _deleteByDateRange(context);
              },
            ),
            const SizedBox(height: 12),
            _DeleteOption(
              icon: Icons.delete_sweep_rounded,
              title: 'Delete all mood entries',
              subtitle: 'Keeps settings and preferences',
              onTap: () {
                Navigator.pop(ctx);
                _deleteAllEntries(context);
              },
            ),
            const SizedBox(height: 12),
            _DeleteOption(
              icon: Icons.restart_alt_rounded,
              title: 'Reset everything',
              subtitle: 'Deletes all data and resets preferences',
              isDestructive: true,
              onTap: () {
                Navigator.pop(ctx);
                _resetEverything(context);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteByDateRange(BuildContext context) async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
            primary: AppTheme.primary,
            onPrimary: AppTheme.onPrimary,
            surface: AppTheme.surfaceContainerLow,
            onSurface: AppTheme.textPrimary,
          ),
        ),
        child: child!,
      ),
    );
    if (range == null || !context.mounted) return;

    final moodProvider = context.read<MoodProvider>();
    final from = range.start;
    final to = DateTime(range.end.year, range.end.month, range.end.day, 23, 59, 59);

    // Count entries in range
    final count = moodProvider.entries.where((e) =>
        !e.createdAt.isBefore(from) && !e.createdAt.isAfter(to)).length;

    final confirmed = await _confirmDelete(
      context,
      'Delete $count entries from ${_fmtDate(from)} to ${_fmtDate(range.end)}? This cannot be undone.',
    );
    if (confirmed != true || !context.mounted) return;

    HapticFeedback.mediumImpact();
    final deleted = await moodProvider.deleteEntriesInRange(from, to);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$deleted entries deleted'),
            backgroundColor: AppTheme.surfaceContainerHigh),
      );
    }
  }

  Future<void> _deleteAllEntries(BuildContext context) async {
    final moodProvider = context.read<MoodProvider>();
    final total = moodProvider.entries.length;

    final confirmed = await _confirmDelete(
      context,
      'Delete all $total mood entries? Your streak will reset. This cannot be undone.',
    );
    if (confirmed != true || !context.mounted) return;

    HapticFeedback.mediumImpact();
    await moodProvider.deleteAllEntries();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All entries deleted'),
            backgroundColor: AppTheme.surfaceContainerHigh),
      );
    }
  }

  Future<void> _resetEverything(BuildContext context) async {
    final confirmed = await _confirmDelete(
      context,
      'Reset Emotrace completely? This deletes all entries, resets your streak, and clears preferences. This cannot be undone.',
    );
    if (confirmed != true || !context.mounted) return;

    HapticFeedback.mediumImpact();
    await context.read<MoodProvider>().deleteAllEntries();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (context.mounted) {
      context.read<ThemeProvider>().setTheme(AccentTheme.gold);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Emotrace reset to defaults'),
            backgroundColor: AppTheme.surfaceContainerHigh),
      );
    }
  }

  Future<bool?> _confirmDelete(BuildContext context, String message) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceContainerLow,
        title: Text('Are you sure?', style: AppTheme.headlineSerifMedium),
        content: Text(message,
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Cancel', style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('Delete',
                style: AppTheme.bodyMedium.copyWith(color: const Color(0xFFE74C3C))),
          ),
        ],
      ),
    );
  }

  String _fmtDate(DateTime d) =>
      '${d.day}/${d.month}/${d.year}';
}

// ─── Accent theme selector ───────────────────────────────────────────────────

class _AccentThemeSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final current = themeProvider.current;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('ACCENT COLOR', style: AppTheme.labelCaps),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: AccentTheme.values.map((t) {
            final isSelected = t == current;
            final swatchColors = AccentColors.fromEnum(t);

            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                context.read<ThemeProvider>().setTheme(t);
              },
              child: Semantics(
                label: '${AccentColors.displayName(t)} theme${isSelected ? ', currently selected' : ''}',
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: swatchColors.accent,
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(color: Colors.white, width: 2)
                            : null,
                        boxShadow: isSelected
                            ? [BoxShadow(
                                color: swatchColors.glow,
                                blurRadius: 12,
                                spreadRadius: 2,
                              )]
                            : null,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AccentColors.displayName(t),
                      style: AppTheme.bodySmall.copyWith(
                        color: isSelected ? swatchColors.accent : AppTheme.textSecondary,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ─── Delete option tile ──────────────────────────────────────────────────────

class _DeleteOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDestructive;

  const _DeleteOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDestructive
                ? const Color(0xFFE74C3C).withValues(alpha: 0.3)
                : AppTheme.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(icon,
                color: isDestructive ? const Color(0xFFE74C3C) : AppTheme.textSecondary,
                size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDestructive ? const Color(0xFFE74C3C) : AppTheme.textPrimary,
                  )),
                  Text(subtitle, style: AppTheme.bodySmall),
                ],
              ),
            ),
            Icon(Icons.chevron_right,
                color: AppTheme.textSecondary, size: 18),
          ],
        ),
      ),
    );
  }
}

// ─── Section title ────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  final Color color;
  const _SectionTitle({required this.title, required this.color});

  @override
  Widget build(BuildContext context) => Text(
        title,
        style: AppTheme.headlineSerifMedium.copyWith(
            fontSize: 22, color: color),
      );
}

// ─── Section card ─────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final List<Widget> children;
  final Color borderColor;
  const _SectionCard({required this.children, required this.borderColor});

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor.withValues(alpha: 0.4)),
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
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: colors.accent.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: colors.accent, size: 20),
      ),
      title: Text(title,
          style: AppTheme.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: titleColor ?? AppTheme.textPrimary)),
      subtitle: Text(subtitle, style: AppTheme.bodySmall),
      trailing: trailing,
    );
  }
}

// ─── Custom Sanctuary toggle ──────────────────────────────────────────────────

class _SanctuaryToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  const _SanctuaryToggle({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;

    return GestureDetector(
      onTap: onChanged != null ? () => onChanged!(!value) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 48,
        height: 26,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(13),
          gradient: value
              ? LinearGradient(colors: [colors.accentSoft, colors.accent])
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
  final Color color;
  const _Divider({required this.color});

  @override
  Widget build(BuildContext context) => Divider(
        height: 1, thickness: 0.5,
        indent: 56, endIndent: 16,
        color: color,
      );
}
