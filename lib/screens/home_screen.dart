// Screen: HomeScreen | Author: Rajat Mahajan | Date: 11 Apr 2026
// Sanctuary redesign: Piyush Puri | Date: 15 Apr 2026
// Editorial hero header, bento grid (vibe card + mood sphere), Recent Echoes grid, gold FAB

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../config/constants.dart';
import '../config/routes.dart';
import '../config/theme.dart';
import '../models/mood_entry_model.dart';
import '../providers/mood_provider.dart';
import '../widgets/mood_entry_card.dart';

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
    final provider = context.read<MoodProvider>();
    Navigator.pushNamed(context, AppRoutes.moodEntry)
        .then((_) => provider.loadEntries());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Consumer<MoodProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.entries.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            );
          }

          return Stack(
            children: [
              RefreshIndicator(
                color: AppTheme.primary,
                onRefresh: provider.loadEntries,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    _buildAppBar(),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          const SizedBox(height: 8),
                          _HeroHeader(
                            currentStreak: provider.currentStreak,
                          ),
                          const SizedBox(height: 24),
                          _BentoGrid(
                            todaysMood: provider.todaysMood,
                            recentEntries: provider.entries,
                            onCheckIn: _goToMoodEntry,
                          ),
                          const SizedBox(height: 28),
                          _RecentEchoesSection(
                            entries: provider.recentEntries,
                          ),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
              // Gold FAB — bottom right
              Positioned(
                right: 24,
                bottom: 100,
                child: GestureDetector(
                  onTap: _goToMoodEntry,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFe9c176), Color(0xFFc5a059)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x40e9c176),
                          blurRadius: 20,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.add, color: Color(0xFF412d00), size: 28),
                  ),
                ),
              ),
            ],
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
    final greeting = hour < 12 ? 'Good morning,' : hour < 17 ? 'Good afternoon,' : 'Good evening,';
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
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFe9c176), Color(0xFFc5a059)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.local_fire_department,
                    color: Color(0xFF412d00), size: 28),
              ),
              const SizedBox(height: 8),
              Text(
                '$currentStreak',
                style: AppTheme.headlineSerifMedium.copyWith(
                    fontSize: 22, fontWeight: FontWeight.w900, color: AppTheme.primary),
              ),
              Text('DAYS', style: AppTheme.labelCaps),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Bento grid ───────────────────────────────────────────────────────────────

class _BentoGrid extends StatelessWidget {
  final MoodEntry? todaysMood;
  final List<MoodEntry> recentEntries;
  final VoidCallback onCheckIn;

  const _BentoGrid({
    required this.todaysMood,
    required this.recentEntries,
    required this.onCheckIn,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 320,
      child: Row(
        children: [
          // Vibe card — 2/3 width
          Expanded(
            flex: 2,
            child: _VibeCard(entry: todaysMood, onCheckIn: onCheckIn),
          ),
          const SizedBox(width: 12),
          // Mood sphere — 1/3 width
          Expanded(
            flex: 1,
            child: _MoodSphereCard(entries: recentEntries),
          ),
        ],
      ),
    );
  }
}

class _VibeCard extends StatelessWidget {
  final MoodEntry? entry;
  final VoidCallback onCheckIn;
  const _VibeCard({required this.entry, required this.onCheckIn});

  @override
  Widget build(BuildContext context) {
    final moodColor = entry != null
        ? AppTheme.moodColorForScore(entry!.moodScore)
        : AppTheme.secondaryContainer;
    final label = entry != null
        ? (AppConstants.moodLabels[entry!.moodScore] ?? '')
        : 'Not logged';
    final score = entry?.moodScore;

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

class _MoodSphereCard extends StatelessWidget {
  final List<MoodEntry> entries;
  const _MoodSphereCard({required this.entries});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final weekEntries = entries.where((e) =>
        now.difference(e.createdAt).inDays < 7).toList();

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Weekly\nSky', style: AppTheme.headlineSerifMedium.copyWith(fontSize: 18)),
            const SizedBox(height: 12),
            // Ambient orb
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.primary.withValues(alpha: 0.3),
                      AppTheme.primary.withValues(alpha: 0.0),
                    ],
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.filter_drama,
                      color: AppTheme.primary, size: 36),
                ),
              ),
            ),
            const Spacer(),
            // Mini 5-bar trend
            if (weekEntries.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(5, (i) {
                  final idx = (weekEntries.length - 5 + i).clamp(0, weekEntries.length - 1);
                  final score = weekEntries[idx].moodScore;
                  final barH = 8.0 + (score / 10) * 28;
                  return Container(
                    width: 10,
                    height: barH,
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.6 + 0.04 * score),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                    ),
                  );
                }),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Recent Echoes section ────────────────────────────────────────────────────

class _RecentEchoesSection extends StatelessWidget {
  final List<MoodEntry> entries;
  const _RecentEchoesSection({required this.entries});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Recent Echoes', style: AppTheme.headlineSerif.copyWith(fontSize: 24)),
            Text('View All →',
                style: AppTheme.bodySmall.copyWith(color: AppTheme.primary)),
          ],
        ),
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
                const Icon(Icons.auto_awesome_outlined, color: AppTheme.primary, size: 32),
                const SizedBox(height: 12),
                Text('No entries yet — start logging!',
                    style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary)),
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
