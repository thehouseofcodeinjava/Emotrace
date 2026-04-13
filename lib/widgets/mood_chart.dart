// Widget: MoodChart — 30-day mood trend line chart
// Redesign: Session 7 (13 Apr 2026) — gradient stroke, soft fill, ghost empty state.

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../config/theme.dart';
import '../models/mood_entry_model.dart';

class MoodChart extends StatelessWidget {
  final List<MoodEntry> entries;

  const MoodChart({super.key, required this.entries});

  @override
  Widget build(BuildContext context) {
    if (entries.length < 2) {
      return _EmptyState(count: entries.length);
    }

    final now = DateTime.now();
    final spots = <FlSpot>[];
    for (final e in entries) {
      final daysAgo = now.difference(e.createdAt).inDays.toDouble();
      if (daysAgo > 29) continue;
      spots.add(FlSpot(29 - daysAgo.clamp(0, 29), e.moodScore.toDouble()));
    }
    spots.sort((a, b) => a.x.compareTo(b.x));

    return Container(
      height: 220,
      padding: const EdgeInsets.only(top: 20, right: 16, bottom: 8, left: 4),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.outlineVariant),
      ),
      child: LineChart(
        LineChartData(
          minY: 1,
          maxY: 10,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 3,
            getDrawingHorizontalLine: (_) => FlLine(
              color: Colors.white.withValues(alpha: 0.04),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                interval: 3,
                getTitlesWidget: (value, _) => Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Text(
                    value.toInt().toString(),
                    style: GoogleFonts.inter(
                      color: AppTheme.textTertiary,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 22,
                interval: 7,
                getTitlesWidget: (value, _) {
                  final date = DateTime.now()
                      .subtract(Duration(days: (29 - value).round()));
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      DateFormat('d MMM').format(date),
                      style: GoogleFonts.inter(
                        color: AppTheme.textTertiary,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.38,
              gradient: LinearGradient(
                colors: [AppTheme.moodColor(1), AppTheme.moodColor(10)],
              ),
              barWidth: 3,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
                  radius: 4,
                  color: AppTheme.moodColor(spot.y.round()),
                  strokeWidth: 2,
                  strokeColor: AppTheme.background,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.tealLight.withValues(alpha: 0.25),
                    AppTheme.tealLight.withValues(alpha: 0.02),
                  ],
                ),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => AppTheme.cardHigh,
              tooltipRoundedRadius: 10,
              getTooltipItems: (touchedSpots) => touchedSpots.map((s) {
                return LineTooltipItem(
                  '${s.y.toInt()}/10',
                  GoogleFonts.inter(
                    color: AppTheme.moodColor(s.y.round()),
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final int count;
  const _EmptyState({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.outlineVariant),
      ),
      child: Stack(
        children: [
          // Ghost line suggestion
          CustomPaint(
            size: Size.infinite,
            painter: _GhostLinePainter(),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Your trend will unfold here',
                  style: GoogleFonts.inter(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  count == 0
                      ? 'Log your first mood to begin'
                      : 'One more entry and the line appears',
                  style: GoogleFonts.inter(
                    color: AppTheme.textTertiary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GhostLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.06)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final path = Path();
    final h = size.height;
    final w = size.width;
    path.moveTo(0, h * 0.65);
    path.cubicTo(w * 0.25, h * 0.35, w * 0.5, h * 0.75, w * 0.75, h * 0.4);
    path.cubicTo(w * 0.85, h * 0.25, w * 0.95, h * 0.5, w, h * 0.35);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
