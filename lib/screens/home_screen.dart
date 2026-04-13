// Screen: HomeScreen | Author: Rajat Mahajan | Date: 11 Apr 2026
// Full impl: Piyush Puri | Date: 13 Apr 2026
// Redesign: Session 7 (13 Apr 2026) — Fraunces greeting, serif score, microLabel sections
// Dashboard — greeting, today's mood card, streak counter, recent entries, FAB

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../config/constants.dart';
import '../config/routes.dart';
import '../config/theme.dart';
import '../models/mood_entry_model.dart';
import '../providers/mood_provider.dart';
import '../widgets/mood_entry_card.dart';
import '../widgets/streak_counter.dart';

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
    Navigator.pushNamed(context, AppRoutes.moodEntry)
        .then((_) => context.read<MoodProvider>().loadEntries());
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
    return SliverAppBar(
      floating: true,
      snap: true,
      backgroundColor: AppTheme.background,
      title: Text(
        AppConstants.appName,
        style: AppTheme.displaySerif(
          size: 22,
          color: AppTheme.tealLight,
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
          style: AppTheme.displaySerif(
            size: 32,
            weight: FontWeight.w500,
            letterSpacing: -0.5,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          dateStr,
          style: GoogleFonts.inter(
            color: AppTheme.textSecondary,
            fontSize: 14,
          ),
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
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: Border.all(
            color: AppTheme.tealLight.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            const Text('😶', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text(
              'Nothing logged yet today',
              style: GoogleFonts.inter(
                color: AppTheme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Takes 30 seconds — how are you feeling?',
              style: GoogleFonts.inter(
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
    final moodColor = AppTheme.moodColor(entry.moodScore);
    final emoji = AppConstants.moodEmojis[entry.moodScore] ?? '';
    final label = AppConstants.moodLabels[entry.moodScore] ?? '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(
          color: moodColor.withValues(alpha: 0.3),
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
                Text('TODAY', style: AppTheme.microLabel()),
                const SizedBox(height: 4),
                Text(
                  '${entry.moodScore}/10',
                  style: AppTheme.displaySerif(
                    size: 32,
                    color: moodColor,
                    letterSpacing: -1,
                  ),
                ),
                Text(
                  label,
                  style: GoogleFonts.inter(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (entry.emotionTags.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    entry.emotionTags.join(' · '),
                    style: GoogleFonts.inter(
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
        Text('RECENT ENTRIES', style: AppTheme.microLabel()),
        const SizedBox(height: 10),
        if (entries.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 28),
            decoration: BoxDecoration(
              color: AppTheme.cardBackground,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              border: Border.all(color: AppTheme.outlineVariant),
            ),
            child: Column(
              children: [
                const Text('📋', style: TextStyle(fontSize: 28)),
                const SizedBox(height: 8),
                Text(
                  'Your story starts with the first entry.',
                  style: GoogleFonts.inter(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                  ),
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
