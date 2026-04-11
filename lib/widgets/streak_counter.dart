// TODO: streak counter widget — displays current + longest streak | Author: Rajat Mahajan

import 'package:flutter/material.dart';

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
    // TODO: Implement full streak badge with flame animation
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          children: [
            Text(
              '$currentStreak day streak',
              style: const TextStyle(
                color: AppTheme.orange,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Longest: $longestStreak days',
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
            ),
          ],
        ),
      ],
    );
  }
}
