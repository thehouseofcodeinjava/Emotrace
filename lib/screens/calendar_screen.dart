// Screen: CalendarScreen | Author: Rajat Mahajan | Date: 11 Apr 2026
// TODO: calendar heatmap — 90-day mood grid | Author: Rajat Mahajan

import 'package:flutter/material.dart';

import '../config/theme.dart';
import '../config/constants.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // TODO: Replace with CalendarHeatmap widget (Week 4)
            Text(
              'Calendar Screen',
              style: TextStyle(color: AppTheme.textPrimary, fontSize: 22),
            ),
            SizedBox(height: 8),
            Text(
              'Last ${AppConstants.calendarDays} days heatmap coming soon',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
