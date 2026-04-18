// Widget: StreakCounter | Author: Piyush Puri | Date: 12 Apr 2026
// Sanctuary redesign: Piyush Puri | Date: 15 Apr 2026

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/constants.dart';
import '../config/theme.dart';
import '../theme/theme_provider.dart';

class StreakCounter extends StatelessWidget {
  final int currentStreak;
  final int longestStreak;

  const StreakCounter({
    super.key,
    required this.currentStreak,
    required this.longestStreak,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (currentStreak / AppConstants.streakGoal).clamp(0.0, 1.0);
    final colors = context.watch<ThemeProvider>().colors;

    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [colors.accent, colors.accentDim],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.local_fire_department,
                    color: AppTheme.onPrimary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('CURRENT STREAK', style: AppTheme.labelCaps),
                      const SizedBox(height: 4),
                      Text(
                        currentStreak == 0 ? 'Start today!' : '$currentStreak Days',
                        style: AppTheme.headlineSerifMedium.copyWith(
                            fontSize: 22,
                            color: colors.accent,
                            fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(99),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 4,
                          backgroundColor: AppTheme.surfaceContainerHighest,
                          valueColor: AlwaysStoppedAnimation<Color>(colors.accent),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text('Goal: ${AppConstants.streakGoal} days',
                          style: AppTheme.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: AppTheme.outlineVariant.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Longest Streak', style: AppTheme.bodySmall),
                const SizedBox(height: 8),
                Text(
                  '$longestStreak days',
                  style: AppTheme.headlineSerif.copyWith(
                      fontSize: 28,
                      color: colors.accent,
                      letterSpacing: -1),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
