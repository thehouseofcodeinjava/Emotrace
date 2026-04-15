// Screen: MoodEntryScreen | Author: Rajat Mahajan | Date: 11 Apr 2026
// Sanctuary redesign: Piyush Puri | Date: 15 Apr 2026
// Glow sphere + bar scale + icon grid chips + gold save button

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/constants.dart';
import '../config/theme.dart';
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
          const SnackBar(
            content: Text('Reflection saved.'),
            backgroundColor: AppTheme.primaryContainer,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.pop(context);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save. Please try again.'),
            backgroundColor: AppTheme.errorContainer,
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
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Custom header ────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.close,
                          color: AppTheme.textSecondary, size: 18),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text('How are you feeling?',
                          style: AppTheme.headlineSerifMedium),
                    ),
                  ),
                  const SizedBox(width: 36), // balance the close button
                ],
              ),
            ),
            // ── Scrollable body ──────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Mood sphere
                    _MoodSphere(moodScore: _selectedMood),
                    const SizedBox(height: 28),

                    // Bar scale
                    MoodScaleWidget(
                      selectedMood: _selectedMood,
                      onMoodSelected: (mood) =>
                          setState(() => _selectedMood = mood),
                    ),
                    const SizedBox(height: 32),

                    // Emotion chips
                    Text('REFINE YOUR STATE', style: AppTheme.labelCaps),
                    const SizedBox(height: 12),
                    EmotionTagSelector(
                      selectedEmotions: _selectedEmotions,
                      onChanged: (e) => setState(() => _selectedEmotions = e),
                    ),
                    const SizedBox(height: 28),

                    // Reflections textarea
                    _ReflectionsField(controller: _notesController),
                    const SizedBox(height: 32),

                    // Save button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: GestureDetector(
                        onTap: _isSaving ? null : _save,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: _isSaving
                                ? null
                                : const LinearGradient(
                                    colors: [Color(0xFFe9c176), Color(0xFFc5a059)]),
                            color: _isSaving ? AppTheme.surfaceContainerHigh : null,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Center(
                            child: _isSaving
                                ? const SizedBox(
                                    width: 22, height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Color(0xFF412d00),
                                    ),
                                  )
                                : Text('SAVE REFLECTION',
                                    style: AppTheme.labelCaps.copyWith(
                                        color: const Color(0xFF412d00),
                                        fontSize: 13)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Mood sphere ──────────────────────────────────────────────────────────────

class _MoodSphere extends StatelessWidget {
  final int moodScore;
  const _MoodSphere({required this.moodScore});

  @override
  Widget build(BuildContext context) {
    final label = AppConstants.moodLabels[moodScore] ?? '';

    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Ambient halo
          Container(
            width: 280, height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppTheme.primary.withValues(alpha: 0.12),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          // Sphere
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 200, height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(
                center: Alignment(-0.3, -0.3),
                colors: [
                  Color(0xFFe9c176),
                  Color(0xFFc5a059),
                  AppTheme.background,
                ],
                stops: [0.0, 0.5, 1.0],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withValues(alpha: 0.25),
                  blurRadius: 60,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$moodScore',
                  style: const TextStyle(
                    fontSize: 60, fontWeight: FontWeight.w900,
                    color: Color(0xFF261900), height: 1,
                  ),
                ),
                Text(
                  label.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10, fontWeight: FontWeight.w700,
                    color: Color(0x99261900), letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Reflections textarea ─────────────────────────────────────────────────────

class _ReflectionsField extends StatefulWidget {
  final TextEditingController controller;
  const _ReflectionsField({required this.controller});

  @override
  State<_ReflectionsField> createState() => _ReflectionsFieldState();
}

class _ReflectionsFieldState extends State<_ReflectionsField> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Focus(
          onFocusChange: (v) => setState(() => _focused = v),
          child: TextField(
            controller: widget.controller,
            maxLines: 5,
            maxLength: AppConstants.maxNotesLength,
            style: AppTheme.bodyMedium,
            decoration: InputDecoration(
              hintText: 'Capture the texture of this moment...',
              hintStyle: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textSecondary.withValues(alpha: 0.4)),
              filled: true,
              fillColor: AppTheme.surfaceContainerHighest.withValues(alpha: 0.4),
              counterStyle: AppTheme.bodySmall,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: const BorderSide(color: AppTheme.primary, width: 1),
              ),
              contentPadding: const EdgeInsets.all(20),
            ),
          ),
        ),
        // Edit icon bottom-right
        Positioned(
          right: 16, bottom: 28,
          child: AnimatedOpacity(
            opacity: _focused ? 1.0 : 0.3,
            duration: const Duration(milliseconds: 200),
            child: const Icon(Icons.edit_note, color: AppTheme.primary, size: 20),
          ),
        ),
      ],
    );
  }
}
