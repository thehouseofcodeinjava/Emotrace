// Widget: CalendarHeatmap — 90-day mood color grid with month navigation | Author: Piyush Puri | Date: 11 Apr 2026
// Design reference: design/emotional_calendar/code.html
// Features: month navigation, tap-to-view entry details, color legend, entry count.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../config/constants.dart';
import '../config/theme.dart';
import '../models/mood_entry_model.dart';
import '../utils/color_utils.dart';
import '../utils/date_utils.dart';

class CalendarHeatmap extends StatefulWidget {
  final List<MoodEntry> entries;

  const CalendarHeatmap({super.key, required this.entries});

  @override
  State<CalendarHeatmap> createState() => _CalendarHeatmapState();
}

class _CalendarHeatmapState extends State<CalendarHeatmap> {
  late DateTime _displayedMonth;

  // Map<"yyyy-MM-dd", MoodEntry> for O(1) lookup
  Map<String, MoodEntry> _entryMap = {};

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _displayedMonth = DateTime(now.year, now.month);
    _buildEntryMap();
  }

  @override
  void didUpdateWidget(CalendarHeatmap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.entries != widget.entries) _buildEntryMap();
  }

  void _buildEntryMap() {
    _entryMap = {};
    for (final e in widget.entries) {
      final key = _dayKey(e.createdAt);
      _entryMap[key] = e;
    }
  }

  String _dayKey(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

  void _prevMonth() {
    // Only allow going back up to 3 months ago
    final limit = DateTime.now().subtract(const Duration(days: 90));
    final prev = DateTime(_displayedMonth.year, _displayedMonth.month - 1);
    if (!prev.isBefore(DateTime(limit.year, limit.month))) {
      setState(() => _displayedMonth = prev);
    }
  }

  void _nextMonth() {
    final now = DateTime.now();
    final current = DateTime(now.year, now.month);
    if (_displayedMonth.isBefore(current)) {
      setState(() => _displayedMonth =
          DateTime(_displayedMonth.year, _displayedMonth.month + 1));
    }
  }

  bool get _canGoPrev {
    final limit = DateTime.now().subtract(const Duration(days: 90));
    final prev = DateTime(_displayedMonth.year, _displayedMonth.month - 1);
    return !prev.isBefore(DateTime(limit.year, limit.month));
  }

  bool get _canGoNext {
    final now = DateTime.now();
    return _displayedMonth.isBefore(DateTime(now.year, now.month));
  }

  // Returns list of weeks for the displayed month.
  // Each week is a list of 7 nullable DateTimes (Mon–Sun).
  List<List<DateTime?>> _buildWeeks() {
    final firstDay = _displayedMonth;
    final lastDay = DateTime(_displayedMonth.year, _displayedMonth.month + 1, 0);

    // Weekday: Mon=1 … Sun=7 (Dart DateTime)
    final startOffset = firstDay.weekday - 1; // cells before the 1st
    final endOffset = 7 - lastDay.weekday;    // cells after the last

    final allDays = <DateTime?>[
      ...List.filled(startOffset, null),
      ...List.generate(lastDay.day, (i) => DateTime(firstDay.year, firstDay.month, i + 1)),
      ...List.filled(endOffset, null),
    ];

    final weeks = <List<DateTime?>>[];
    for (int i = 0; i < allDays.length; i += 7) {
      weeks.add(allDays.sublist(i, i + 7));
    }
    return weeks;
  }

  @override
  Widget build(BuildContext context) {
    final weeks = _buildWeeks();
    final monthLabel = DateFormat('MMMM yyyy').format(_displayedMonth);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Month navigation header ─────────────────────────────────────────
        Row(
          children: [
            IconButton(
              onPressed: _canGoPrev ? _prevMonth : null,
              icon: const Icon(Icons.chevron_left),
              color: _canGoPrev ? AppTheme.textPrimary : AppTheme.textSecondary,
              iconSize: 22,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 8),
            Text(
              monthLabel,
              style: AppTheme.displaySerif(size: 22, weight: FontWeight.w500),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: _canGoNext ? _nextMonth : null,
              icon: const Icon(Icons.chevron_right),
              color: _canGoNext ? AppTheme.textPrimary : AppTheme.textSecondary,
              iconSize: 22,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // ── Weekday labels ──────────────────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: ['M', 'T', 'W', 'T', 'F', 'S', 'S'].map((d) {
            return SizedBox(
              width: 34,
              child: Center(
                child: Text(
                  d,
                  style: GoogleFonts.inter(
                    color: AppTheme.textTertiary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 6),

        // ── Heatmap grid ────────────────────────────────────────────────────
        ...weeks.map((week) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: week.map((day) => _buildCell(day)).toList(),
              ),
            )),

        const SizedBox(height: 16),

        // ── Legend ──────────────────────────────────────────────────────────
        _buildLegend(),

        const SizedBox(height: 12),

        // ── Total entries count ─────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: AppTheme.cardHigh,
            borderRadius: BorderRadius.circular(99),
            border: Border.all(color: AppTheme.outlineVariant),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.auto_awesome_outlined,
                  size: 14, color: AppTheme.tealLight),
              const SizedBox(width: 6),
              Text(
                '${widget.entries.length} entries so far',
                style: GoogleFonts.inter(
                  color: AppTheme.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCell(DateTime? day) {
    if (day == null) {
      return const SizedBox(width: 34, height: 34);
    }

    final key = _dayKey(day);
    final entry = _entryMap[key];
    final isToday = AppDateUtils.isToday(day);
    final hasEntry = entry != null;

    final cellColor = hasEntry
        ? AppTheme.moodColor(entry.moodScore)
        : AppTheme.surfaceContainer;

    return GestureDetector(
      onTap: hasEntry ? () => _showEntryDetails(context, entry) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: hasEntry ? cellColor : AppTheme.surfaceContainer,
          borderRadius: BorderRadius.circular(8),
          border: isToday
              ? Border.all(color: AppTheme.tealLight, width: 1.5)
              : Border.all(
                  color: hasEntry
                      ? Colors.white.withValues(alpha: 0.08)
                      : AppTheme.outlineVariant,
                  width: 0.8,
                ),
          boxShadow: hasEntry
              ? [
                  BoxShadow(
                    color: cellColor.withValues(alpha: 0.35),
                    blurRadius: 8,
                    spreadRadius: -1,
                  ),
                ]
              : null,
        ),
        child: day.day == 1
            ? Center(
                child: Text(
                  '${day.day}',
                  style: GoogleFonts.inter(
                    color: hasEntry
                        ? Colors.white.withValues(alpha: 0.92)
                        : AppTheme.textTertiary,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              )
            : null,
      ),
    );
  }

  void _showEntryDetails(BuildContext context, MoodEntry entry) {
    final emoji = _emojiForScore(entry.moodScore);
    final dateLabel = DateFormat('EEEE, d MMMM yyyy').format(entry.createdAt);
    final timeLabel = DateFormat('HH:mm').format(entry.createdAt);

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.outlineVariant,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Date + time
            Text(dateLabel,
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 12)),
            const SizedBox(height: 4),
            Text(timeLabel,
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 11)),
            const SizedBox(height: 16),

            // Emoji + score
            Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 40)),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${entry.moodScore}/10',
                      style: TextStyle(
                        color: AppColorUtils.getMoodColor(entry.moodScore),
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      AppColorUtils.getMoodLabel(entry.moodScore),
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Emotions
            if (entry.emotionTags.isNotEmpty) ...[
              const Text('Emotions',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: entry.emotionTags
                    .map((tag) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.teal.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(99),
                            border: Border.all(
                                color: AppTheme.teal.withValues(alpha: 0.3)),
                          ),
                          child: Text(tag,
                              style: const TextStyle(
                                  color: AppTheme.tealLight, fontSize: 12)),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 16),
            ],

            // Notes
            if (entry.notes.isNotEmpty) ...[
              const Text('Notes',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
              const SizedBox(height: 6),
              Text(entry.notes,
                  style: const TextStyle(
                      color: AppTheme.textPrimary, fontSize: 14)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    final items = [
      ('1-2', AppTheme.moodColor(2)),
      ('3-4', AppTheme.moodColor(4)),
      ('5-6', AppTheme.moodColor(6)),
      ('7-8', AppTheme.moodColor(8)),
      ('9-10', AppTheme.moodColor(10)),
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 6,
      children: items.map((item) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: item.$2,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: 5),
            Text(
              item.$1,
              style: GoogleFonts.inter(
                color: AppTheme.textTertiary,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  String _emojiForScore(int score) {
    const emojis = {
      1: '😣', 2: '😢', 3: '😕', 4: '😐', 5: '😶',
      6: '🙂', 7: '😊', 8: '😄', 9: '😁', 10: '🤩',
    };
    return emojis[score.clamp(1, 10)] ?? '🙂';
  }
}
