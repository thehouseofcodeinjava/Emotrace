// Widget: EmotionTagSelector | Author: Rajat Mahajan | Date: 11 Apr 2026
// Full impl: Piyush Puri | Date: 13 Apr 2026
// FilterChip emotion picker — max 5 selections, teal highlight

import 'package:flutter/material.dart';

import '../config/constants.dart';
import '../config/theme.dart';

class EmotionTagSelector extends StatelessWidget {
  final List<String> selectedEmotions;
  final ValueChanged<List<String>> onChanged;

  static const int _maxSelections = 5;

  const EmotionTagSelector({
    super.key,
    required this.selectedEmotions,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final atLimit = selectedEmotions.length >= _maxSelections;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: AppConstants.emotions.map((emotion) {
        final isSelected = selectedEmotions.contains(emotion);
        final isDisabled = atLimit && !isSelected;

        return FilterChip(
          label: Text(emotion),
          selected: isSelected,
          onSelected: isDisabled
              ? null
              : (selected) {
                  final updated = List<String>.from(selectedEmotions);
                  if (selected) {
                    updated.add(emotion);
                  } else {
                    updated.remove(emotion);
                  }
                  onChanged(updated);
                },
          selectedColor: AppTheme.teal.withValues(alpha: 0.20),
          checkmarkColor: AppTheme.teal,
          showCheckmark: true,
          labelStyle: TextStyle(
            color: isSelected
                ? AppTheme.teal
                : isDisabled
                    ? AppTheme.textSecondary.withValues(alpha: 0.4)
                    : AppTheme.textSecondary,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
          backgroundColor: AppTheme.cardBackground,
          disabledColor: AppTheme.cardBackground,
          side: BorderSide(
            color: isSelected
                ? AppTheme.teal.withValues(alpha: 0.7)
                : Colors.transparent,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        );
      }).toList(),
    );
  }
}
