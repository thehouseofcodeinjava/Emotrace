// TODO: calendar heatmap — 90-day mood color grid | Author: Rajat Mahajan

import 'package:flutter/material.dart';

import '../config/theme.dart';

class CalendarHeatmap extends StatelessWidget {
  // TODO: accept mood data and render heatmap

  const CalendarHeatmap({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Implement full heatmap with week labels, month navigation, tap-to-view
    return const Center(
      child: Text(
        'Calendar Heatmap — Coming in Week 4',
        style: TextStyle(color: AppTheme.textSecondary),
      ),
    );
  }
}
