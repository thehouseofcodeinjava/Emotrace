// Widget: EmotionTagSelector | Author: Rajat Mahajan | Date: 11 Apr 2026
// Redesign: Session 7 (13 Apr 2026) — pill chips, softer states.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
      spacing: 10,
      runSpacing: 10,
      children: AppConstants.emotions.map((emotion) {
        final isSelected = selectedEmotions.contains(emotion);
        final isDisabled = atLimit && !isSelected;

        return _EmotionPill(
          label: emotion,
          selected: isSelected,
          disabled: isDisabled,
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
        );
      }).toList(),
    );
  }
}

class _EmotionPill extends StatelessWidget {
  final String label;
  final bool selected;
  final bool disabled;
  final VoidCallback? onTap;

  const _EmotionPill({
    required this.label,
    required this.selected,
    required this.disabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = selected
        ? AppTheme.tealLight.withValues(alpha: 0.14)
        : AppTheme.cardBackground;
    final border = selected
        ? AppTheme.tealLight.withValues(alpha: 0.6)
        : AppTheme.outlineVariant;
    final textColor = selected
        ? AppTheme.tealLight
        : disabled
            ? AppTheme.textTertiary
            : AppTheme.textSecondary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(99),
          border: Border.all(color: border, width: 1),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            color: textColor,
            fontSize: 13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            letterSpacing: 0.1,
          ),
        ),
      ),
    );
  }
}
