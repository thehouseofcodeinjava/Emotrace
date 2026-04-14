// Widget: StreakCounter | Author: Piyush Puri | Date: 12 Apr 2026
// Full bento-grid implementation — replaces Rajat Mahajan's shell (11 Apr 2026)
// Used by: CalendarScreen (and HomeScreen in Week 2)

import 'package:flutter/material.dart';

import '../config/theme.dart';
import '../config/constants.dart';

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
    final progress =
        (currentStreak / AppConstants.streakGoal).clamp(0.0, 1.0);

    return Row(
      children: [
        // ── Current streak card (larger) ──────────────────────────────
        Expanded(
          flex: 3,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.cardBackground,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'CONSISTENCY',
                  style: TextStyle(
                    color: AppTheme.orange,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  currentStreak == 0
                      ? 'Start your streak!'
                      : 'Current Streak: $currentStreak days 🔥',
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(99),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 6,
                          backgroundColor: AppTheme.surfaceVariant,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              AppTheme.tealLight),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Goal: ${AppConstants.streakGoal}',
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),

        // ── Longest streak card ───────────────────────────────────────
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.cardHigh,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: AppTheme.outlineVariant.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Longest Streak',
                  style: TextStyle(
                      color: AppTheme.textSecondary, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Text(
                  '$longestStreak days',
                  style: const TextStyle(
                    color: AppTheme.tealLight,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
