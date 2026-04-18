// Widget: EmotracBottomNavBar | Author: Piyush Puri | Date: 15 Apr 2026
// Sanctuary frosted glass nav bar — accent gradient active pill, 4 tabs

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../theme/theme_provider.dart';

class EmotracBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const EmotracBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const _tabs = [
    _NavTab(label: 'HOME',     icon: Icons.home_outlined,           activeIcon: Icons.home),
    _NavTab(label: 'CALENDAR', icon: Icons.calendar_month_outlined, activeIcon: Icons.calendar_month),
    _NavTab(label: 'INSIGHTS', icon: Icons.analytics_outlined,      activeIcon: Icons.analytics),
    _NavTab(label: 'SETTINGS', icon: Icons.settings_outlined,       activeIcon: Icons.settings),
  ];

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final colors = context.watch<ThemeProvider>().colors;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0b1513).withValues(alpha: 0.85),
            boxShadow: const [
              BoxShadow(
                offset: Offset(0, -20),
                blurRadius: 40,
                color: Color(0x660b1513),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + bottomPadding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_tabs.length, (i) {
                final isActive = i == currentIndex;
                return GestureDetector(
                  onTap: () => onTap(i),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.symmetric(
                      horizontal: isActive ? 20 : 12,
                      vertical: 8,
                    ),
                    decoration: isActive
                        ? BoxDecoration(
                            gradient: LinearGradient(
                              colors: [colors.accent, colors.accentDim],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          )
                        : null,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isActive ? _tabs[i].activeIcon : _tabs[i].icon,
                          size: 20,
                          color: isActive
                              ? AppTheme.onPrimary
                              : colors.accentDim.withValues(alpha: 0.6),
                        ),
                        if (isActive) ...[
                          const SizedBox(width: 6),
                          Text(
                            _tabs[i].label,
                            style: const TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.onPrimary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavTab {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  const _NavTab({required this.label, required this.icon, required this.activeIcon});
}
