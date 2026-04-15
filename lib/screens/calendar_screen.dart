// Screen: CalendarScreen | Author: Piyush Puri | Date: 11 Apr 2026
// BMS redesign: Rajat Mahajan | Date: 15 Apr 2026
// BookMyShow listing style — filter tabs, stat badges, dark heatmap card

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/mood_provider.dart';
import '../utils/date_utils.dart';
import '../widgets/calendar_heatmap.dart';

// ─── BMS palette ──────────────────────────────────────────────────────────────
const Color _kBg        = Color(0xFF0A0A0A);
const Color _kSurface   = Color(0xFF1A1A1A);
const Color _kRed       = Color(0xFFE31E24);
const Color _kText      = Color(0xFFFFFFFF);
const Color _kTextSec   = Color(0xFF9E9E9E);
const Color _kBorder    = Color(0xFF2E2E2E);
const Color _kOrange    = Color(0xFFF5A623);

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MoodProvider>().loadEntries();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: Consumer<MoodProvider>(
        builder: (context, moodProvider, _) {
          final entries = moodProvider.entries;

          if (moodProvider.isLoading && entries.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: _kRed),
            );
          }

          final streak = AppDateUtils.calculateCurrentStreak(
            entries.map((e) => e.createdAt).toList(),
          );
          final longestStreak = _calculateLongestStreak(
              entries.map((e) => e.createdAt).toList());

          final now = DateTime.now();
          final daysElapsed = now.day;
          final thisMonthEntries = entries.where((e) =>
              e.createdAt.month == now.month &&
              e.createdAt.year == now.year).length;
          final completionPct =
              daysElapsed > 0 ? (thisMonthEntries / daysElapsed * 100).round() : 0;

          return RefreshIndicator(
            onRefresh: moodProvider.loadEntries,
            color: _kRed,
            backgroundColor: _kSurface,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // BMS-style app bar
                SliverAppBar(
                  pinned: true,
                  backgroundColor: _kBg,
                  elevation: 0,
                  title: const Text(
                    'EMOTRACE',
                    style: TextStyle(
                      color: _kText,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      letterSpacing: 1.2,
                    ),
                  ),
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(48),
                    child: Container(
                      decoration: const BoxDecoration(
                        border: Border(
                            bottom: BorderSide(color: _kBorder, width: 1)),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        labelColor: _kText,
                        unselectedLabelColor: _kTextSec,
                        labelStyle: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          letterSpacing: 0.5,
                        ),
                        indicator: const UnderlineTabIndicator(
                          borderSide: BorderSide(color: _kRed, width: 3),
                        ),
                        tabs: const [
                          Tab(text: 'HEATMAP'),
                          Tab(text: 'INSIGHTS'),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),

                      // Page title
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Your Mood History',
                          style: TextStyle(
                            color: _kText,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Track your emotional patterns',
                          style: TextStyle(color: _kTextSec, fontSize: 13),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Stat badges row — BMS ticket count style
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            _BadgeStat(
                              icon: Icons.local_fire_department_rounded,
                              iconColor: _kOrange,
                              value: '$streak days',
                              label: 'Current Streak',
                            ),
                            const SizedBox(width: 12),
                            _BadgeStat(
                              icon: Icons.check_circle_outline_rounded,
                              iconColor: _kRed,
                              value: '$completionPct%',
                              label: 'This Month',
                            ),
                            const SizedBox(width: 12),
                            _BadgeStat(
                              icon: Icons.emoji_events_outlined,
                              iconColor: const Color(0xFF4FC3F7),
                              value: '$longestStreak days',
                              label: 'Best Streak',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Heatmap card
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: _kSurface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: _kBorder),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: _kRed,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text('ACTIVITY MAP',
                                      style: TextStyle(
                                        color: _kText,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              CalendarHeatmap(entries: entries),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Insight summary card
                      if (entries.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _InsightSummaryCard(
                            longestStreak: longestStreak,
                            totalEntries: entries.length,
                          ),
                        ),
                      const SizedBox(height: 40),
                    ],
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

// ─── Badge stat card ──────────────────────────────────────────────────────────

class _BadgeStat extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;
  const _BadgeStat({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: _kSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _kBorder),
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(height: 6),
            Text(value,
              style: const TextStyle(
                color: _kText,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(label,
              style: const TextStyle(
                color: _kTextSec,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Insight summary card ─────────────────────────────────────────────────────

class _InsightSummaryCard extends StatelessWidget {
  final int longestStreak;
  final int totalEntries;
  const _InsightSummaryCard({
    required this.longestStreak,
    required this.totalEntries,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: _kRed.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.insights_rounded, color: _kRed, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Your Historical Peak',
                  style: TextStyle(
                    color: _kText,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _InfoChip(label: '$longestStreak days', sublabel: 'Longest'),
                    const SizedBox(width: 12),
                    _InfoChip(label: '$totalEntries', sublabel: 'Total logs'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String sublabel;
  const _InfoChip({required this.label, required this.sublabel});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label,
          style: const TextStyle(
            color: _kRed,
            fontWeight: FontWeight.w800,
            fontSize: 13,
          ),
        ),
        const SizedBox(width: 4),
        Text(sublabel,
          style: const TextStyle(color: _kTextSec, fontSize: 12)),
      ],
    );
  }
}
