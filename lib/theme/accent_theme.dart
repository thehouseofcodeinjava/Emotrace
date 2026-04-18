import 'package:flutter/material.dart';

enum AccentTheme { gold, rose, sage, sky, lavender }

class AccentColors {
  final Color accent;
  final Color accentSoft;
  final Color accentDim;
  final Color line;
  final Color glow;

  const AccentColors({
    required this.accent,
    required this.accentSoft,
    required this.accentDim,
    required this.line,
    required this.glow,
  });

  static const gold = AccentColors(
    accent: Color(0xFFD4A04A),
    accentSoft: Color(0xFFE9C98A),
    accentDim: Color(0xFF8A6D35),
    line: Color(0x24D4A04A),
    glow: Color(0x40D4A04A),
  );

  static const rose = AccentColors(
    accent: Color(0xFFD98AA8),
    accentSoft: Color(0xFFEFB6CE),
    accentDim: Color(0xFF8F5871),
    line: Color(0x29D98AA8),
    glow: Color(0x4DD98AA8),
  );

  static const sage = AccentColors(
    accent: Color(0xFFA3C4A0),
    accentSoft: Color(0xFFC8DCC6),
    accentDim: Color(0xFF5F7D5C),
    line: Color(0x29A3C4A0),
    glow: Color(0x47A3C4A0),
  );

  static const sky = AccentColors(
    accent: Color(0xFF8FB8D9),
    accentSoft: Color(0xFFB8D1E6),
    accentDim: Color(0xFF547490),
    line: Color(0x298FB8D9),
    glow: Color(0x478FB8D9),
  );

  static const lavender = AccentColors(
    accent: Color(0xFFB8A4D4),
    accentSoft: Color(0xFFD1C2E5),
    accentDim: Color(0xFF746289),
    line: Color(0x29B8A4D4),
    glow: Color(0x47B8A4D4),
  );

  static AccentColors fromEnum(AccentTheme t) {
    switch (t) {
      case AccentTheme.gold: return gold;
      case AccentTheme.rose: return rose;
      case AccentTheme.sage: return sage;
      case AccentTheme.sky: return sky;
      case AccentTheme.lavender: return lavender;
    }
  }

  static String displayName(AccentTheme t) {
    switch (t) {
      case AccentTheme.gold: return 'Gold';
      case AccentTheme.rose: return 'Rose';
      case AccentTheme.sage: return 'Sage';
      case AccentTheme.sky: return 'Sky';
      case AccentTheme.lavender: return 'Lavender';
    }
  }
}
