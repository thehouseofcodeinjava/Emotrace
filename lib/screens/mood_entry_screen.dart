// Screen: MoodEntryScreen | Author: Rajat Mahajan | Date: 11 Apr 2026
// TODO: mood entry — mood scale + emotion tags + notes | Author: Rajat Mahajan

import 'package:flutter/material.dart';

import '../config/theme.dart';
import '../config/constants.dart';

class MoodEntryScreen extends StatefulWidget {
  const MoodEntryScreen({super.key});

  @override
  State<MoodEntryScreen> createState() => _MoodEntryScreenState();
}

class _MoodEntryScreenState extends State<MoodEntryScreen> {
  int _selectedMood = 5;
  final List<String> _selectedEmotions = [];
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Mood'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // TODO: Replace with MoodScaleWidget (Week 3)
            Text(
              'Mood Entry Screen',
              style: const TextStyle(color: AppTheme.textPrimary, fontSize: 22),
            ),
            const SizedBox(height: 16),
            Text(
              'Selected: $_selectedMood/10',
              style: const TextStyle(color: AppTheme.teal, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              AppConstants.moodEmojis[_selectedMood] ?? '',
              style: const TextStyle(fontSize: 48),
            ),
            const SizedBox(height: 8),
            Text(
              AppConstants.moodLabels[_selectedMood] ?? '',
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
