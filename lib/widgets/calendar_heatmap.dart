// Widget: CalendarHeatmap — mood color grid with month navigation
// Author: Piyush Puri | Date: 11 Apr 2026
// Sanctuary redesign: Piyush Puri | Date: 15 Apr 2026

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../config/constants.dart';
import '../config/theme.dart';
import '../models/mood_entry_model.dart';
import '../theme/accent_theme.dart';
import '../theme/theme_provider.dart';
import '../utils/date_utils.dart';

class CalendarHeatmap extends StatefulWidget {
  final List<MoodEntry> entries;

  const CalendarHeatmap({super.key, required this.entries});

  @override
  State<CalendarHeatmap> createState() => _CalendarHeatmapState();
}

class _CalendarHeatmapState extends State<CalendarHeatmap> {
  late DateTime _displayedMonth;

  Map<String, List<MoodEntry>> _entryMap = {};

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
      _entryMap.putIfAbsent(key, () => []).add(e);
    }
  }

  double _dayAverage(List<MoodEntry> entries) {
    if (entries.isEmpty) return 0.0;
    final sum = entries.fold<int>(0, (s, e) => s + e.moodScore);
    return sum / entries.length;
  }

  /// Derive heatmap color at render time from current accent + average score.
  Color _heatmapColor(double avg, AccentColors accent) {
    if (avg >= 9) return accent.accent.withValues(alpha: 1.0);
    if (avg >= 7) return accent.accent.withValues(alpha: 0.75);
    if (avg >= 5) return accent.accent.withValues(alpha: 0.5);
    if (avg >= 3) return accent.accent.withValues(alpha: 0.3);
    return accent.accent.withValues(alpha: 0.15);
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
    final accent = context.watch<ThemeProvider>().colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: _canGoPrev ? _prevMonth : null,
              icon: const Icon(Icons.chevron_left),
              color: _canGoPrev ? accent.accent : AppTheme.textSecondary,
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
              color: _canGoNext ? accent.accent : AppTheme.textSecondary,
              iconSize: 22,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
        const SizedBox(height: 12),
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
        ...weeks.map((week) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: week.map((day) => _buildCell(day, accent)).toList(),
              ),
            )),
        const SizedBox(height: 16),
        _buildLegend(accent),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.surfaceVariant,
            borderRadius: BorderRadius.circular(99),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.storage_rounded, size: 14, color: accent.accent),
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

  Widget _buildCell(DateTime? day, AccentColors accent) {
    if (day == null) {
      return const SizedBox(width: 32, height: 32);
    }

    final key = _dayKey(day);
    final dayEntries = _entryMap[key];
    final hasEntry = dayEntries != null && dayEntries.isNotEmpty;
    final isToday = AppDateUtils.isToday(day);

    final avg = hasEntry ? _dayAverage(dayEntries!) : 0.0;
    final cellColor = hasEntry
        ? _heatmapColor(avg, accent)
        : AppTheme.surfaceContainerHighest;
    final topEntry = hasEntry ? dayEntries!.first : null;
    final hasNotes = hasEntry && dayEntries!.any((e) => e.notes.isNotEmpty);

    return GestureDetector(
      onTap: topEntry != null ? () => _showEntryDetails(context, topEntry) : null,
      child: SizedBox(
        width: 32,
        height: 32,
        child: Container(
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: hasEntry
                ? cellColor
                : AppTheme.surfaceContainerHighest.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(6),
            border: isToday
                ? Border.all(color: accent.accent, width: 1.5)
                : !hasEntry
                    ? Border.all(
                        color: AppTheme.outlineVariant.withValues(alpha: 0.2),
                        width: 0.5)
                    : null,
          ),
          child: Stack(
            children: [
              Center(
                child: Text(
                  '${day.day}',
                  style: TextStyle(
                    color: hasEntry
                        ? (avg >= 7
                            ? Colors.black87
                            : Colors.white.withValues(alpha: 0.9))
                        : AppTheme.textSecondary.withValues(alpha: 0.6),
                    fontSize: 8,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (hasNotes)
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
    final accent = context.read<ThemeProvider>().colors;
    final emoji = AppConstants.moodEmojis[entry.moodScore.clamp(1, 10)] ?? '';
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
            Text(dateLabel, style: AppTheme.bodySmall),
            const SizedBox(height: 4),
            Text(timeLabel, style: AppTheme.bodySmall),
            const SizedBox(height: 16),
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
                            color: accent.accent.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(99),
                            border: Border.all(
                                color: accent.accent.withValues(alpha: 0.3)),
                          ),
                          child: Text(tag, style: AppTheme.bodySmall.copyWith(
                              color: accent.accent)),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 16),
            ],
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

  Widget _buildLegend(AccentColors accent) {
    final items = [
      ('Low', accent.accent.withValues(alpha: 0.15)),
      ('Off', accent.accent.withValues(alpha: 0.3)),
      ('Steady', accent.accent.withValues(alpha: 0.5)),
      ('Bright', accent.accent.withValues(alpha: 0.75)),
      ('Radiant', accent.accent.withValues(alpha: 1.0)),
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
