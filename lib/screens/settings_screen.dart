// Screen: SettingsScreen | Author: Piyush Puri | Date: 13 Apr 2026
// BMS redesign: Rajat Mahajan | Date: 15 Apr 2026
// BookMyShow account/profile page style — profile card, grouped red-icon tiles

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

import '../config/constants.dart';
import '../providers/mood_provider.dart';
import '../providers/settings_provider.dart';
import '../services/pdf_service.dart';

// ─── BMS palette ──────────────────────────────────────────────────────────────
const Color _kBg        = Color(0xFF0A0A0A);
const Color _kSurface   = Color(0xFF1A1A1A);
const Color _kSurfaceHi = Color(0xFF252525);
const Color _kRed       = Color(0xFFE31E24);
const Color _kRedDark   = Color(0xFFC1121F);
const Color _kText      = Color(0xFFFFFFFF);
const Color _kTextSec   = Color(0xFF9E9E9E);
const Color _kBorder    = Color(0xFF2E2E2E);

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
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: Colors.red.shade900,
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
      backgroundColor: _kBg,
      body: SafeArea(
        child: Consumer<SettingsProvider>(
          builder: (context, settings, _) {
            return ListView(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 40),
              children: [
                // ── Profile / account card (BMS top header) ─────────
                _ProfileCard(),
                const SizedBox(height: 24),

                // ── Section: Appearance ──────────────────────────────
                _SectionLabel(title: 'APPEARANCE'),
                _BmsGroup(children: [
                  _BmsTile(
                    icon: Icons.dark_mode_rounded,
                    title: 'Dark Mode',
                    subtitle: 'Only dark theme in this version',
                    trailing: _BmsToggle(value: true, onChanged: null),
                  ),
                ]),
                const SizedBox(height: 16),

                // ── Section: Notifications ───────────────────────────
                _SectionLabel(title: 'NOTIFICATIONS'),
                _BmsGroup(children: [
                  _BmsTile(
                    icon: Icons.notifications_none_rounded,
                    title: 'Daily Reminder',
                    subtitle: 'Get a nudge to log your mood every day',
                    trailing: _BmsToggle(
                      value: settings.dailyReminderEnabled,
                      onChanged: (v) => settings.toggleReminder(v),
                    ),
                  ),
                  if (settings.dailyReminderEnabled) ...[
                    _BmsDivider(),
                    _BmsTile(
                      icon: Icons.access_time_rounded,
                      title: 'Reminder Time',
                      subtitle: _formatTime(settings.reminderTime),
                      trailing: const Icon(Icons.chevron_right,
                          color: _kTextSec, size: 20),
                      onTap: () => _pickReminderTime(context, settings),
                    ),
                  ],
                ]),
                const SizedBox(height: 16),

                // ── Section: Data & Privacy ──────────────────────────
                _SectionLabel(title: 'DATA & PRIVACY'),
                _BmsGroup(children: [
                  _BmsTile(
                    icon: Icons.download_rounded,
                    title: 'Export Mood History',
                    subtitle: 'Share all entries as a PDF report',
                    trailing: _isExporting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: _kRed))
                        : const Icon(Icons.chevron_right,
                            color: _kTextSec, size: 20),
                    onTap: _isExporting
                        ? null
                        : () => _exportHistoryPdf(context),
                  ),
                  _BmsDivider(),
                  _BmsTile(
                    icon: Icons.delete_outline_rounded,
                    title: 'Clear All Data',
                    subtitle: 'Permanently delete all mood entries',
                    titleColor: _kRed,
                    iconColor: _kRed,
                    trailing: const Icon(Icons.chevron_right,
                        color: _kTextSec, size: 20),
                    onTap: () => _confirmClearData(context),
                  ),
                ]),
                const SizedBox(height: 16),

                // ── Section: About ───────────────────────────────────
                _SectionLabel(title: 'ABOUT'),
                _BmsGroup(children: [
                  _BmsTile(
                    icon: Icons.info_outline_rounded,
                    title: AppConstants.appName,
                    subtitle: 'Version 1.0.0 — MVP',
                  ),
                  _BmsDivider(),
                  _BmsTile(
                    icon: Icons.people_outline_rounded,
                    title: 'Built by',
                    subtitle: 'Rajat Mahajan & Piyush Puri',
                  ),
                ]),
                const SizedBox(height: 32),

                // Footer
                const Center(
                  child: Text(
                    '❤ Built by EMOTRACE',
                    style: TextStyle(
                      color: _kRed,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
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

  Future<void> _pickReminderTime(
      BuildContext context, SettingsProvider settings) async {
    final parts = settings.reminderTime.split(':');
    final initial =
        TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));

    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          timePickerTheme: const TimePickerThemeData(
            backgroundColor: Color(0xFF1A1A1A),
            hourMinuteColor: Color(0xFF252525),
            hourMinuteTextColor: Colors.white,
            dialBackgroundColor: Color(0xFF252525),
            dialHandColor: Color(0xFFE31E24),
            dialTextColor: Colors.white,
            entryModeIconColor: Color(0xFFE31E24),
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
        backgroundColor: _kSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: _kBorder),
        ),
        title: const Text('Clear All Data?',
          style: TextStyle(
            color: _kText,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        content: const Text(
          'This will permanently delete all your mood entries and cannot be undone.',
          style: TextStyle(color: _kTextSec, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel',
                style: TextStyle(color: _kTextSec)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete Everything',
                style: TextStyle(
                    color: _kRed, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      // TODO: call DatabaseService.clearAllEntries() — Week 5 | Author: Piyush Puri
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data cleared (coming in Week 5)'),
          backgroundColor: Color(0xFF252525),
        ),
      );
    }
  }
}

// ─── Profile card — BMS account header ───────────────────────────────────────

class _ProfileCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      color: _kSurface,
      child: Row(
        children: [
          // Avatar
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_kRed, _kRedDark],
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Center(
              child: Text(
                'R',
                style: TextStyle(
                  color: _kText,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Name & details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Rajat Mahajan',
                  style: TextStyle(
                    color: _kText,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _kRed.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                            color: _kRed.withValues(alpha: 0.4)),
                      ),
                      child: const Text(
                        'MVP USER',
                        style: TextStyle(
                          color: _kRed,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('v1.0.0',
                        style: TextStyle(color: _kTextSec, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: _kTextSec, size: 20),
        ],
      ),
    );
  }
}

// ─── Section label ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String title;
  const _SectionLabel({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Text(title,
        style: const TextStyle(
          color: _kTextSec,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}

// ─── Group container ──────────────────────────────────────────────────────────

class _BmsGroup extends StatelessWidget {
  final List<Widget> children;
  const _BmsGroup({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kBorder),
      ),
      child: Column(children: children),
    );
  }
}

// ─── Settings tile ────────────────────────────────────────────────────────────

class _BmsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? titleColor;
  final Color? iconColor;

  const _BmsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
    this.titleColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: (iconColor ?? _kRed).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor ?? _kRed, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                    style: TextStyle(
                      color: titleColor ?? _kText,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(subtitle,
                    style: const TextStyle(
                      color: _kTextSec,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 12),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}

// ─── BMS-style toggle ─────────────────────────────────────────────────────────

class _BmsToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  const _BmsToggle({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onChanged != null ? () => onChanged!(!value) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 46,
        height: 26,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(13),
          color: value ? _kRed : _kSurfaceHi,
          border: Border.all(
            color: value ? _kRed : _kBorder,
            width: 1,
          ),
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              left: value ? 22 : 2,
              top: 2,
              child: Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  color: _kText,
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

class _BmsDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => const Divider(
        height: 1,
        thickness: 0.5,
        indent: 68,
        endIndent: 0,
        color: _kBorder,
      );
}
