// Screen: MoodEntryScreen | Author: Rajat Mahajan | Date: 11 Apr 2026
// BMS redesign: Rajat Mahajan | Date: 15 Apr 2026
// BookMyShow movie-detail style — poster header, rating display, red book button

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/constants.dart';
import '../config/theme.dart';
import '../providers/mood_provider.dart';
import '../widgets/emotion_tag_selector.dart';
import '../widgets/mood_scale_widget.dart';

// ─── BMS palette ──────────────────────────────────────────────────────────────
const Color _kBg        = Color(0xFF0A0A0A);
const Color _kSurface   = Color(0xFF1A1A1A);
const Color _kSurfaceHi = Color(0xFF252525);
const Color _kRed       = Color(0xFFE31E24);
const Color _kRedDark   = Color(0xFFC1121F);
const Color _kText      = Color(0xFFFFFFFF);
const Color _kTextSec   = Color(0xFF9E9E9E);
const Color _kBorder    = Color(0xFF2E2E2E);

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
            content: Text('Mood entry saved!'),
            backgroundColor: _kRed,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.pop(context);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to save. Please try again.'),
            backgroundColor: Colors.red.shade900,
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
    final moodColor = AppTheme.moodColorForScore(_selectedMood);
    final label = AppConstants.moodLabels[_selectedMood] ?? '';

    return Scaffold(
      backgroundColor: _kBg,
      body: Column(
        children: [
          // ── Poster header (like BMS movie detail top) ─────────────
          _PosterHeader(
            moodScore: _selectedMood,
            moodLabel: label,
            moodColor: moodColor,
          ),
          // ── Scrollable body ──────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Mood scale
                  _SectionLabel(text: 'SELECT YOUR MOOD'),
                  const SizedBox(height: 12),
                  MoodScaleWidget(
                    selectedMood: _selectedMood,
                    onMoodSelected: (mood) =>
                        setState(() => _selectedMood = mood),
                  ),
                  const SizedBox(height: 28),

                  // Emotion chips — like genre tags in BMS
                  _SectionLabel(text: 'TAG YOUR EMOTIONS'),
                  const SizedBox(height: 12),
                  EmotionTagSelector(
                    selectedEmotions: _selectedEmotions,
                    onChanged: (e) => setState(() => _selectedEmotions = e),
                  ),
                  const SizedBox(height: 28),

                  // Notes — like "Write a Review" on BMS
                  _SectionLabel(text: 'WRITE A REFLECTION'),
                  const SizedBox(height: 12),
                  _ReflectionsField(controller: _notesController),
                  const SizedBox(height: 32),

                  // Save button — BMS "Book Tickets" style
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: GestureDetector(
                      onTap: _isSaving ? null : _save,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          gradient: _isSaving
                              ? null
                              : const LinearGradient(
                                  colors: [_kRed, _kRedDark]),
                          color: _isSaving ? _kSurfaceHi : null,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: _isSaving
                              ? null
                              : const [
                                  BoxShadow(
                                    color: Color(0x55E31E24),
                                    blurRadius: 16,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                        ),
                        child: Center(
                          child: _isSaving
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: _kText,
                                  ),
                                )
                              : const Text(
                                  'SAVE ENTRY',
                                  style: TextStyle(
                                    color: _kText,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                    letterSpacing: 1,
                                  ),
                                ),
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
    );
  }
}

// ─── Poster header ────────────────────────────────────────────────────────────

class _PosterHeader extends StatelessWidget {
  final int moodScore;
  final String moodLabel;
  final Color moodColor;

  const _PosterHeader({
    required this.moodScore,
    required this.moodLabel,
    required this.moodColor,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            moodColor.withValues(alpha: 0.7),
            _kBg,
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // Close button
            Positioned(
              top: 4,
              left: 8,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.close, color: _kText, size: 18),
                ),
              ),
            ),
            // Center content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  // Big score — like BMS movie rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '$moodScore',
                        style: const TextStyle(
                          color: _kText,
                          fontSize: 72,
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: const Text(
                          '/10',
                          style: TextStyle(
                            color: _kTextSec,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: _kRed,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      moodLabel.toUpperCase(),
                      style: const TextStyle(
                        color: _kText,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Section label ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
          color: _kTextSec,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
        ),
      );
}

// ─── Reflections textarea ─────────────────────────────────────────────────────

class _ReflectionsField extends StatelessWidget {
  final TextEditingController controller;
  const _ReflectionsField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: 5,
      maxLength: AppConstants.maxNotesLength,
      style: const TextStyle(color: _kText, fontSize: 14),
      decoration: InputDecoration(
        hintText: 'How was your day? Capture the feeling...',
        hintStyle: const TextStyle(color: _kTextSec, fontSize: 14),
        filled: true,
        fillColor: _kSurface,
        counterStyle: const TextStyle(color: _kTextSec, fontSize: 11),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _kBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _kBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _kRed, width: 1.5),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }
}
