// Screen: InsightsScreen | Author: Piyush Puri | Date: 13 Apr 2026
// BMS redesign: Rajat Mahajan | Date: 15 Apr 2026
// BookMyShow offers/deals style — featured card, horizontal pattern cards, red bars

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

import '../models/mood_entry_model.dart';
import '../providers/insights_provider.dart';
import '../providers/mood_provider.dart';
import '../services/insight_service.dart';
import '../services/pdf_service.dart';
import '../widgets/mood_chart.dart';

// ─── BMS palette ──────────────────────────────────────────────────────────────
const Color _kBg        = Color(0xFF0A0A0A);
const Color _kSurface   = Color(0xFF1A1A1A);
const Color _kSurfaceHi = Color(0xFF252525);
const Color _kRed       = Color(0xFFE31E24);
const Color _kRedDark   = Color(0xFFC1121F);
const Color _kText      = Color(0xFFFFFFFF);
const Color _kTextSec   = Color(0xFF9E9E9E);
const Color _kBorder    = Color(0xFF2E2E2E);
const Color _kOrange    = Color(0xFFF5A623);

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
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: Colors.red.shade900,
          ),
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
      backgroundColor: _kBg,
      body: Consumer2<InsightsProvider, MoodProvider>(
        builder: (context, insightsProvider, moodProvider, _) {
          final entries = moodProvider.entries;
          final isLoading =
              insightsProvider.isLoading || moodProvider.isLoading;

          if (isLoading && entries.isEmpty) {
            return const Center(
                child: CircularProgressIndicator(color: _kRed));
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
                  actions: [
                    _isSharing
                        ? const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: _kRed),
                              ),
                            ),
                          )
                        : IconButton(
                            icon: const Icon(Icons.share_outlined,
                                color: _kTextSec),
                            tooltip: 'Share Insights PDF',
                            onPressed: () => _shareInsightsPdf(
                                context,
                                insights,
                                List<MoodEntry>.from(entries)),
                          ),
                  ],
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Page title
                        const Text(
                          'Your Patterns',
                          style: TextStyle(
                            color: _kText,
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const Text(
                          'Last 30 days of reflection',
                          style: TextStyle(color: _kTextSec, fontSize: 13),
                        ),
                        const SizedBox(height: 24),

                        // Featured stability card — like BMS "Gold Offer"
                        _StabilityFeatureCard(insights: insights),
                        const SizedBox(height: 20),

                        // Mood trend chart card
                        _ChartCard(entries: entries),
                        const SizedBox(height: 24),

                        // Pattern cards — horizontal scroll
                        if (insights.bestDay.isNotEmpty ||
                            insights.worstDay.isNotEmpty) ...[
                          _SectionHeader(title: 'YOUR PATTERNS'),
                          const SizedBox(height: 12),
                          _PatternRow(insights: insights),
                          const SizedBox(height: 24),
                        ],

                        // Emotion frequency
                        if (insights.emotionFrequency.isNotEmpty) ...[
                          _SectionHeader(title: 'EMOTION FREQUENCY'),
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

// ─── Section header ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) => Text(
        title,
        style: const TextStyle(
          color: _kText,
          fontWeight: FontWeight.w800,
          fontSize: 14,
          letterSpacing: 0.5,
        ),
      );
}

// ─── Featured stability card ──────────────────────────────────────────────────

class _StabilityFeatureCard extends StatelessWidget {
  final Insights insights;
  const _StabilityFeatureCard({required this.insights});

  @override
  Widget build(BuildContext context) {
    final score = insights.stabilityScore > 0
        ? insights.stabilityScore
        : insights.averageMood;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E0A0A), Color(0xFF1A1A1A)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kRed.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          // Score display
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _kRed,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text('STABILITY SCORE',
                  style: TextStyle(
                    color: _kText,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                score.toStringAsFixed(1),
                style: const TextStyle(
                  color: _kText,
                  fontSize: 56,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
              const Text('/10',
                style: TextStyle(
                  color: _kTextSec,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                )),
            ],
          ),
          const Spacer(),
          // Visual gauge
          _ScoreGauge(score: score),
        ],
      ),
    );
  }
}

class _ScoreGauge extends StatelessWidget {
  final double score;
  const _ScoreGauge({required this.score});

  @override
  Widget build(BuildContext context) {
    final pct = (score / 10).clamp(0.0, 1.0);
    return Column(
      children: [
        SizedBox(
          width: 70,
          height: 70,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: pct,
                strokeWidth: 7,
                backgroundColor: _kSurfaceHi,
                valueColor: const AlwaysStoppedAnimation<Color>(_kRed),
              ),
              Text(
                '${(pct * 100).round()}%',
                style: const TextStyle(
                  color: _kText,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Text('MOOD HEALTH',
          style: TextStyle(
            color: _kTextSec,
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

// ─── Mood chart card ──────────────────────────────────────────────────────────

class _ChartCard extends StatelessWidget {
  final List<MoodEntry> entries;
  const _ChartCard({required this.entries});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('MOOD TREND',
            style: TextStyle(
              color: _kTextSec,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          const Text('Daily average sentiment',
            style: TextStyle(color: _kText, fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 16),
          MoodChart(entries: entries),
        ],
      ),
    );
  }
}

// ─── Pattern cards row ────────────────────────────────────────────────────────

class _PatternRow extends StatelessWidget {
  final Insights insights;
  const _PatternRow({required this.insights});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (insights.bestDay.isNotEmpty)
          Expanded(
            child: _PatternCard(
              icon: Icons.wb_sunny_outlined,
              iconColor: _kOrange,
              headline: 'Peak: ${insights.bestDay}s',
              subtext: 'Your mood scores peak on ${insights.bestDay}s.',
              accent: _kOrange,
            ),
          ),
        if (insights.bestDay.isNotEmpty && insights.worstDay.isNotEmpty)
          const SizedBox(width: 12),
        if (insights.worstDay.isNotEmpty)
          Expanded(
            child: _PatternCard(
              icon: Icons.bolt_outlined,
              iconColor: _kRed,
              headline: 'Watch: ${insights.worstDay}s',
              subtext: '${insights.worstDay}s show a consistent dip.',
              accent: _kRed,
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
  final Color accent;

  const _PatternCard({
    required this.icon,
    required this.iconColor,
    required this.headline,
    required this.subtext,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 12),
          Text(headline,
            style: const TextStyle(
              color: _kText,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 6),
          Text(subtext,
            style: const TextStyle(
              color: _kTextSec,
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Emotion frequency bars ───────────────────────────────────────────────────

class _EmotionFrequencyBars extends StatelessWidget {
  final Map<String, int> emotionFreq;
  const _EmotionFrequencyBars({required this.emotionFreq});

  @override
  Widget build(BuildContext context) {
    if (emotionFreq.isEmpty) return const SizedBox.shrink();
    final maxCount = emotionFreq.values.reduce((a, b) => a > b ? a : b);
    final entries = emotionFreq.entries.toList();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kBorder),
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
                      style: TextStyle(
                        color: isTop ? _kText : _kTextSec,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isTop
                            ? _kRed.withValues(alpha: 0.15)
                            : _kSurfaceHi,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${entry.value}×',
                        style: TextStyle(
                          color: isTop ? _kRed : _kTextSec,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: pct,
                    minHeight: 6,
                    backgroundColor: _kSurfaceHi,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isTop ? _kRed : _kBorder,
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

// ─── Empty state ──────────────────────────────────────────────────────────────

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
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                color: _kRed.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_graph_outlined,
                  size: 40, color: _kRed),
            ),
            const SizedBox(height: 20),
            const Text('Your Patterns',
              style: TextStyle(
                color: _kText,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Log ${3 - entryCount} more mood${3 - entryCount == 1 ? '' : 's'} to unlock insights.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: _kTextSec, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [_kRed, _kRedDark]),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text('START LOGGING',
                style: TextStyle(
                  color: _kText,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

