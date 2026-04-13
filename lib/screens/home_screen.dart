// Screen: HomeScreen | Author: Rajat Mahajan | Date: 11 Apr 2026
// Full impl: Piyush Puri | Date: 13 Apr 2026
// Dashboard — greeting, today's mood card, streak counter, recent entries, FAB

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../config/constants.dart';
import '../config/theme.dart';
import '../models/mood_entry_model.dart';
import '../providers/mood_provider.dart';
import '../widgets/mood_entry_card.dart';
import '../widgets/streak_counter.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MoodProvider>().loadEntries();
    });
  }

  Future<void> _refresh(MoodProvider provider) => provider.loadEntries();

  void _goToMoodEntry() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MoodEntryScreen()),
    ).then((_) => context.read<MoodProvider>().loadEntries());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<MoodProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.entries.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            color: AppTheme.teal,
            onRefresh: () => _refresh(provider),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                _buildAppBar(),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const SizedBox(height: 8),
                      _GreetingSection(),
                      const SizedBox(height: 20),
                      _TodayMoodCard(
                        entry: provider.todaysMood,
                        onTap: _goToMoodEntry,
                      ),
                      const SizedBox(height: 16),
                      StreakCounter(
                        currentStreak: provider.currentStreak,
                        longestStreak: provider.longestStreak,
                      ),
                      const SizedBox(height: 24),
                      _RecentEntriesSection(entries: provider.recentEntries),
                      if (provider.error != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text(
                            provider.error!,
                            style: const TextStyle(color: AppTheme.red, fontSize: 13),
                          ),
                        ),
                    ]),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _goToMoodEntry,
        backgroundColor: AppTheme.teal,
        foregroundColor: const Color(0xFF003827),
        icon: const Icon(Icons.add),
        label: const Text(
          'Log Mood',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  SliverAppBar _buildAppBar() {
    return const SliverAppBar(
      floating: true,
      snap: true,
      backgroundColor: AppTheme.background,
      title: Text(
        AppConstants.appName,
        style: TextStyle(
          color: AppTheme.teal,
          fontSize: 22,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.5,
        ),
      ),
      centerTitle: false,
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Greeting section
// ─────────────────────────────────────────────────────────────
class _GreetingSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final greeting = _timeGreeting(now.hour);
    final dateStr = DateFormat('EEEE, d MMMM').format(now);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 28,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          dateStr,
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
        ),
      ],
    );
  }

  String _timeGreeting(int hour) {
    if (hour < 12) return 'Good morning.';
    if (hour < 17) return 'Good afternoon.';
    return 'Good evening.';
  }
}

// ─────────────────────────────────────────────────────────────
// Today's mood card
// ─────────────────────────────────────────────────────────────
class _TodayMoodCard extends StatelessWidget {
  final MoodEntry? entry;
  final VoidCallback onTap;

  const _TodayMoodCard({required this.entry, required this.onTap});

  @override
  Widget build(BuildContext context) {
    if (entry == null) {
      return _EmptyMoodCard(onTap: onTap);
    }
    return _FilledMoodCard(entry: entry!);
  }
}

class _EmptyMoodCard extends StatelessWidget {
  final VoidCallback onTap;
  const _EmptyMoodCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.teal.withValues(alpha: 0.25),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            const Text('😶', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            const Text(
              'No mood logged today',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Tap to check in — takes 30 seconds',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilledMoodCard extends StatelessWidget {
  final MoodEntry entry;
  const _FilledMoodCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final moodColor = moodColors[entry.moodScore] ?? AppTheme.teal;
    final emoji = AppConstants.moodEmojis[entry.moodScore] ?? '';
    final label = AppConstants.moodLabels[entry.moodScore] ?? '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: moodColor.withValues(alpha: 0.35),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 52)),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'TODAY',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${entry.moodScore}/10',
                  style: TextStyle(
                    color: moodColor,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (entry.emotionTags.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    entry.emotionTags.join(' · '),
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Recent entries section
// ─────────────────────────────────────────────────────────────
class _RecentEntriesSection extends StatelessWidget {
  final List<MoodEntry> entries;
  const _RecentEntriesSection({required this.entries});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'RECENT ENTRIES',
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 10),
        if (entries.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 28),
            decoration: BoxDecoration(
              color: AppTheme.cardBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(
              children: [
                Text('📋', style: TextStyle(fontSize: 28)),
                SizedBox(height: 8),
                Text(
                  'No entries yet — start logging!',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                ),
              ],
            ),
          )
        else
          ...entries.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: MoodEntryCard(entry: e),
            ),
          ),
      ],
    );
  }
}
