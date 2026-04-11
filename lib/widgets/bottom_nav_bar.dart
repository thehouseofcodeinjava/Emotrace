// TODO: bottom navigation bar widget | Author: Rajat Mahajan
// Note: Navigation is currently handled in main.dart MainNavigation
// This widget is reserved for custom bottom nav bar with mood entry FAB

import 'package:flutter/material.dart';

import '../config/theme.dart';

class EmotracBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const EmotracBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // TODO: Implement custom bottom nav with centered FAB for mood entry
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_month_outlined), label: 'Calendar'),
        BottomNavigationBarItem(icon: Icon(Icons.bar_chart_outlined), label: 'Insights'),
        BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: 'Settings'),
      ],
    );
  }
}
