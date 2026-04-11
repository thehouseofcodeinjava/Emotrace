// Screen: HomeScreen | Author: Rajat Mahajan | Date: 11 Apr 2026
// TODO: home dashboard | Author: Rajat Mahajan

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/mood_provider.dart';
import '../config/theme.dart';
import '../config/constants.dart';
import 'mood_entry_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load entries when screen first appears
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MoodProvider>().loadEntries();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
      ),
      body: Consumer<MoodProvider>(
        builder: (context, moodProvider, _) {
          if (moodProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // TODO: Replace with full Home Dashboard (Week 2)
                const Text(
                  'Home Dashboard',
                  style: TextStyle(color: AppTheme.textPrimary, fontSize: 22),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MoodEntryScreen()),
                    );
                  },
                  child: const Text('+ Log Mood'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
