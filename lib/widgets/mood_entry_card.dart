// TODO: mood entry card — summary card for recent entries list | Author: Rajat Mahajan

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/mood_entry_model.dart';
import '../config/theme.dart';

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
    final moodColor = moodColors[entry.moodScore] ?? AppTheme.teal;
    final dateLabel = DateFormat('EEE, d MMM').format(entry.createdAt);

    // TODO: Implement full expandable card with details
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: moodColor,
          child: Text(
            '${entry.moodScore}',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          dateLabel,
          style: const TextStyle(color: AppTheme.textPrimary),
        ),
        subtitle: Text(
          entry.emotionTags.isEmpty ? 'No emotions tagged' : entry.emotionTags.join(', '),
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
        ),
        trailing: const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
      ),
    );
  }
}
