// Screen: HomeScreen | Author: Rajat Mahajan | Date: 11 Apr 2026
// Sanctuary redesign: Piyush Puri | Date: 15 Apr 2026
// Editorial hero header, vibe card, Netflix mood grid, gold FAB

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../config/constants.dart';
import '../config/routes.dart';
import '../config/theme.dart';
import '../models/mood_entry_model.dart';
import '../providers/insights_provider.dart';
import '../providers/mood_provider.dart';

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

  void _goToMoodEntry() {
    final moodProvider = context.read<MoodProvider>();
    final insightsProvider = context.read<InsightsProvider>();
    Navigator.pushNamed(context, AppRoutes.moodEntry).then((_) async {
      await moodProvider.loadEntries();
      insightsProvider.calculateInsights();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      floatingActionButton: FloatingActionButton(
        onPressed: _goToMoodEntry,
        backgroundColor: const Color(0xFFe9c176),
        elevation: 2.0,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Color(0xFF412d00), size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Consumer<MoodProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.entries.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            );
          }

          return RefreshIndicator(
            color: AppTheme.primary,
            onRefresh: provider.loadEntries,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                _buildAppBar(),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const SizedBox(height: 8),
                      _HeroHeader(
                        currentStreak: provider.currentStreak,
                      ),
                      const SizedBox(height: 24),
                      _VibeCardSection(
                        todaysMood: provider.todaysMood,
                        dailyAverage: provider.dailyAverage,
                        onCheckIn: _goToMoodEntry,
                      ),
                      const SizedBox(height: 28),
                      _TodaysMoodGrid(entries: provider.todaysMoods),
                    ]),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      floating: true,
      snap: true,
      backgroundColor: AppTheme.background,
      leading: Padding(
        padding: const EdgeInsets.all(10),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceContainerHighest,
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.outlineVariant, width: 1),
          ),
          child: const Icon(Icons.person_outline,
              color: AppTheme.textSecondary, size: 20),
        ),
      ),
      title: Text(
        'EMOTRACE',
        style: AppTheme.headlineSerifItalic.copyWith(fontSize: 22),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none, color: AppTheme.primary),
          onPressed: () {},
        ),
      ],
    );
  }
}

// ─── Hero header ─────────────────────────────────────────────────────────────

class _HeroHeader extends StatelessWidget {
  final int currentStreak;
  const _HeroHeader({required this.currentStreak});

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final greeting = hour < 6 ? 'Good night,' : hour < 12 ? 'Good morning,' : hour < 18 ? 'Good afternoon,' : 'Good evening,';
    final date = DateFormat('EEEE, d MMMM').format(DateTime.now());

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(greeting, style: AppTheme.headlineSerif),
              Text('You', style: AppTheme.displaySerifItalic.copyWith(fontSize: 36)),
              const SizedBox(height: 6),
              Text(date, style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary)),
            ],
          ),
        ),
        const SizedBox(width: 16),
        // Streak card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.local_fire_department,
                      color: AppTheme.primary, size: 24),
                  const SizedBox(width: 6),
                  Text(
                    '$currentStreak',
                    style: AppTheme.headlineSerifMedium.copyWith(
                        fontSize: 22, fontWeight: FontWeight.w900, color: AppTheme.primary),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text('DAY STREAK', style: AppTheme.labelCaps),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Vibe card section (full-width) ──────────────────────────────────────────

class _VibeCardSection extends StatelessWidget {
  final MoodEntry? todaysMood;
  final double dailyAverage;
  final VoidCallback onCheckIn;

  const _VibeCardSection({
    required this.todaysMood,
    required this.dailyAverage,
    required this.onCheckIn,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 280,
      child: _VibeCard(
          entry: todaysMood, dailyAverage: dailyAverage, onCheckIn: onCheckIn),
    );
  }
}

class _VibeCard extends StatelessWidget {
  final MoodEntry? entry;
  final double dailyAverage;
  final VoidCallback onCheckIn;
  const _VibeCard(
      {required this.entry,
      required this.dailyAverage,
      required this.onCheckIn});

  @override
  Widget build(BuildContext context) {
    final moodColor = entry != null
        ? AppTheme.moodColorForScore(entry!.moodScore)
        : AppTheme.secondaryContainer;
    final label = entry != null
        ? (AppConstants.moodLabels[entry!.moodScore] ?? '')
        : 'Not logged';
    final score = entry?.moodScore;
    final avgText = dailyAverage > 0
        ? 'Avg: ${dailyAverage.toStringAsFixed(2)}/10'
        : null;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Container(
      decoration: const BoxDecoration(
        color: AppTheme.surfaceContainerLow,
      ),
      child: Stack(
        children: [
          // Forest background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/forest.png',
              fit: BoxFit.cover,
            ),
          ),
          // Mood-tinted + dark gradient overlay
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    moodColor.withValues(alpha: 0.25),
                    AppTheme.background.withValues(alpha: 0.88),
                  ],
                  stops: const [0.0, 0.65],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Pill badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceContainer.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6, height: 6,
                        decoration: const BoxDecoration(
                          color: AppTheme.primary, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 6),
                      Text('CURRENT RESONANCE',
                          style: AppTheme.labelCaps.copyWith(color: AppTheme.primary)),
                    ],
                  ),
                ),
                const Spacer(),
                // Score
                if (score != null)
                  Text('$score', style: AppTheme.displaySerif.copyWith(
                      fontSize: 64, color: AppTheme.primary, height: 1)),
                Text(
                  score != null ? '$label · $score/10' : 'Tap to check in',
                  style: AppTheme.headlineSerifMedium.copyWith(
                      color: AppTheme.textPrimary, fontSize: 18),
                ),
                if (avgText != null) ...[
                  const SizedBox(height: 4),
                  Text(avgText,
                      style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.primary)),
                ],
                const SizedBox(height: 16),
                // Check in button
                GestureDetector(
                  onTap: onCheckIn,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [Color(0xFFe9c176), Color(0xFFc5a059)]),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.edit_note, color: Color(0xFF412d00), size: 18),
                        const SizedBox(width: 6),
                        Text('Check In',
                            style: AppTheme.labelMedium.copyWith(color: const Color(0xFF412d00))),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      ), // Container
    );   // ClipRRect
  }
}

// ─── Today's Mood Grid (Netflix-style 3-column) ───────────────────────────────

const List<String> _moodImages = [
  'assets/images/gloomy.png',
  'assets/images/sea.png',
  'assets/images/sunrise.png',
  'assets/images/lake.png',
];

String _randomMoodImage() => _moodImages[Random().nextInt(_moodImages.length)];

class _TodaysMoodGrid extends StatelessWidget {
  final List<MoodEntry> entries;
  const _TodaysMoodGrid({required this.entries});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Today's Moods",
            style: AppTheme.headlineSerif.copyWith(fontSize: 24)),
        const SizedBox(height: 16),
        if (entries.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Icon(Icons.auto_awesome_outlined,
                    color: AppTheme.primary, size: 32),
                const SizedBox(height: 12),
                Text("No moods logged today — start your first check-in!",
                    textAlign: TextAlign.center,
                    style: AppTheme.bodyMedium
                        .copyWith(color: AppTheme.textSecondary)),
              ],
            ),
          )
        else
          SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final e = entries[index];
                return _MoodHorizontalCard(
                  image: _randomMoodImage(),
                  moodName: e.emotionTags.isNotEmpty
                      ? e.emotionTags.first
                      : (AppConstants.moodLabels[e.moodScore] ?? ''),
                  description: e.notes,
                  score: e.moodScore,
                );
              },
            ),
          ),
      ],
    );
  }
}

class _MoodHorizontalCard extends StatelessWidget {
  final String image;
  final String moodName;
  final String description;
  final int score;

  const _MoodHorizontalCard({
    required this.image,
    required this.moodName,
    required this.description,
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: AppTheme.outlineVariant.withValues(alpha: 0.25), width: 0.5),
      ),
      child: Column(
        children: [
          // Image — top
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            child: SizedBox(
              width: 140,
              height: 104,
              child: Image.asset(
                image,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: AppTheme.moodColorForScore(score).withValues(alpha: 0.6),
                ),
              ),
            ),
          ),
          // Text — bottom
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    moodName,
                    style: AppTheme.labelMedium.copyWith(
                        color: AppTheme.textPrimary, fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (description.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: AppTheme.bodySmall.copyWith(fontSize: 9),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
