// Screen: InsightsScreen | Author: Piyush Puri | Date: 13 Apr 2026
// Sanctuary redesign: Piyush Puri | Date: 15 Apr 2026

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

import '../config/theme.dart';
import '../models/mood_entry_model.dart';
import '../providers/insights_provider.dart';
import '../providers/mood_provider.dart';
import '../services/insight_service.dart';
import '../services/pdf_service.dart';
import '../theme/theme_provider.dart';
import '../widgets/mood_chart.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  bool _isSharing = false;

  Future<void> _shareInsightsPdf(
    BuildContext context,
    Insights insights,
    List<MoodEntry> entries,
  ) async {
    if (_isSharing) return;
    setState(() => _isSharing = true);
    try {
      final bytes = await PdfService.buildInsightsPdf(insights, entries);
      await Printing.sharePdf(bytes: bytes, filename: 'emotrace_insights.pdf');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e'),
              backgroundColor: AppTheme.errorContainer),
        );
      }
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

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
    final colors = context.watch<ThemeProvider>().colors;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Consumer2<InsightsProvider, MoodProvider>(
        builder: (context, insightsProvider, moodProvider, _) {
          final entries = moodProvider.entries;
          final isLoading = insightsProvider.isLoading || moodProvider.isLoading;

          if (isLoading && entries.isEmpty) {
            return Center(
                child: CircularProgressIndicator(color: colors.accent));
          }

          final insights = insightsProvider.insights;

          if (entries.length < 3) {
            return _EmptyInsightsState(entryCount: entries.length);
          }

          return RefreshIndicator(
            onRefresh: () => Future.wait([
              moodProvider.loadEntries(),
              insightsProvider.calculateInsights(),
            ]),
            color: colors.accent,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverAppBar(
                  pinned: true,
                  backgroundColor: AppTheme.background,
                  title: Text('EMOTRACE',
                      style: AppTheme.headlineSerifItalic.copyWith(fontSize: 22)),
                  elevation: 0,
                  actions: [
                    _isSharing
                        ? Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: SizedBox(
                                width: 20, height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: colors.accent)),
                          )
                        : IconButton(
                            icon: const Icon(Icons.share_outlined,
                                color: AppTheme.textSecondary),
                            tooltip: 'Share Insights PDF',
                            onPressed: () => _shareInsightsPdf(
                                context, insights, List<MoodEntry>.from(entries)),
                          ),
                  ],
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Your Patterns',
                            style: AppTheme.headlineSerif.copyWith(fontSize: 36)),
                        Text('last 30 days of reflection',
                            style: AppTheme.bodyMedium.copyWith(
                                color: AppTheme.textSecondary)),
                        const SizedBox(height: 24),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Mood Trend',
                                  style: AppTheme.headlineSerifMedium),
                              Text('Daily average sentiment',
                                  style: AppTheme.bodySmall),
                              const SizedBox(height: 12),
                              MoodChart(entries: entries),
                            ],
                          ),
                        ),
                        if (entries.length < 5)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Text(
                              'Patterns will appear here after about 5 check-ins.',
                              style: AppTheme.bodySmall.copyWith(
                                  fontStyle: FontStyle.italic,
                                  color: AppTheme.textSecondary),
                            ),
                          ),
                        const SizedBox(height: 16),
                        _MonthStatCards(entries: entries),
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(16),
                            border: Border(
                              left: BorderSide(
                                color: colors.accent.withValues(alpha: 0.3),
                                width: 3,
                              ),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('STABILITY SCORE',
                                  style: AppTheme.labelCaps),
                              const SizedBox(height: 12),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    insights.stabilityScore > 0
                                        ? insights.stabilityScore
                                            .toStringAsFixed(1)
                                        : insights.averageMood
                                            .toStringAsFixed(1),
                                    style: AppTheme.headlineSerif.copyWith(
                                        color: colors.accent, fontSize: 40),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 6),
                                    child: Text('/10',
                                        style: AppTheme.bodySmall.copyWith(
                                            color: AppTheme.textSecondary)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),
                        if (insights.bestDay.isNotEmpty || insights.worstDay.isNotEmpty) ...[
                          _PatternGrid(insights: insights),
                          const SizedBox(height: 28),
                        ],
                        if (insights.emotionFrequency.isNotEmpty) ...[
                          Text('Emotion Frequency',
                              style: AppTheme.headlineSerifMedium),
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

class _MonthStatCards extends StatelessWidget {
  final List<MoodEntry> entries;
  const _MonthStatCards({required this.entries});

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;
    final now = DateTime.now();

    final monthEntries = entries.where((e) =>
        e.createdAt.year == now.year && e.createdAt.month == now.month).toList();
    final totalThisMonth = monthEntries.length;
    final avgMood = monthEntries.isNotEmpty
        ? (monthEntries.fold<int>(0, (s, e) => s + e.moodScore) / monthEntries.length)
        : 0.0;

    // Most frequent emotion tag
    final tagCounts = <String, int>{};
    for (final e in monthEntries) {
      for (final tag in e.emotionTags) {
        tagCounts[tag] = (tagCounts[tag] ?? 0) + 1;
      }
    }
    String topTag = '—';
    if (tagCounts.isNotEmpty) {
      topTag = tagCounts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
      // Capitalize
      topTag = topTag[0].toUpperCase() + topTag.substring(1);
    }

    return Row(
      children: [
        _MiniStat(label: 'CHECK-INS', value: '$totalThisMonth', color: colors.accent),
        const SizedBox(width: 8),
        _MiniStat(label: 'AVG MOOD', value: avgMood > 0 ? avgMood.toStringAsFixed(1) : '—', color: colors.accent),
        const SizedBox(width: 8),
        _MiniStat(label: 'TOP MOOD', value: topTag, color: colors.accent),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _MiniStat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(value, style: AppTheme.headlineSerifMedium.copyWith(
                fontSize: 20, color: color)),
            const SizedBox(height: 4),
            Text(label, style: AppTheme.labelCaps.copyWith(fontSize: 8)),
          ],
        ),
      ),
    );
  }
}

class _PatternGrid extends StatelessWidget {
  final Insights insights;
  const _PatternGrid({required this.insights});

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;

    return Row(
      children: [
        if (insights.bestDay.isNotEmpty)
          Expanded(
            child: _PatternCard(
              icon: Icons.wb_sunny_outlined,
              iconColor: colors.accent,
              headline: 'You feel better on ${insights.bestDay}s',
              subtext:
                  'Your mood scores peak on ${insights.bestDay}s. Lean into what makes this day great.',
              bg: AppTheme.surfaceContainerHigh,
            ),
          ),
        if (insights.bestDay.isNotEmpty && insights.worstDay.isNotEmpty)
          const SizedBox(width: 12),
        if (insights.worstDay.isNotEmpty)
          Expanded(
            child: _PatternCard(
              icon: Icons.bolt_outlined,
              iconColor: AppTheme.secondary,
              headline: 'Watch out on ${insights.worstDay}s',
              subtext:
                  '${insights.worstDay}s show a consistent dip. Plan some self-care on these days.',
              bg: AppTheme.surfaceContainerLow,
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
  final Color bg;

  const _PatternCard({
    required this.icon,
    required this.iconColor,
    required this.headline,
    required this.subtext,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.outlineVariant.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(height: 12),
          Text(headline,
              style: AppTheme.headlineSerifMedium.copyWith(
                  fontSize: 15, color: AppTheme.textPrimary)),
          const SizedBox(height: 6),
          Text(subtext, style: AppTheme.bodySmall.copyWith(height: 1.4)),
        ],
      ),
    );
  }
}

class _EmotionFrequencyBars extends StatelessWidget {
  final Map<String, int> emotionFreq;
  const _EmotionFrequencyBars({required this.emotionFreq});

  @override
  Widget build(BuildContext context) {
    if (emotionFreq.isEmpty) return const SizedBox.shrink();
    final colors = context.watch<ThemeProvider>().colors;
    final maxCount = emotionFreq.values.reduce((a, b) => a > b ? a : b);
    final entries = emotionFreq.entries.toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLow,
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
                    Text(entry.key.toUpperCase(),
                        style: AppTheme.labelCaps.copyWith(
                            color: isTop ? colors.accent : AppTheme.textSecondary)),
                    Text('${entry.value}',
                        style: AppTheme.labelCaps.copyWith(
                            color: isTop ? colors.accent : AppTheme.textSecondary)),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: pct,
                    minHeight: 6,
                    backgroundColor: AppTheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isTop ? colors.accent : colors.accentDim,
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

class _EmptyInsightsState extends StatelessWidget {
  final int entryCount;
  const _EmptyInsightsState({required this.entryCount});

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_graph_outlined, size: 56, color: colors.accent),
            const SizedBox(height: 20),
            Text('Your Patterns', style: AppTheme.headlineSerif),
            const SizedBox(height: 10),
            Text(
              'Log ${3 - entryCount} more mood${3 - entryCount == 1 ? '' : 's'} to unlock insights.',
              textAlign: TextAlign.center,
              style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textSecondary, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
