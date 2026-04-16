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
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Consumer2<InsightsProvider, MoodProvider>(
        builder: (context, insightsProvider, moodProvider, _) {
          final entries = moodProvider.entries;
          final isLoading = insightsProvider.isLoading || moodProvider.isLoading;

          if (isLoading && entries.isEmpty) {
            return const Center(
                child: CircularProgressIndicator(color: AppTheme.primary));
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
            color: AppTheme.primary,
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
                        ? const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: SizedBox(
                                width: 20, height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: AppTheme.primary)),
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
                        // Editorial header
                        Text('Your Patterns',
                            style: AppTheme.headlineSerif.copyWith(fontSize: 36)),
                        Text('last 30 days of reflection',
                            style: AppTheme.bodyMedium.copyWith(
                                color: AppTheme.textSecondary)),
                        const SizedBox(height: 24),

                        // Mood Trend chart — full width
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
                        const SizedBox(height: 16),

                        // Stability Score card — full width below chart
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(16),
                            border: Border(
                              left: BorderSide(
                                color: AppTheme.primary.withValues(alpha: 0.3),
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
                                        color: AppTheme.primary, fontSize: 40),
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

                        // Pattern cards
                        if (insights.bestDay.isNotEmpty || insights.worstDay.isNotEmpty) ...[
                          _PatternGrid(insights: insights),
                          const SizedBox(height: 28),
                        ],

                        // Emotion frequency
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
              iconColor: AppTheme.primary,
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
                            color: isTop ? AppTheme.primary : AppTheme.textSecondary)),
                    Text('${entry.value}',
                        style: AppTheme.labelCaps.copyWith(
                            color: isTop ? AppTheme.primary : AppTheme.textSecondary)),
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
                      isTop ? AppTheme.primary : AppTheme.primaryContainer,
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.auto_graph_outlined, size: 56, color: AppTheme.primary),
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
