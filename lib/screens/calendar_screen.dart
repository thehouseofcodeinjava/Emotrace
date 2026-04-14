// Screen: CalendarScreen | Author: Piyush Puri | Date: 11 Apr 2026
// Updated: 12 Apr 2026 — wired StreakCounter widget, added pull-to-refresh
// Design reference: design/emotional_calendar/code.html

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/theme.dart';
import '../providers/mood_provider.dart';
import '../utils/date_utils.dart';
import '../widgets/calendar_heatmap.dart';
import '../widgets/streak_counter.dart';

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
      body: Consumer<MoodProvider>(
        builder: (context, moodProvider, _) {
          final entries = moodProvider.entries;

          // Full-screen spinner only on first load (no data yet)
          if (moodProvider.isLoading && entries.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final streak = AppDateUtils.calculateCurrentStreak(
            entries.map((e) => e.createdAt).toList(),
          );
          final longestStreak =
              _calculateLongestStreak(entries.map((e) => e.createdAt).toList());

          return RefreshIndicator(
            onRefresh: moodProvider.loadEntries,
            color: AppTheme.teal,
            backgroundColor: AppTheme.cardBackground,
            child: CustomScrollView(
              // Required for RefreshIndicator to trigger on short content
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // ── App bar ──────────────────────────────────────────────
                SliverAppBar(
                  pinned: true,
                  backgroundColor: AppTheme.background,
                  title: const Text(
                    'EMOTRACE',
                    style: TextStyle(
                      color: AppTheme.teal,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  elevation: 0,
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Header ────────────────────────────────────────
                        const Text(
                          'HISTORICAL OVERVIEW',
                          style: TextStyle(
                            color: AppTheme.tealLight,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Your Emotional\nCalendar',
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Scroll to see past 90 days',
                          style: TextStyle(
                              color: AppTheme.textSecondary, fontSize: 14),
                        ),
                        const SizedBox(height: 24),

                        // ── Streak bento grid (StreakCounter widget) ──────
                        StreakCounter(
                          currentStreak: streak,
                          longestStreak: longestStreak,
                        ),
                        const SizedBox(height: 24),

                        // ── Heatmap card ──────────────────────────────────
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppTheme.cardBackground,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: CalendarHeatmap(entries: entries),
                        ),
                        const SizedBox(height: 20),

                        // ── Trends summary ────────────────────────────────
                        if (entries.isNotEmpty)
                          _TrendsSummaryCard(entries: entries),
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

// ─── Trends summary card ────────────────────────────────────────────────────

class _TrendsSummaryCard extends StatelessWidget {
  final List entries;

  const _TrendsSummaryCard({required this.entries});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final thisMonthEntries = entries.where((e) {
      return e.createdAt.month == now.month && e.createdAt.year == now.year;
    }).toList();

    final prevMonthEntries = entries.where((e) {
      final prev = DateTime(now.year, now.month - 1);
      return e.createdAt.month == prev.month && e.createdAt.year == prev.year;
    }).toList();

    double? diff;
    if (thisMonthEntries.isNotEmpty && prevMonthEntries.isNotEmpty) {
      final thisAvg =
          thisMonthEntries.fold<int>(0, (s, e) => s + (e.moodScore as int)) /
              thisMonthEntries.length;
      final prevAvg =
          prevMonthEntries.fold<int>(0, (s, e) => s + (e.moodScore as int)) /
              prevMonthEntries.length;
      diff = prevAvg > 0 ? ((thisAvg - prevAvg) / prevAvg * 100) : null;
    }

    final monthName = _monthName(now.month);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.cardBackground, AppTheme.background],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.outlineVariant.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$monthName Trends',
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  diff != null
                      ? 'You\'ve been ${diff.abs().toStringAsFixed(0)}% '
                          '${diff > 0 ? 'more positive' : 'less positive'} '
                          'this month compared to last month. Keep tracking!'
                      : 'Keep logging to see monthly comparisons.',
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.teal.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              diff != null && diff > 0
                  ? Icons.trending_up
                  : diff != null && diff < 0
                      ? Icons.trending_down
                      : Icons.trending_flat,
              color: AppTheme.tealLight,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  String _monthName(int month) {
    const names = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return names[month];
  }
}
