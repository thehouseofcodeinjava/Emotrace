// TODO: emotion tag selector — chip-based emotion picker | Author: Rajat Mahajan

import 'package:flutter/material.dart';

import '../config/theme.dart';
import '../config/constants.dart';

class EmotionTagSelector extends StatelessWidget {
  final List<String> selectedEmotions;
  final ValueChanged<List<String>> onChanged;

  const EmotionTagSelector({
    super.key,
    required this.selectedEmotions,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // TODO: Implement full emotion chip selector with max selection limit
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: AppConstants.emotions.map((emotion) {
        final isSelected = selectedEmotions.contains(emotion);
        return FilterChip(
          label: Text(emotion),
          selected: isSelected,
          onSelected: (selected) {
            final updated = List<String>.from(selectedEmotions);
            if (selected) {
              updated.add(emotion);
            } else {
              updated.remove(emotion);
            }
            onChanged(updated);
          },
          selectedColor: AppTheme.teal.withAlpha(80),
          checkmarkColor: AppTheme.teal,
          labelStyle: TextStyle(
            color: isSelected ? AppTheme.teal : AppTheme.textSecondary,
          ),
          backgroundColor: AppTheme.cardBackground,
          side: BorderSide(
            color: isSelected ? AppTheme.teal : Colors.transparent,
          ),
        );
      }).toList(),
    );
  }
}
