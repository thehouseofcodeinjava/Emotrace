// Widget: MoodEntryCard | Author: Rajat Mahajan | Date: 11 Apr 2026
// Redesign: Session 7 (13 Apr 2026) — softer card, gradient accent, serif score.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../config/constants.dart';
import '../config/theme.dart';
import '../models/mood_entry_model.dart';
import '../utils/date_utils.dart';

class MoodEntryCard extends StatelessWidget {
  final MoodEntry entry;
  final VoidCallback? onTap;

  const MoodEntryCard({
    super.key,
    required this.entry,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final moodColor = AppTheme.moodColor(entry.moodScore);
    final emoji = AppConstants.moodEmojis[entry.moodScore] ?? '';
    final label = AppConstants.moodLabels[entry.moodScore] ?? '';
    final dateLabel = AppDateUtils.relativeLabel(entry.createdAt);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.cardBackground,
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            border: Border.all(color: AppTheme.outlineVariant),
          ),
          child: Row(
            children: [
              // Gradient wash circle
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      moodColor.withValues(alpha: 0.35),
                      moodColor.withValues(alpha: 0.0),
                    ],
                  ),
                ),
                child: Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 24)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dateLabel,
                      style: GoogleFonts.inter(
                        color: AppTheme.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      entry.emotionTags.isEmpty
                          ? label
                          : entry.emotionTags.join(' · '),
                      style: GoogleFonts.inter(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                        height: 1.4,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${entry.moodScore}',
                style: AppTheme.displaySerif(
                  size: 24,
                  color: moodColor,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                '/10',
                style: GoogleFonts.inter(
                  color: AppTheme.textTertiary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
