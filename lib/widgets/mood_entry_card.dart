// Widget: MoodEntryCard | Author: Rajat Mahajan | Date: 11 Apr 2026
// Sanctuary redesign: Piyush Puri | Date: 15 Apr 2026
// Newsreader headline, labelCaps date, mood-color square thumbnail

import 'package:flutter/material.dart';
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
    final moodColor = AppTheme.moodColorForScore(entry.moodScore);
    final label = AppConstants.moodLabels[entry.moodScore] ?? '';
    final dateLabel = AppDateUtils.relativeLabel(entry.createdAt);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.outlineVariant.withValues(alpha: 0.2),
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            // Square mood thumbnail
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: moodColor.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  '${entry.moodScore}',
                  style: AppTheme.headlineSerifMedium.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 20,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(dateLabel.toUpperCase(), style: AppTheme.labelCaps),
                  const SizedBox(height: 4),
                  Text(
                    entry.notes.isNotEmpty ? entry.notes : label,
                    style: AppTheme.headlineSerifMedium.copyWith(
                        fontSize: 15, color: AppTheme.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (entry.emotionTags.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      entry.emotionTags.join(' · '),
                      style: AppTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            // Score
            Text(
              '${entry.moodScore}/10',
              style: AppTheme.headlineSerifItalic.copyWith(
                  fontSize: 16, color: moodColor),
            ),
          ],
        ),
      ),
    );
  }
}
