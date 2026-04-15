// Screen: App Entry Point | Author: Rajat Mahajan | Date: 11 Apr 2026
// Updated: Piyush Puri | Date: 15 Apr 2026 — wired EmotracBottomNavBar

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'config/routes.dart';
import 'config/theme.dart';
import 'providers/auth_provider.dart';
import 'providers/insights_provider.dart';
import 'providers/mood_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/calendar_screen.dart';
import 'screens/home_screen.dart';
import 'screens/insights_screen.dart';
import 'screens/settings_screen.dart';
import 'services/database_service.dart';
import 'services/notification_service.dart';
import 'widgets/bottom_nav_bar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseService().init();
  await NotificationService().init();
  runApp(const EmotracApp());
}

class EmotracApp extends StatelessWidget {
  const EmotracApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MoodProvider()),
        ChangeNotifierProvider(create: (_) => InsightsProvider()),
        ChangeNotifierProvider(
          // loadSettings() fires async in background — UI shows defaults
          // then rebuilds automatically when settings are loaded from DB.
          create: (_) => SettingsProvider()..loadSettings(),
        ),
      ],
      child: MaterialApp(
        title: 'EMOTRACE',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const MainNavigation(),
        routes: AppRoutes.routes,
      ),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    CalendarScreen(),
    InsightsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: EmotracBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
