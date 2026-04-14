// Screen: MoodEntryScreen | Author: Rajat Mahajan | Date: 11 Apr 2026
// Full impl: Piyush Puri | Date: 13 Apr 2026
// Redesign: Session 7 (13 Apr 2026) — Fraunces header, microLabel sections, premium save CTA
// Mood entry flow — scale selector + emotion tags + notes + save

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../config/theme.dart';
import '../config/constants.dart';
import '../providers/mood_provider.dart';
import '../widgets/emotion_tag_selector.dart';
import '../widgets/mood_scale_widget.dart';

class MoodEntryScreen extends StatefulWidget {
  const MoodEntryScreen({super.key});

  @override
  State<MoodEntryScreen> createState() => _MoodEntryScreenState();
}

class _MoodEntryScreenState extends State<MoodEntryScreen> {
  int _selectedMood = 5;
  List<String> _selectedEmotions = [];
  final TextEditingController _notesController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      await context.read<MoodProvider>().addMoodEntry(
            _selectedMood,
            _selectedEmotions,
            _notesController.text.trim(),
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Mood saved!'),
            backgroundColor: AppTheme.teal,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
        Navigator.pop(context);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save. Please try again.'),
            backgroundColor: AppTheme.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Mood'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Section header ──────────────────────────────
              Text(
                'How are you\nfeeling?',
                style: AppTheme.displaySerif(
                  size: 30,
                  weight: FontWeight.w500,
                  letterSpacing: -0.5,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Be honest — this is just for you.',
                style: GoogleFonts.inter(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 28),

              // ── Mood Scale ──────────────────────────────────
              MoodScaleWidget(
                selectedMood: _selectedMood,
                onMoodSelected: (mood) => setState(() => _selectedMood = mood),
              ),

              const SizedBox(height: 32),

              // ── Emotion tags ────────────────────────────────
              Text('DESCRIBE IT', style: AppTheme.microLabel()),
              const SizedBox(height: 4),
              Text(
                'Pick up to 5 emotions',
                style: GoogleFonts.inter(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 12),
              EmotionTagSelector(
                selectedEmotions: _selectedEmotions,
                onChanged: (emotions) =>
                    setState(() => _selectedEmotions = emotions),
              ),

              const SizedBox(height: 28),

              // ── Notes ───────────────────────────────────────
              Text('NOTES', style: AppTheme.microLabel()),
              const SizedBox(height: 12),
              TextField(
                controller: _notesController,
                maxLines: 4,
                maxLength: AppConstants.maxNotesLength,
                style: GoogleFonts.inter(
                  color: AppTheme.textPrimary,
                  fontSize: 14,
                  height: 1.5,
                ),
                decoration: InputDecoration(
                  hintText: 'What\'s on your mind? (optional)',
                  hintStyle: GoogleFonts.inter(
                    color: AppTheme.textTertiary,
                    fontSize: 14,
                  ),
                  filled: true,
                  fillColor: AppTheme.cardBackground,
                  counterStyle: GoogleFonts.inter(
                    color: AppTheme.textTertiary,
                    fontSize: 11,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    borderSide: BorderSide(color: AppTheme.outlineVariant),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    borderSide: BorderSide(color: AppTheme.outlineVariant),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    borderSide: const BorderSide(
                      color: AppTheme.tealLight,
                      width: 1.5,
                    ),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),

              const SizedBox(height: 32),

              // ── Save button ─────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF003827),
                          ),
                        )
                      : Text(
                          'Save Mood',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
