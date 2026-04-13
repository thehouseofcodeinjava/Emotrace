// Widget: MoodScaleWidget | Author: Rajat Mahajan | Date: 11 Apr 2026
// Full impl: Piyush Puri | Date: 13 Apr 2026
// Emoji + numbered scale, tap-to-select, color gradient, motivational text

import 'package:flutter/material.dart';

import '../config/constants.dart';
import '../config/theme.dart';

class MoodScaleWidget extends StatelessWidget {
  final int selectedMood;
  final ValueChanged<int> onMoodSelected;

  const MoodScaleWidget({
    super.key,
    required this.selectedMood,
    required this.onMoodSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Big emoji + label ────────────────────────────────
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (child, animation) =>
              ScaleTransition(scale: animation, child: child),
          child: Text(
            AppConstants.moodEmojis[selectedMood] ?? '',
            key: ValueKey(selectedMood),
            style: const TextStyle(fontSize: 72),
          ),
        ),
        const SizedBox(height: 8),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 150),
          child: Text(
            AppConstants.moodLabels[selectedMood] ?? '',
            key: ValueKey('label_$selectedMood'),
            style: TextStyle(
              color: moodColors[selectedMood] ?? AppTheme.teal,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
        ),

        const SizedBox(height: 24),

        // ── Number circles ───────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(10, (i) {
            final mood = i + 1;
            final isSelected = mood == selectedMood;
            final color = moodColors[mood] ?? AppTheme.teal;

            return GestureDetector(
              onTap: () => onMoodSelected(mood),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: isSelected ? 38 : 28,
                height: isSelected ? 38 : 28,
                decoration: BoxDecoration(
                  color: isSelected ? color : color.withValues(alpha: 0.35),
                  shape: BoxShape.circle,
                  border: isSelected
                      ? Border.all(color: Colors.white, width: 2)
                      : null,
                  boxShadow: isSelected
                      ? [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 8)]
                      : null,
                ),
                child: Center(
                  child: Text(
                    '$mood',
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppTheme.textSecondary,
                      fontSize: isSelected ? 14 : 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),

        const SizedBox(height: 16),

        // ── Motivational text ────────────────────────────────
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Text(
            AppConstants.moodMotivations[selectedMood] ?? '',
            key: ValueKey('motivation_$selectedMood'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
