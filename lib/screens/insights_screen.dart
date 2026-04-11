// Screen: InsightsScreen | Author: Rajat Mahajan | Date: 11 Apr 2026
// TODO: insights — patterns, trends, analytics | Author: Rajat Mahajan
// NOTE: InsightsProvider needs MoodRepository — dependency on Rajat's MoodService

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/insights_provider.dart';
import '../config/theme.dart';
import '../config/constants.dart';

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
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Insights'),
      ),
      body: Consumer<InsightsProvider>(
        builder: (context, insightsProvider, _) {
          if (insightsProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // TODO: Replace with full Insights UI (Week 4)
                Text(
                  'Insights Screen',
                  style: TextStyle(color: AppTheme.textPrimary, fontSize: 22),
                ),
                SizedBox(height: 8),
                Text(
                  'Need ${AppConstants.recentEntriesCount}+ entries to show patterns',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
