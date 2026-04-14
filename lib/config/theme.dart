// Config: AppTheme | Author: Rajat Mahajan | Date: 11 Apr 2026
// NOTE: Recreated by Piyush Puri (11 Apr 2026) — original was missing from Rajat's commit.
// Cross-dependency resolved: see HIGHLIGHT.md CROSS-DEPENDENCY FLAGS.

import 'package:flutter/material.dart';

// Top-level mood color map — used directly by MoodEntryCard and AppColorUtils
const Map<int, Color> moodColors = {
  1: Color(0xFFE63946),  // deep red
  2: Color(0xFFFF4560),  // orange-red
  3: Color(0xFFFF7043),  // deep orange
  4: Color(0xFFFF9800),  // orange
  5: Color(0xFFFFC107),  // amber
  6: Color(0xFF8BC34A),  // light green
  7: Color(0xFF47F3BB),  // teal-green
  8: Color(0xFF27E0A9),  // medium teal
  9: Color(0xFF06D6A0),  // teal
  10: Color(0xFF00BFA5), // dark teal
};

class AppTheme {
  // ---- Brand colours ----
  static const Color teal       = Color(0xFF06D6A0);
  static const Color tealLight  = Color(0xFF47F3BB);
  static const Color orange     = Color(0xFFF77F00);
  static const Color red        = Color(0xFFE63946);

  // ---- Surface / background ----
  static const Color background       = Color(0xFF131313);
  static const Color surface          = Color(0xFF131313);
  static const Color cardBackground   = Color(0xFF1C1B1B);  // surface-container-low
  static const Color cardHigh         = Color(0xFF2A2A2A);  // surface-container-high
  static const Color surfaceVariant   = Color(0xFF353534);  // surface-container-highest
  static const Color surfaceContainer = Color(0xFF201F1F);  // surface-container

  // ---- Text ----
  static const Color textPrimary   = Color(0xFFE5E2E1);  // on-surface
  static const Color textSecondary = Color(0xFFBACAC1);  // on-surface-variant

  // ---- Outline ----
  static const Color outlineVariant = Color(0xFF3B4A43);

  // ---- Material Dark Theme ----
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: background,
    primaryColor: teal,
    colorScheme: const ColorScheme.dark(
      primary: tealLight,
      onPrimary: Color(0xFF003827),
      primaryContainer: teal,
      onPrimaryContainer: Color(0xFF00573F),
      secondary: Color(0xFFFFB784),
      onSecondary: Color(0xFF502500),
      secondaryContainer: Color(0xFFF47D00),
      surface: surface,
      onSurface: textPrimary,
      onSurfaceVariant: textSecondary,
      outline: Color(0xFF85948C),
      outlineVariant: outlineVariant,
      error: Color(0xFFFFB4AB),
      onError: Color(0xFF690005),
    ),
    cardTheme: const CardThemeData(
      color: cardBackground,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: background,
      foregroundColor: textPrimary,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: teal,
        fontSize: 22,
        fontWeight: FontWeight.w900,
        letterSpacing: -0.5,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: teal,
        foregroundColor: Color(0xFF003827),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xB3131313),
      selectedItemColor: tealLight,
      unselectedItemColor: textSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    chipTheme: const ChipThemeData(
      backgroundColor: surfaceContainer,
      selectedColor: teal,
      labelStyle: TextStyle(color: textPrimary, fontSize: 12),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: textPrimary,
        fontSize: 48,
        fontWeight: FontWeight.w900,
        letterSpacing: -1.5,
      ),
      headlineMedium: TextStyle(
        color: textPrimary,
        fontSize: 32,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
      ),
      titleLarge: TextStyle(
        color: textPrimary,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
      titleMedium: TextStyle(
        color: textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      bodyMedium: TextStyle(color: textPrimary, fontSize: 14),
      bodySmall: TextStyle(color: textSecondary, fontSize: 12),
      labelSmall: TextStyle(
        color: textSecondary,
        fontSize: 10,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      ),
    ),
  );
}
