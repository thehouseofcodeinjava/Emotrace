// Widget: MoodChart — 30-day mood trend line chart | Author: Piyush Puri | Date: 11 Apr 2026
// Sanctuary redesign: Piyush Puri | Date: 15 Apr 2026
// Gold gradient line, no grid, Sanctuary surface container

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../config/theme.dart';
import '../models/mood_entry_model.dart';

class MoodChart extends StatelessWidget {
  final List<MoodEntry> entries;

  const MoodChart({super.key, required this.entries});

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return _emptyState();
    }

    // Group entries by day, average mood scores so same-day entries merge into one point
    final now = DateTime.now();
    final Map<int, List<double>> byDay = {};
    for (final e in entries) {
      final daysAgo = now.difference(e.createdAt).inDays;
      if (daysAgo <= 29) {
        byDay.putIfAbsent(daysAgo, () => []).add(e.moodScore.toDouble());
      }
    }
    final spots = byDay.entries.map((entry) {
      final avg = entry.value.reduce((a, b) => a + b) / entry.value.length;
      return FlSpot((29 - entry.key).toDouble(), avg);
    }).toList()
      ..sort((a, b) => a.x.compareTo(b.x));

    return Container(
      height: 200,
      padding: const EdgeInsets.only(top: 16, right: 16, bottom: 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: LineChart(
        LineChartData(
          minY: 1,
          maxY: 10,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 24,
                interval: 5,
                getTitlesWidget: (value, _) => Text(
                  value.toInt().toString(),
                  style: AppTheme.labelCaps.copyWith(fontSize: 10),
                ),
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
                interval: 7,
                getTitlesWidget: (value, _) {
                  final date = DateTime.now()
                      .subtract(Duration(days: (29 - value).round()));
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      DateFormat('d MMM').format(date),
                      style: AppTheme.labelCaps.copyWith(fontSize: 9),
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
              curveSmoothness: 0.35,
              gradient: const LinearGradient(
                colors: [Color(0xFFe9c176), Color(0xFFc5a059)],
              ),
              barWidth: 2.5,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, _, __, i) {
                  final isLast = i == spots.length - 1;
                  return FlDotCirclePainter(
                    radius: isLast ? 5 : 3,
                    color: const Color(0xFFe9c176),
                    strokeWidth: isLast ? 2 : 1,
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
                    const Color(0xFFe9c176).withValues(alpha: 0.15),
                    const Color(0xFFe9c176).withValues(alpha: 0.0),
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
                  '${s.y.toInt()}/10',
                  const TextStyle(
                    color: AppTheme.primary,
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
              'Log 3+ moods to see your trend',
              style: AppTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
