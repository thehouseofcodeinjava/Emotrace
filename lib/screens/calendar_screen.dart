// Screen: CalendarScreen | Author: Piyush Puri | Date: 11 Apr 2026
// Sanctuary redesign: Piyush Puri | Date: 15 Apr 2026
// Stat cards row (streak + completion %), Sanctuary heatmap card, editorial header

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/theme.dart';
import '../providers/mood_provider.dart';
import '../utils/date_utils.dart';
import '../widgets/calendar_heatmap.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MoodProvider>().loadEntries();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Consumer<MoodProvider>(
        builder: (context, moodProvider, _) {
          final entries = moodProvider.entries;

          if (moodProvider.isLoading && entries.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            );
          }

          final streak = AppDateUtils.calculateCurrentStreak(
            entries.map((e) => e.createdAt).toList(),
          );
          final longestStreak = _calculateLongestStreak(
              entries.map((e) => e.createdAt).toList());

          // Completion % — entries this month / days elapsed this month
          final now = DateTime.now();
          final daysElapsed = now.day;
          final thisMonthEntries = entries.where((e) =>
              e.createdAt.month == now.month &&
              e.createdAt.year == now.year).length;
          final completionPct =
              daysElapsed > 0 ? (thisMonthEntries / daysElapsed * 100).round() : 0;

          return RefreshIndicator(
            onRefresh: moodProvider.loadEntries,
            color: AppTheme.primary,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // App bar
                SliverAppBar(
                  pinned: true,
                  backgroundColor: AppTheme.background,
                  title: Text('EMOTRACE',
                      style: AppTheme.headlineSerifItalic.copyWith(fontSize: 22)),
                  elevation: 0,
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Editorial header
                        Text('Your Emotional', style: AppTheme.headlineSerif),
                        Text('Calendar',
                            style: AppTheme.headlineSerifItalic.copyWith(fontSize: 32)),
                        const SizedBox(height: 4),
                        Text('Your mood history at a glance',
                            style: AppTheme.bodyMedium.copyWith(
                                color: AppTheme.textSecondary)),
                        const SizedBox(height: 24),

                        // Stat cards row
                        Row(
                          children: [
                            Expanded(
                              child: _StatCard(
                                label: 'CURRENT STREAK',
                                value: '$streak days 🔥',
                                bg: AppTheme.surfaceContainerLow,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _StatCard(
                                label: 'COMPLETION',
                                value: '$completionPct%',
                                bg: AppTheme.surfaceContainerHigh,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Heatmap card
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: CalendarHeatmap(entries: entries),
                        ),
                        const SizedBox(height: 20),

                        // Insight card
                        if (entries.isNotEmpty)
                          _InsightCard(
                            longestStreak: longestStreak,
                            totalEntries: entries.length,
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  int _calculateLongestStreak(List<DateTime> dates) {
    if (dates.isEmpty) return 0;
    final days = dates
        .map((d) => DateTime(d.year, d.month, d.day))
        .toSet()
        .toList()
      ..sort();
    if (days.isEmpty) return 0;
    int longest = 1, current = 1;
    for (int i = 1; i < days.length; i++) {
      if (days[i].difference(days[i - 1]).inDays == 1) {
        current++;
        if (current > longest) longest = current;
      } else {
        current = 1;
      }
    }
    return longest;
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color bg;
  const _StatCard({required this.label, required this.value, required this.bg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTheme.labelCaps),
          const SizedBox(height: 8),
          Text(value,
              style: AppTheme.headlineSerifMedium.copyWith(color: AppTheme.primary)),
        ],
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  final int longestStreak;
  final int totalEntries;
  const _InsightCard({required this.longestStreak, required this.totalEntries});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.outlineVariant.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Historical Peak', style: AppTheme.headlineSerifMedium),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text('Longest streak: ',
                        style: AppTheme.bodySmall),
                    Text('$longestStreak days',
                        style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text('Total entries: ',
                        style: AppTheme.bodySmall),
                    Text('$totalEntries',
                        style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.insights, color: AppTheme.primary, size: 22),
          ),
        ],
      ),
    );
  }
}
