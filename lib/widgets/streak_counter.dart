// Widget: StreakCounter | Author: Piyush Puri | Date: 12 Apr 2026
// Sanctuary redesign: Piyush Puri | Date: 15 Apr 2026
// Fire icon in gold gradient square, Newsreader bold streak count

import 'package:flutter/material.dart';
import '../config/constants.dart';
import '../config/theme.dart';

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

    return Row(
      children: [
        // Current streak card
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
                // Gold fire icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFe9c176), Color(0xFFc5a059)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.local_fire_department,
                    color: Color(0xFF412d00),
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
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(99),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 4,
                          backgroundColor: AppTheme.surfaceContainerHighest,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              AppTheme.primary),
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

        // Longest streak card
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
                      color: AppTheme.primary,
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
