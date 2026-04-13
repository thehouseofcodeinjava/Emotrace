// Widget: MoodScaleWidget | Author: Rajat Mahajan | Date: 11 Apr 2026
// Redesign: Session 7 (13 Apr 2026) — gradient slider replaces 10-circle row.
// Inspired by Apple State of Mind + How We Feel.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
    final selectedColor = AppTheme.moodColor(selectedMood);
    final emoji = AppConstants.moodEmojis[selectedMood] ?? '';
    final label = AppConstants.moodLabels[selectedMood] ?? '';
    final motivation = AppConstants.moodMotivations[selectedMood] ?? '';

    return Column(
      children: [
        // ── Hero emoji ────────────────────────────────────────
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 260),
          transitionBuilder: (child, animation) => ScaleTransition(
            scale: Tween<double>(begin: 0.85, end: 1).animate(animation),
            child: FadeTransition(opacity: animation, child: child),
          ),
          child: Container(
            key: ValueKey(selectedMood),
            width: 132,
            height: 132,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  selectedColor.withValues(alpha: 0.25),
                  selectedColor.withValues(alpha: 0.0),
                ],
              ),
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 82)),
            ),
          ),
        ),
        const SizedBox(height: 18),

        // ── Score number (serif) ──────────────────────────────
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: Text(
            '$selectedMood',
            key: ValueKey('num_$selectedMood'),
            style: AppTheme.displaySerif(
              size: 56,
              color: selectedColor,
              letterSpacing: -2,
            ),
          ),
        ),

        // ── Label ─────────────────────────────────────────────
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 150),
          child: Text(
            label,
            key: ValueKey('label_$selectedMood'),
            style: GoogleFonts.inter(
              color: AppTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.2,
            ),
          ),
        ),

        const SizedBox(height: 28),

        // ── Gradient slider ───────────────────────────────────
        _GradientSlider(
          selectedMood: selectedMood,
          onChanged: onMoodSelected,
        ),

        const SizedBox(height: 20),

        // ── Motivational line ─────────────────────────────────
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Padding(
            key: ValueKey('m_$selectedMood'),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              motivation,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: AppTheme.textSecondary,
                fontSize: 14,
                height: 1.5,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Gradient slider — drag or tap to pick a mood.
// ─────────────────────────────────────────────────────────────
class _GradientSlider extends StatelessWidget {
  final int selectedMood;
  final ValueChanged<int> onChanged;

  const _GradientSlider({required this.selectedMood, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final width = c.maxWidth;
        final segment = width / 10;
        final thumbX = segment * (selectedMood - 1) + segment / 2;

        void handleDrag(Offset local) {
          final dx = local.dx.clamp(0, width - 0.1);
          final mood = (dx / segment).floor() + 1;
          final clamped = mood.clamp(1, 10);
          if (clamped != selectedMood) onChanged(clamped);
        }

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (d) => handleDrag(d.localPosition),
          onHorizontalDragUpdate: (d) => handleDrag(d.localPosition),
          child: SizedBox(
            height: 56,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Track
                Container(
                  height: 14,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(99),
                    gradient: LinearGradient(colors: AppTheme.moodGradient),
                    border: Border.all(color: AppTheme.outlineVariant, width: 1),
                  ),
                ),
                // Tick marks
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(10, (i) {
                    final mood = i + 1;
                    final active = mood == selectedMood;
                    return SizedBox(
                      width: segment,
                      child: Center(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 160),
                          width: 3,
                          height: active ? 0 : 3,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.35),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                // Thumb
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  left: thumbX - 18,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.moodColor(selectedMood),
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.moodColor(selectedMood)
                              .withValues(alpha: 0.5),
                          blurRadius: 16,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
