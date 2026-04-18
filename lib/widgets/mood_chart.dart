// Widget: MoodChart — current month mood trend line chart
// Author: Piyush Puri | Date: 11 Apr 2026
// S4 fix: full month x-axis, correct multi-day averaging, today marker

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/theme.dart';
import '../models/mood_entry_model.dart';
import '../theme/theme_provider.dart';

class MoodChart extends StatelessWidget {
  final List<MoodEntry> entries;

  const MoodChart({super.key, required this.entries});

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;

    if (entries.isEmpty) {
      return _emptyState();
    }

    final now = DateTime.now();
    final year = now.year;
    final month = now.month;
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final today = now.day;

    // Group entries by day-of-month for current month, compute averages
    final dailySums = <int, double>{};
    final dailyCounts = <int, int>{};
    for (final e in entries) {
      if (e.createdAt.year == year && e.createdAt.month == month) {
        final day = e.createdAt.day;
        dailySums[day] = (dailySums[day] ?? 0) + e.moodScore;
        dailyCounts[day] = (dailyCounts[day] ?? 0) + 1;
      }
    }

    final spots = <FlSpot>[];
    for (int d = 1; d <= today; d++) {
      if (dailyCounts.containsKey(d)) {
        spots.add(FlSpot(d.toDouble(), dailySums[d]! / dailyCounts[d]!));
      }
    }

    if (spots.isEmpty) {
      return _emptyState();
    }

    return Container(
      height: 200,
      padding: const EdgeInsets.only(top: 16, right: 8, bottom: 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: LineChart(
        LineChartData(
          minX: 1,
          maxX: daysInMonth.toDouble(),
          minY: 1,
          maxY: 10,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          extraLinesData: ExtraLinesData(
            verticalLines: [
              VerticalLine(
                x: today.toDouble(),
                color: colors.accent.withValues(alpha: 0.3),
                strokeWidth: 1,
                dashArray: [4, 4],
              ),
            ],
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 24,
                interval: 3,
                getTitlesWidget: (value, _) {
                  if (value == 1 || value == 5 || value == 10) {
                    return Text(
                      value.toInt().toString(),
                      style: AppTheme.labelCaps.copyWith(fontSize: 10),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 22,
                interval: 1,
                getTitlesWidget: (value, _) {
                  final day = value.toInt();
                  // Show labels at 1, 7, 14, 21, 28 and last day
                  if (day == 1 || day == 7 || day == 14 || day == 21 ||
                      day == 28 || day == daysInMonth) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '$day',
                        style: AppTheme.labelCaps.copyWith(fontSize: 9),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.35,
              gradient: LinearGradient(
                colors: [colors.accentSoft, colors.accent],
              ),
              barWidth: 2.5,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, _, __, i) {
                  final isToday = spot.x.toInt() == today;
                  return FlDotCirclePainter(
                    radius: isToday ? 5 : 3,
                    color: colors.accent,
                    strokeWidth: isToday ? 2 : 1,
                    strokeColor: AppTheme.background,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    colors.accent.withValues(alpha: 0.15),
                    colors.accent.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => AppTheme.surfaceContainerHighest,
              getTooltipItems: (touchedSpots) => touchedSpots.map((s) {
                return LineTooltipItem(
                  'Day ${s.x.toInt()}: ${s.y.toStringAsFixed(1)}/10',
                  TextStyle(
                    color: colors.accent,
                    fontWeight: FontWeight.bold,
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

  Widget _emptyState() {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.bar_chart_outlined, color: AppTheme.textSecondary, size: 32),
            const SizedBox(height: 8),
            Text(
              'Your first entry will appear here',
              style: AppTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
