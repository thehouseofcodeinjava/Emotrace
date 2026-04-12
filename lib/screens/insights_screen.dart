// Screen: InsightsScreen | Author: Piyush Puri | Date: 11 Apr 2026
// Updated: 12 Apr 2026 — added pull-to-refresh
// Design reference: design/insights/code.html
// Features: stability score, 30-day mood trend chart, best/worst day pattern cards, emotion frequency bars.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/theme.dart';
import '../providers/insights_provider.dart';
import '../providers/mood_provider.dart';
import '../services/insight_service.dart';
import '../widgets/mood_chart.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InsightsProvider>().calculateInsights();
      context.read<MoodProvider>().loadEntries();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer2<InsightsProvider, MoodProvider>(
        builder: (context, insightsProvider, moodProvider, _) {
          final entries = moodProvider.entries;
          final isLoading = insightsProvider.isLoading || moodProvider.isLoading;

          // Full-screen spinner only on first load (no data yet)
          if (isLoading && entries.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final insights = insightsProvider.insights;

          // Minimum 3 entries to show any insights
          if (entries.length < 3) {
            return _EmptyInsightsState(entryCount: entries.length);
          }

          return RefreshIndicator(
            onRefresh: () => Future.wait([
              moodProvider.loadEntries(),
              insightsProvider.calculateInsights(),
            ]),
            color: AppTheme.teal,
            backgroundColor: AppTheme.cardBackground,
            child: CustomScrollView(
              // Required for RefreshIndicator to trigger on short content
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
              // ── App bar ──────────────────────────────────────────────────
              SliverAppBar(
                pinned: true,
                backgroundColor: AppTheme.background,
                title: const Text('EMOTRACE',
                    style: TextStyle(
                      color: AppTheme.teal,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    )),
                elevation: 0,
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Hero stats ───────────────────────────────────────
                      _HeroStats(insights: insights, entries: entries),
                      const SizedBox(height: 28),

                      // ── Mood trend chart ─────────────────────────────────
                      _SectionHeader(title: 'Mood Trend', label: 'Last 30 Days'),
                      const SizedBox(height: 12),
                      MoodChart(entries: entries),
                      const SizedBox(height: 28),

                      // ── Pattern cards (bento grid) ───────────────────────
                      if (insights.bestDay.isNotEmpty || insights.worstDay.isNotEmpty) ...[
                        _PatternGrid(insights: insights),
                        const SizedBox(height: 28),
                      ],

                      // ── Emotion frequency ────────────────────────────────
                      if (insights.emotionFrequency.isNotEmpty) ...[
                        const _SectionHeader(title: 'Emotion Frequency', label: ''),
                        const SizedBox(height: 12),
                        _EmotionFrequencyBars(
                            emotionFreq: insights.emotionFrequency),
                      ],
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
}

// ─── Hero stats (stability score + trend) ──────────────────────────────────

class _HeroStats extends StatelessWidget {
  final Insights insights;
  final List entries;

  const _HeroStats({required this.insights, required this.entries});

  @override
  Widget build(BuildContext context) {
    final avg = insights.averageMood;
    final stability = insights.stabilityScore;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'MONTHLY OVERVIEW',
          style: TextStyle(
            color: AppTheme.tealLight,
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Your Patterns',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 36,
            fontWeight: FontWeight.w900,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              stability > 0
                  ? '${stability.toStringAsFixed(1)}/10'
                  : avg > 0
                      ? '${avg.toStringAsFixed(1)}/10'
                      : '—',
              style: const TextStyle(
                color: AppTheme.tealLight,
                fontSize: 64,
                fontWeight: FontWeight.w900,
                letterSpacing: -2,
                height: 1,
              ),
            ),
            const SizedBox(width: 16),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'STABILITY SCORE',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.trending_up,
                          size: 14, color: AppTheme.tealLight),
                      const SizedBox(width: 4),
                      Text(
                        'Avg mood: ${avg.toStringAsFixed(1)}',
                        style: const TextStyle(
                            color: AppTheme.tealLight, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Pattern bento grid ─────────────────────────────────────────────────────

class _PatternGrid extends StatelessWidget {
  final Insights insights;

  const _PatternGrid({required this.insights});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (insights.bestDay.isNotEmpty)
          Expanded(
            child: _PatternCard(
              icon: Icons.wb_sunny_outlined,
              iconColor: AppTheme.tealLight,
              headline: 'You feel better on ${insights.bestDay}s',
              subtext:
                  'Your mood scores peak on ${insights.bestDay}s. Lean into what makes this day great.',
              background: AppTheme.cardHigh,
            ),
          ),
        if (insights.bestDay.isNotEmpty && insights.worstDay.isNotEmpty)
          const SizedBox(width: 12),
        if (insights.worstDay.isNotEmpty)
          Expanded(
            child: _PatternCard(
              icon: Icons.bolt_outlined,
              iconColor: const Color(0xFFFFB784),
              headline: 'Watch out on ${insights.worstDay}s',
              subtext:
                  '${insights.worstDay}s show a consistent dip. Plan some self-care on these days.',
              background: AppTheme.cardBackground,
            ),
          ),
      ],
    );
  }
}

class _PatternCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String headline;
  final String subtext;
  final Color background;

  const _PatternCard({
    required this.icon,
    required this.iconColor,
    required this.headline,
    required this.subtext,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.outlineVariant.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(height: 12),
          Text(
            headline,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtext,
            style: const TextStyle(
                color: AppTheme.textSecondary, fontSize: 11, height: 1.4),
          ),
        ],
      ),
    );
  }
}

// ─── Emotion frequency bars ─────────────────────────────────────────────────

class _EmotionFrequencyBars extends StatelessWidget {
  final Map<String, int> emotionFreq;

  const _EmotionFrequencyBars({required this.emotionFreq});

  @override
  Widget build(BuildContext context) {
    if (emotionFreq.isEmpty) return const SizedBox.shrink();

    final maxCount = emotionFreq.values.reduce((a, b) => a > b ? a : b);
    final entries = emotionFreq.entries.toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.outlineVariant.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: entries.map((entry) {
          final pct = maxCount > 0 ? entry.value / maxCount : 0.0;
          final isTop = entry == entries.first;

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      entry.key.toUpperCase(),
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1,
                      ),
                    ),
                    Text(
                      '${entry.value}',
                      style: TextStyle(
                        color: isTop ? AppTheme.tealLight : AppTheme.textSecondary,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: pct,
                    minHeight: 6,
                    backgroundColor: AppTheme.surfaceContainer,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isTop ? AppTheme.tealLight : AppTheme.teal,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Empty state ────────────────────────────────────────────────────────────

class _EmptyInsightsState extends StatelessWidget {
  final int entryCount;

  const _EmptyInsightsState({required this.entryCount});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.auto_graph_outlined,
                size: 56, color: AppTheme.textSecondary),
            const SizedBox(height: 20),
            const Text(
              'Your Patterns',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Log ${3 - entryCount} more mood${3 - entryCount == 1 ? '' : 's'} to unlock insights.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: AppTheme.textSecondary, fontSize: 14, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Section header ─────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final String label;

  const _SectionHeader({required this.title, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (label.isNotEmpty)
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 9,
              letterSpacing: 1,
            ),
          ),
      ],
    );
  }
}
