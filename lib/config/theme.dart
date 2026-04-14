// Config: AppTheme | Author: Rajat Mahajan | Date: 11 Apr 2026
// Redesign: Session 7 (13 Apr 2026) — premium design system
// Layered dark surfaces + mood gradient + Inter/Fraunces typography.
// NOTE: all original static names (teal, background, cardBackground, etc.)
// are preserved so existing screens compile; values are upgraded.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─────────────────────────────────────────────────────────────
// Mood gradient — the soul of the EmoTrace brand.
// Warm muted red (1) → amber (4-5) → soft green (8) → serene teal (10).
// Used by MoodScaleWidget, CalendarHeatmap, MoodChart, score numbers.
// ─────────────────────────────────────────────────────────────
const Map<int, Color> moodColors = {
  1:  Color(0xFFD64545), // muted deep red
  2:  Color(0xFFE05C47), // warm red
  3:  Color(0xFFEB7A3C), // burnt orange
  4:  Color(0xFFF29E3A), // amber
  5:  Color(0xFFE9B949), // honey
  6:  Color(0xFFBFC74D), // olive-lime
  7:  Color(0xFF7DC481), // soft green
  8:  Color(0xFF4FB89E), // teal-green
  9:  Color(0xFF34B3A9), // ocean teal
  10: Color(0xFF2FA8B8), // serene teal-cyan
};

class AppTheme {
  // ─── Brand colors (names preserved for back-compat) ──────────
  static const Color teal       = Color(0xFF34B3A9); // serene teal
  static const Color tealLight  = Color(0xFF5FD0C4); // soft mint
  static const Color orange     = Color(0xFFE09B5B); // warm amber
  static const Color red        = Color(0xFFD64545); // muted red
  static const Color accent     = Color(0xFF8B7FD6); // soft violet — CTAs

  // ─── Surface stack (3 layers + depth) ────────────────────────
  static const Color background       = Color(0xFF0A0E14); // deepest
  static const Color surface          = Color(0xFF0A0E14);
  static const Color cardBackground   = Color(0xFF141A22); // surface-1
  static const Color surfaceContainer = Color(0xFF182028); // surface-1.5
  static const Color cardHigh         = Color(0xFF1E2630); // surface-2
  static const Color surfaceVariant   = Color(0xFF252E3A); // surface-3

  // ─── Text (opacity ladder) ───────────────────────────────────
  static const Color textPrimary   = Color(0xEBFFFFFF); // white @ 92%
  static const Color textSecondary = Color(0xA3FFFFFF); // white @ 64%
  static const Color textTertiary  = Color(0x66FFFFFF); // white @ 40%

  // ─── Outline ─────────────────────────────────────────────────
  static const Color outlineVariant = Color(0x14FFFFFF); // white @ 8%

  // ─── Spacing / radius tokens ─────────────────────────────────
  static const double radiusSm = 10;
  static const double radiusMd = 14;
  static const double radiusLg = 20;
  static const double radiusXl = 28;

  // ─── Mood gradient helpers ───────────────────────────────────
  static List<Color> get moodGradient => List.generate(10, (i) => moodColors[i + 1]!);

  static Color moodColor(int score) =>
      moodColors[score.clamp(1, 10)] ?? teal;

  // ─── Serif display helper (Fraunces) ─────────────────────────
  static TextStyle displaySerif({
    double size = 48,
    FontWeight weight = FontWeight.w600,
    Color color = textPrimary,
    double letterSpacing = -1.2,
    double height = 1.05,
  }) {
    return GoogleFonts.fraunces(
      fontSize: size,
      fontWeight: weight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  // ─── Micro label helper (Inter, all-caps tracked) ────────────
  static TextStyle microLabel({Color color = textTertiary}) {
    return GoogleFonts.inter(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      letterSpacing: 1.4,
      color: color,
    );
  }

  // ─── Material theme ──────────────────────────────────────────
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: background,
    primaryColor: teal,
    colorScheme: const ColorScheme.dark(
      primary: tealLight,
      onPrimary: Color(0xFF00322A),
      primaryContainer: teal,
      onPrimaryContainer: Color(0xFFE8FFF9),
      secondary: accent,
      onSecondary: Color(0xFF1A0E40),
      secondaryContainer: Color(0xFF5A4FA8),
      surface: surface,
      onSurface: textPrimary,
      onSurfaceVariant: textSecondary,
      outline: Color(0xFF4A5468),
      outlineVariant: outlineVariant,
      error: Color(0xFFFFB4AB),
      onError: Color(0xFF690005),
    ),
    textTheme: GoogleFonts.interTextTheme(
      const TextTheme().apply(
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ),
    ).copyWith(
      bodyMedium: GoogleFonts.inter(color: textPrimary, fontSize: 14, height: 1.5),
      bodySmall: GoogleFonts.inter(color: textSecondary, fontSize: 12, height: 1.5),
      labelSmall: GoogleFonts.inter(
        color: textTertiary,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.4,
      ),
      titleMedium: GoogleFonts.inter(
        color: textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    ),
    cardTheme: CardThemeData(
      color: cardBackground,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusLg),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: background,
      foregroundColor: textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: GoogleFonts.fraunces(
        color: textPrimary,
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: tealLight,
        foregroundColor: const Color(0xFF002A24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusXl),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        textStyle: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xF00A0E14),
      selectedItemColor: tealLight,
      unselectedItemColor: textTertiary,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: surfaceContainer,
      selectedColor: teal,
      labelStyle: GoogleFonts.inter(color: textPrimary, fontSize: 13),
      side: const BorderSide(color: outlineVariant),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusXl),
      ),
    ),
  );
}
