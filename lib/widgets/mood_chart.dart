// TODO: mood chart — line chart for last 30-day trend | Author: Rajat Mahajan

import 'package:flutter/material.dart';

import '../config/theme.dart';

class MoodChart extends StatelessWidget {
  // TODO: accept mood data list and render fl_chart line chart

  const MoodChart({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Implement full line chart using fl_chart package
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Text(
          'Mood Chart — Coming in Week 4',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
      ),
    );
  }
}
