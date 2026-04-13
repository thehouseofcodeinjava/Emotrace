// Widget: EmotracBottomNavBar | Author: Rajat Mahajan | Date: 11 Apr 2026
// Redesign: Session 7 (13 Apr 2026) — custom pill-indicator bar, intentional not stock.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../config/theme.dart';

class EmotracBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const EmotracBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const _items = [
    (Icons.home_outlined, Icons.home_rounded, 'Home'),
    (Icons.calendar_month_outlined, Icons.calendar_month_rounded, 'Calendar'),
    (Icons.insights_outlined, Icons.insights_rounded, 'Patterns'),
    (Icons.settings_outlined, Icons.settings_rounded, 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 16),
      decoration: BoxDecoration(
        color: AppTheme.background.withValues(alpha: 0.96),
        border: Border(
          top: BorderSide(color: AppTheme.outlineVariant),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(_items.length, (i) {
            final active = i == currentIndex;
            final item = _items[i];
            return Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onTap(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: active
                        ? AppTheme.tealLight.withValues(alpha: 0.12)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        active ? item.$2 : item.$1,
                        color: active ? AppTheme.tealLight : AppTheme.textTertiary,
                        size: 22,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.$3,
                        style: GoogleFonts.inter(
                          color: active ? AppTheme.tealLight : AppTheme.textTertiary,
                          fontSize: 11,
                          fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
