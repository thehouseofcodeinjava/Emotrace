// Widget: EmotionTagSelector | Author: Rajat Mahajan | Date: 11 Apr 2026
// Sanctuary redesign: Piyush Puri | Date: 15 Apr 2026
// 2-column icon grid replaces FilterChip Wrap

import 'package:flutter/material.dart';
import '../config/constants.dart';
import '../config/theme.dart';

class EmotionTagSelector extends StatelessWidget {
  final List<String> selectedEmotions;
  final ValueChanged<List<String>> onChanged;

  static const int _maxSelections = 5;

  static const Map<String, IconData> _emotionIcons = {
    'calm':        Icons.water_drop,
    'focused':     Icons.filter_center_focus,
    'inspired':    Icons.light_mode,
    'grounded':    Icons.eco,
    'peaceful':    Icons.auto_awesome,
    'energetic':   Icons.energy_savings_leaf,
    'anxious':     Icons.waves,
    'happy':       Icons.mood,
    'sad':         Icons.sentiment_dissatisfied,
    'stressed':    Icons.psychology_alt,
    'grateful':    Icons.favorite,
    'overwhelmed': Icons.cloud,
    'angry':       Icons.local_fire_department,
    'excited':     Icons.bolt,
    'tired':       Icons.bedtime,
    'content':     Icons.spa,
  };

  const EmotionTagSelector({
    super.key,
    required this.selectedEmotions,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final atLimit = selectedEmotions.length >= _maxSelections;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      childAspectRatio: 3.5,
      children: AppConstants.emotions.map((emotion) {
        final isSelected = selectedEmotions.contains(emotion);
        final isDisabled = atLimit && !isSelected;
        final icon = _emotionIcons[emotion] ?? Icons.circle;

        return GestureDetector(
          onTap: isDisabled
              ? null
              : () {
                  final updated = List<String>.from(selectedEmotions);
                  if (isSelected) {
                    updated.remove(emotion);
                  } else {
                    updated.add(emotion);
                  }
                  onChanged(updated);
                },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.secondaryContainer
                  : AppTheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? AppTheme.primary.withValues(alpha: 0.7)
                    : AppTheme.outlineVariant.withValues(alpha: 0.3),
                width: isSelected ? 1 : 0.5,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppTheme.primary.withValues(alpha: 0.15),
                        blurRadius: 8,
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: isSelected
                      ? AppTheme.primary
                      : isDisabled
                          ? AppTheme.textSecondary.withValues(alpha: 0.3)
                          : AppTheme.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  emotion,
                  style: AppTheme.bodySmall.copyWith(
                    color: isSelected
                        ? AppTheme.primary
                        : isDisabled
                            ? AppTheme.textSecondary.withValues(alpha: 0.3)
                            : AppTheme.textSecondary,
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
