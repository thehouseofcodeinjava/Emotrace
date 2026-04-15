// Widget: MoodScaleWidget | Author: Rajat Mahajan | Date: 11 Apr 2026
// Sanctuary redesign: Piyush Puri | Date: 15 Apr 2026
// 10-bar scale chart — replaces emoji number circles

import 'package:flutter/material.dart';
import '../config/constants.dart';
import '../config/theme.dart';

class MoodScaleWidget extends StatelessWidget {
  final int selectedMood;
  final ValueChanged<int> onMoodSelected;

  // Bell-curve bar heights (index 0 = mood 1, index 9 = mood 10)
  static const _barHeights = [32.0, 38.0, 44.0, 50.0, 56.0, 50.0, 44.0, 56.0, 50.0, 64.0];

  const MoodScaleWidget({
    super.key,
    required this.selectedMood,
    required this.onMoodSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          // Endpoint labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Tired', style: AppTheme.labelCaps),
              Text('Radiant', style: AppTheme.labelCaps),
            ],
          ),
          const SizedBox(height: 16),
          // Bars
          SizedBox(
            height: 72,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(10, (i) {
                final mood = i + 1;
                final isSelected = mood == selectedMood;
                final barH = _barHeights[i];

                return GestureDetector(
                  onTap: () => onMoodSelected(mood),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 22,
                    height: isSelected ? barH + 8 : barH,
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Color(0xFFe9c176), Color(0xFFc5a059)],
                            )
                          : null,
                      color: isSelected
                          ? null
                          : AppTheme.surfaceContainerHighest
                              .withValues(alpha: 0.5),
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(8)),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppTheme.primary.withValues(alpha: 0.4),
                                blurRadius: 12,
                                offset: const Offset(0, -4),
                              ),
                            ]
                          : null,
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 16),
          // Label for selected mood
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 150),
            child: Text(
              AppConstants.moodLabels[selectedMood] ?? '',
              key: ValueKey(selectedMood),
              style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.primary, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
