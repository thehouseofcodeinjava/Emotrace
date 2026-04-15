// Widget: CalendarHeatmap — 90-day mood color grid with month navigation | Author: Piyush Puri | Date: 11 Apr 2026
// Sanctuary redesign: Piyush Puri | Date: 15 Apr 2026
// Square cells, 5-band Sanctuary color scale, note dots, gold today ring

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../config/constants.dart';
import '../config/theme.dart';
import '../models/mood_entry_model.dart';
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

  List<List<DateTime?>> _buildWeeks() {
    final firstDay = _displayedMonth;
    final lastDay = DateTime(_displayedMonth.year, _displayedMonth.month + 1, 0);

    final startOffset = firstDay.weekday - 1;
    final endOffset = 7 - lastDay.weekday;

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
              color: _canGoPrev ? AppTheme.primary : AppTheme.textSecondary,
              iconSize: 22,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 8),
            Text(
              monthLabel,
              style: AppTheme.headlineSerifMedium.copyWith(fontSize: 18),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: _canGoNext ? _nextMonth : null,
              icon: const Icon(Icons.chevron_right),
              color: _canGoNext ? AppTheme.primary : AppTheme.textSecondary,
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
          children: const ['M', 'T', 'W', 'T', 'F', 'S', 'S'].map((d) {
            return SizedBox(
              width: 32,
              child: Center(
                child: Text(
                  d,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.surfaceVariant,
            borderRadius: BorderRadius.circular(99),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.storage_rounded,
                  size: 14, color: AppTheme.primary),
              const SizedBox(width: 6),
              Text(
                'Total entries: ${widget.entries.length}',
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.textPrimary,
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
      return const SizedBox(width: 32, height: 32);
    }

    final key = _dayKey(day);
    final entry = _entryMap[key];
    final isToday = AppDateUtils.isToday(day);

    final cellColor = entry != null
        ? AppTheme.moodColorForScore(entry.moodScore)
        : AppTheme.surfaceContainerHighest;

    return GestureDetector(
      onTap: entry != null ? () => _showEntryDetails(context, entry) : null,
      child: AspectRatio(
        aspectRatio: 1.0,
        child: Container(
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: entry != null
                ? cellColor
                : AppTheme.surfaceContainerHighest.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(8),
            border: isToday
                ? Border.all(color: AppTheme.primary, width: 1.5)
                : entry == null
                    ? Border.all(
                        color: AppTheme.outlineVariant.withValues(alpha: 0.2),
                        width: 0.5)
                    : null,
          ),
          child: Stack(
            children: [
              if (day.day == 1)
                Center(
                  child: Text(
                    '${day.day}',
                    style: TextStyle(
                      color: entry != null
                          ? Colors.white.withValues(alpha: 0.9)
                          : AppTheme.textSecondary,
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              // Note dot
              if (entry != null && entry.notes.isNotEmpty)
                Positioned(
                  bottom: 3, left: 0, right: 0,
                  child: Center(
                    child: Container(
                      width: 4, height: 4,
                      decoration: const BoxDecoration(
                        color: Colors.white, shape: BoxShape.circle),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEntryDetails(BuildContext context, MoodEntry entry) {
    final emoji = AppConstants.moodEmojis[entry.moodScore.clamp(1, 10)] ?? '🙂';
    final dateLabel = DateFormat('EEEE, d MMMM yyyy').format(entry.createdAt);
    final timeLabel = DateFormat('HH:mm').format(entry.createdAt);
    final moodColor = AppTheme.moodColorForScore(entry.moodScore);
    final moodLabel = AppConstants.moodLabels[entry.moodScore] ?? '';

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
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.outlineVariant,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Date + time
            Text(dateLabel, style: AppTheme.bodySmall),
            const SizedBox(height: 4),
            Text(timeLabel, style: AppTheme.bodySmall),
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
                      style: AppTheme.headlineSerif.copyWith(
                        color: moodColor,
                        fontSize: 28,
                      ),
                    ),
                    Text(moodLabel, style: AppTheme.bodySmall),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Emotions
            if (entry.emotionTags.isNotEmpty) ...[
              Text('Emotions', style: AppTheme.labelCaps),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: entry.emotionTags
                    .map((tag) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(99),
                            border: Border.all(
                                color: AppTheme.primary.withValues(alpha: 0.3)),
                          ),
                          child: Text(tag, style: AppTheme.bodySmall.copyWith(
                              color: AppTheme.primary)),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 16),
            ],

            // Notes
            if (entry.notes.isNotEmpty) ...[
              Text('Notes', style: AppTheme.labelCaps),
              const SizedBox(height: 6),
              Text(entry.notes, style: AppTheme.bodyMedium),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    final items = [
      ('1–2', const Color(0xFF93000a)),
      ('3–4', const Color(0xFFc5a059)),
      ('5–6', const Color(0xFFb5ccc1)),
      ('7–8', const Color(0xFF394d45)),
      ('9–10', const Color(0xFF21342d)),
    ];
    return Wrap(
      spacing: 12,
      runSpacing: 6,
      children: items.map((item) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10, height: 10,
            decoration: BoxDecoration(
                color: item.$2, borderRadius: BorderRadius.circular(3)),
          ),
          const SizedBox(width: 4),
          Text(item.$1, style: AppTheme.bodySmall),
        ],
      )).toList(),
    );
  }
}
