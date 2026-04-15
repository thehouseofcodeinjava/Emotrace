// Config: AppTheme | Author: Piyush Puri | Date: 15 Apr 2026
// Sanctuary editorial dark theme — deep forest green + gold palette
// Legacy aliases kept so unrewritten files continue to compile during migration.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─── Mood color map — 5-band scale (1-10) ────────────────────────────────────
const Map<int, Color> moodColors = {
  1: Color(0xFF93000a),
  2: Color(0xFF93000a),
  3: Color(0xFFc5a059),
  4: Color(0xFFc5a059),
  5: Color(0xFFb5ccc1),
  6: Color(0xFFb5ccc1),
  7: Color(0xFF394d45),
  8: Color(0xFF394d45),
  9: Color(0xFF21342d),
  10: Color(0xFF21342d),
};

class AppTheme {
  // ── New Sanctuary palette ─────────────────────────────────────────────────
  static const Color background              = Color(0xFF0b1513);
  static const Color surface                 = Color(0xFF0b1513);
  static const Color surfaceContainer        = Color(0xFF18221f);
  static const Color surfaceContainerLow     = Color(0xFF141e1b);
  static const Color cardBackground          = Color(0xFF141e1b);
  static const Color surfaceContainerHigh    = Color(0xFF222c29);
  static const Color cardHigh                = Color(0xFF222c29);
  static const Color surfaceContainerHighest = Color(0xFF2d3734);
  static const Color surfaceVariant          = Color(0xFF2d3734);

  static const Color primary          = Color(0xFFe9c176);
  static const Color primaryContainer = Color(0xFFc5a059);
  static const Color onPrimary        = Color(0xFF412d00);
  static const Color onPrimaryFixed   = Color(0xFF261900);

  static const Color secondary          = Color(0xFFb5ccc1);
  static const Color secondaryContainer = Color(0xFF394d45);
  static const Color onSecondary        = Color(0xFF1f3a31);

  static const Color textPrimary   = Color(0xFFdae5e0);
  static const Color textSecondary = Color(0xFFd1c5b4);

  static const Color outline        = Color(0xFF9a8f80);
  static const Color outlineVariant = Color(0xFF4e4639);

  static const Color red            = Color(0xFFffb4ab);
  static const Color errorContainer = Color(0xFF93000a);

  // ── Legacy aliases — kept so existing files compile during migration ───────
  static const Color teal      = Color(0xFF06D6A0);
  static const Color tealLight = Color(0xFF47F3BB);
  static const Color orange    = Color(0xFFF77F00);

  // ── Mood helper ───────────────────────────────────────────────────────────
  static Color moodColorForScore(int score) =>
      moodColors[score.clamp(1, 10)] ?? secondary;

  // ── Typography helpers (Newsreader + Manrope) ─────────────────────────────
  static TextStyle get displaySerif => GoogleFonts.newsreader(
        fontSize: 52, fontWeight: FontWeight.w600, color: textPrimary);

  static TextStyle get displaySerifItalic => GoogleFonts.newsreader(
        fontSize: 52,
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
        color: primary);

  static TextStyle get headlineSerif => GoogleFonts.newsreader(
        fontSize: 32, fontWeight: FontWeight.w600, color: textPrimary);

  static TextStyle get headlineSerifMedium => GoogleFonts.newsreader(
        fontSize: 24, fontWeight: FontWeight.w500, color: textPrimary);

  static TextStyle get headlineSerifItalic => GoogleFonts.newsreader(
        fontSize: 24,
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
        color: primary);

  static TextStyle get bodyMedium =>
      GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w400, color: textPrimary);

  static TextStyle get bodySmall =>
      GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.w400, color: textSecondary);

  static TextStyle get labelCaps => GoogleFonts.manrope(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: textSecondary,
        letterSpacing: 1.5);

  static TextStyle get labelMedium => GoogleFonts.manrope(
        fontSize: 11, fontWeight: FontWeight.w700, color: textPrimary);

  // ── Material ThemeData ────────────────────────────────────────────────────
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: background,
    primaryColor: primary,
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFFe9c176),
      onPrimary: Color(0xFF412d00),
      primaryContainer: Color(0xFFc5a059),
      secondary: Color(0xFFb5ccc1),
      onSecondary: Color(0xFF1f3a31),
      secondaryContainer: Color(0xFF394d45),
      surface: Color(0xFF0b1513),
      onSurface: Color(0xFFdae5e0),
      onSurfaceVariant: Color(0xFFd1c5b4),
      outline: Color(0xFF9a8f80),
      outlineVariant: Color(0xFF4e4639),
      error: Color(0xFFffb4ab),
      onError: Color(0xFF690005),
    ),
    cardTheme: const CardThemeData(
      color: Color(0xFF141e1b),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF0b1513),
      foregroundColor: Color(0xFFdae5e0),
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFe9c176),
        foregroundColor: const Color(0xFF412d00),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      ),
    ),
    chipTheme: const ChipThemeData(
      backgroundColor: Color(0xFF141e1b),
      selectedColor: Color(0xFF394d45),
      labelStyle: TextStyle(color: Color(0xFFdae5e0), fontSize: 12),
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Color(0xFFdae5e0), fontSize: 14),
      bodySmall: TextStyle(color: Color(0xFFd1c5b4), fontSize: 12),
    ),
  );
}
