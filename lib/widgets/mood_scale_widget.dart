// TODO: mood scale widget — 1-10 emoji selector | Author: Rajat Mahajan

import 'package:flutter/material.dart';

import '../config/theme.dart';
import '../config/constants.dart';

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
    // TODO: Implement full emoji scale with tap-to-select, color gradient, motivational text
    return Column(
      children: [
        Text(
          AppConstants.moodEmojis[selectedMood] ?? '',
          style: const TextStyle(fontSize: 64),
        ),
        const SizedBox(height: 8),
        Text(
          AppConstants.moodLabels[selectedMood] ?? '',
          style: const TextStyle(color: AppTheme.teal, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(10, (i) {
            final mood = i + 1;
            final isSelected = mood == selectedMood;
            return GestureDetector(
              onTap: () => onMoodSelected(mood),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: isSelected ? 36 : 28,
                height: isSelected ? 36 : 28,
                decoration: BoxDecoration(
                  color: moodColors[mood],
                  shape: BoxShape.circle,
                  border: isSelected
                      ? Border.all(color: Colors.white, width: 2)
                      : null,
                ),
                child: Center(
                  child: Text(
                    '$mood',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isSelected ? 14 : 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        Text(
          AppConstants.moodMotivations[selectedMood] ?? '',
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
      ],
    );
  }
}
