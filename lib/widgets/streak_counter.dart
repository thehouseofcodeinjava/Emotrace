// Widget: StreakCounter | Author: Piyush Puri | Date: 12 Apr 2026
// Redesign: Session 7 (13 Apr 2026) — pluralization fix, warmer copy, depth.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

  String _days(int n) => n == 1 ? '1 day' : '$n days';

  @override
  Widget build(BuildContext context) {
    final progress =
        (currentStreak / AppConstants.streakGoal).clamp(0.0, 1.0);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Current streak card ────────────────────────────────
        Expanded(
          flex: 3,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.cardBackground,
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              border: Border.all(color: AppTheme.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('CONSISTENCY', style: AppTheme.microLabel(color: AppTheme.orange)),
                const SizedBox(height: 12),
                Text(
                  currentStreak == 0
                      ? 'Start your streak'
                      : '${_days(currentStreak)} 🔥',
                  style: GoogleFonts.inter(
                    color: AppTheme.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 18),
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
                    const SizedBox(width: 10),
                    Text(
                      'Goal ${AppConstants.streakGoal}',
                      style: GoogleFonts.inter(
                        color: AppTheme.textTertiary,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),

        // ── Longest streak card ────────────────────────────────
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.cardHigh,
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              border: Border.all(color: AppTheme.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('LONGEST', style: AppTheme.microLabel()),
                const SizedBox(height: 8),
                Text(
                  _days(longestStreak),
                  style: AppTheme.displaySerif(
                    size: 30,
                    color: AppTheme.tealLight,
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
