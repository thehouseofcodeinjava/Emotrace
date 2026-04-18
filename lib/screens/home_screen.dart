// Screen: HomeScreen | Author: Rajat Mahajan | Date: 11 Apr 2026
// Sanctuary redesign: Piyush Puri | Date: 15 Apr 2026
// Editorial hero header, vibe card, Netflix mood grid, gold FAB

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../config/constants.dart';
import '../config/routes.dart';
import '../config/theme.dart';
import '../models/mood_entry_model.dart';
import '../providers/insights_provider.dart';
import '../providers/mood_provider.dart';
import '../theme/theme_provider.dart';

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
    final colors = context.watch<ThemeProvider>().colors;

    return Scaffold(
      backgroundColor: AppTheme.background,
      // FAB removed — "Add mood" card in grid replaces it
      body: Consumer<MoodProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.entries.isEmpty) {
            return Center(
              child: CircularProgressIndicator(color: colors.accent),
            );
          }

          return RefreshIndicator(
            color: colors.accent,
            onRefresh: provider.loadEntries,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                _buildAppBar(colors),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const SizedBox(height: 8),
                      _HeroHeader(currentStreak: provider.currentStreak),
                      const SizedBox(height: 24),
                      _VibeCardSection(
                        provider: provider,
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

  SliverAppBar _buildAppBar(dynamic colors) {
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
          icon: Icon(Icons.notifications_none, color: colors.accent),
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
    final colors = context.watch<ThemeProvider>().colors;
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
              const SizedBox(height: 6),
              Text(date, style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary)),
            ],
          ),
        ),
        const SizedBox(width: 16),
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
                  Icon(Icons.local_fire_department,
                      color: colors.accent, size: 24),
                  const SizedBox(width: 6),
                  Text(
                    '$currentStreak',
                    style: AppTheme.headlineSerifMedium.copyWith(
                        fontSize: 22, fontWeight: FontWeight.w900, color: colors.accent),
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
  final MoodProvider provider;
  final VoidCallback onCheckIn;

  const _VibeCardSection({
    required this.provider,
    required this.onCheckIn,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 280,
      child: _VibeCard(provider: provider, onCheckIn: onCheckIn),
    );
  }
}

/// Builds the contextual insight line based on user mood data state.
({String line, String subline, String? accentWord}) _buildResonanceInsight(MoodProvider provider) {
  final entries = provider.entries;
  final todaysMoods = provider.todaysMoods;
  final streak = provider.currentStreak;
  final totalEntries = entries.length;

  // Condition 1: zero total entries
  if (totalEntries == 0) {
    return (
      line: 'A quiet place to notice yourself. Start when you\'re ready.',
      subline: 'YOUR FIRST CHECK-IN',
      accentWord: null,
    );
  }

  // Condition 2: 1-2 total entries, same day
  if (totalEntries <= 2 && todaysMoods.length == totalEntries) {
    final n = totalEntries;
    final times = n == 1 ? 'time' : 'times';
    return (
      line: 'You\'ve checked in $n $times today. Keep the thread going.',
      subline: 'DAY 1',
      accentWord: null,
    );
  }

  // For streak >= 3 conditions, compute averages
  if (streak >= 3) {
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));
    final fourteenDaysAgo = now.subtract(const Duration(days: 14));

    final last7 = entries.where((e) => e.createdAt.isAfter(sevenDaysAgo)).toList();
    final prior7 = entries.where((e) =>
        e.createdAt.isAfter(fourteenDaysAgo) &&
        e.createdAt.isBefore(sevenDaysAgo)).toList();

    final avg7 = last7.isNotEmpty
        ? last7.fold<int>(0, (s, e) => s + e.moodScore) / last7.length
        : 0.0;
    final avgPrior = prior7.isNotEmpty
        ? prior7.fold<int>(0, (s, e) => s + e.moodScore) / prior7.length
        : 0.0;

    final hour = now.hour;
    final timeOfDay = hour < 12 ? 'morning' : hour < 17 ? 'afternoon' : 'evening';

    // Condition 3: avg >= 7 (steady)
    if (avg7 >= 7 && avg7 < 8) {
      return (
        line: 'Your ${timeOfDay}s have felt steadier this week.',
        subline: '$streak DAYS OF PATTERNS',
        accentWord: 'steadier',
      );
    }

    // Condition 4: avg dropped >= 1.5 vs prior week
    if (prior7.isNotEmpty && (avgPrior - avg7) >= 1.5) {
      return (
        line: 'Some days weigh more. You showed up anyway.',
        subline: '$streak DAY STREAK',
        accentWord: null,
      );
    }

    // Condition 5: avg >= 8 consistently
    if (avg7 >= 8) {
      return (
        line: 'You\'ve been arriving bright lately.',
        subline: '$streak DAYS OF LIGHT',
        accentWord: 'bright',
      );
    }

    // Condition 6: middle range 5-7
    if (avg7 >= 5 && avg7 < 7) {
      return (
        line: 'You\'ve been holding steady.',
        subline: '$streak DAYS OF PATTERNS',
        accentWord: 'steady',
      );
    }
  }

  // Default fallback
  return (
    line: 'How are you landing today?',
    subline: 'CURRENT RESONANCE',
    accentWord: 'landing',
  );
}

class _VibeCard extends StatelessWidget {
  final MoodProvider provider;
  final VoidCallback onCheckIn;
  const _VibeCard({required this.provider, required this.onCheckIn});

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;
    final insight = _buildResonanceInsight(provider);

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Container(
      decoration: const BoxDecoration(
        color: AppTheme.surfaceContainerLow,
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/forest.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    colors.accent.withValues(alpha: 0.15),
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
                        decoration: BoxDecoration(
                          color: colors.accent, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 6),
                      Text('CURRENT RESONANCE',
                          style: AppTheme.labelCaps.copyWith(color: colors.accent)),
                    ],
                  ),
                ),
                const Spacer(),
                // Contextual one-liner
                _InsightLine(
                  line: insight.line,
                  accentWord: insight.accentWord,
                  accentColor: colors.accent,
                ),
                const SizedBox(height: 8),
                Text(insight.subline,
                    style: AppTheme.labelCaps.copyWith(
                        color: AppTheme.textSecondary, fontSize: 10)),
                const SizedBox(height: 20),
                // Check in button
                GestureDetector(
                  onTap: onCheckIn,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: [colors.accentSoft, colors.accent]),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.edit_note, color: AppTheme.onPrimary, size: 18),
                        const SizedBox(width: 6),
                        Text('Check In',
                            style: AppTheme.labelMedium.copyWith(color: AppTheme.onPrimary)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }
}

/// Renders the insight line with an optional accent-colored italic word.
class _InsightLine extends StatelessWidget {
  final String line;
  final String? accentWord;
  final Color accentColor;

  const _InsightLine({
    required this.line,
    this.accentWord,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    if (accentWord == null || !line.contains(accentWord!)) {
      return Text(
        line,
        style: AppTheme.headlineSerifItalic.copyWith(
            fontSize: 22, color: AppTheme.textPrimary),
      );
    }

    final parts = line.split(accentWord!);
    return RichText(
      text: TextSpan(
        style: AppTheme.headlineSerifItalic.copyWith(
            fontSize: 22, color: AppTheme.textPrimary),
        children: [
          TextSpan(text: parts[0]),
          TextSpan(
            text: accentWord,
            style: TextStyle(color: accentColor),
          ),
          if (parts.length > 1) TextSpan(text: parts[1]),
        ],
      ),
    );
  }
}

// ─── Today's Mood Grid (Netflix-style 3-column) ───────────────────────────────

const List<String> _moodImages = [
  'assets/images/gloomy.png',
  'assets/images/sea.png',
  'assets/images/sunrise.png',
  'assets/images/lake.png',
];

String _moodImageForIndex(int index) => _moodImages[index % _moodImages.length];

class _TodaysMoodGrid extends StatelessWidget {
  final List<MoodEntry> entries;
  const _TodaysMoodGrid({required this.entries});

  void _goToMoodEntry(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.moodEntry).then((_) async {
      if (context.mounted) {
        await context.read<MoodProvider>().loadEntries();
        context.read<InsightsProvider>().calculateInsights();
      }
    });
  }

  void _showMoodDetail(BuildContext context, MoodEntry entry) {
    final colors = context.read<ThemeProvider>().colors;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.outlineVariant,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              entry.emotionTags.isNotEmpty
                  ? entry.emotionTags.first[0].toUpperCase() + entry.emotionTags.first.substring(1)
                  : (AppConstants.moodLabels[entry.moodScore] ?? ''),
              style: AppTheme.headlineSerifMedium,
            ),
            const SizedBox(height: 4),
            Text(
              '${DateFormat('h:mm a').format(entry.createdAt)} · Score: ${entry.moodScore}/10',
              style: AppTheme.bodySmall,
            ),
            if (entry.notes.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(entry.notes, style: AppTheme.bodyMedium),
            ],
            if (entry.emotionTags.length > 1) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: entry.emotionTags.map((tag) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: colors.accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(tag[0].toUpperCase() + tag.substring(1),
                      style: AppTheme.bodySmall.copyWith(color: colors.accent)),
                )).toList(),
              ),
            ],
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      Navigator.pop(_);
                      if (context.mounted) {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            backgroundColor: AppTheme.surfaceContainerLow,
                            title: Text('Delete this entry?', style: AppTheme.headlineSerifMedium),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: Text('Cancel', style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary)),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                child: Text('Delete', style: AppTheme.bodyMedium.copyWith(color: const Color(0xFFE74C3C))),
                              ),
                            ],
                          ),
                        );
                        if (confirmed == true && context.mounted) {
                          await context.read<MoodProvider>().deleteEntry(entry.id);
                        }
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE74C3C).withValues(alpha: 0.4)),
                      ),
                      child: Center(
                        child: Text('Delete',
                            style: AppTheme.labelMedium.copyWith(color: const Color(0xFFE74C3C))),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;
    // +1 for the "Add mood" card at the end
    final itemCount = entries.length + 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with count
        Row(
          children: [
            Text("Today's Moods",
                style: AppTheme.headlineSerif.copyWith(fontSize: 24)),
            if (entries.isNotEmpty) ...[
              const SizedBox(width: 8),
              Text('(${entries.length})',
                  style: AppTheme.bodyMedium.copyWith(
                      color: colors.accentSoft, fontSize: 14)),
            ],
          ],
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 12,
            crossAxisSpacing: 10,
            childAspectRatio: 0.8,
          ),
          itemCount: itemCount,
          itemBuilder: (context, i) {
            // Last item is the "Add mood" card
            if (i == entries.length) {
              return _AddMoodCard(onTap: () => _goToMoodEntry(context));
            }
            final e = entries[i];
            return _MoodGridCard(
              entry: e,
              image: _moodImageForIndex(i),
              onTap: () => _showMoodDetail(context, e),
            );
          },
        ),
      ],
    );
  }
}

class _MoodGridCard extends StatelessWidget {
  final MoodEntry entry;
  final String image;
  final VoidCallback onTap;

  const _MoodGridCard({
    required this.entry,
    required this.image,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;
    final moodName = entry.emotionTags.isNotEmpty
        ? entry.emotionTags.first
        : (AppConstants.moodLabels[entry.moodScore] ?? '');
    // Capitalize
    final displayName = moodName.isNotEmpty
        ? moodName[0].toUpperCase() + moodName.substring(1)
        : '';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.line, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Full-card background image
              Positioned.fill(
                child: ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    Colors.black.withValues(alpha: 0.15),
                    BlendMode.darken,
                  ),
                  child: Image.asset(image, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppTheme.moodColorForScore(entry.moodScore).withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ),
              // Bottom gradient scrim
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.5),
                        Colors.black.withValues(alpha: 0.9),
                      ],
                      stops: const [0, 0.4, 0.7, 1.0],
                    ),
                  ),
                ),
              ),
              // Time pill top-right
              Positioned(
                top: 8, right: 8,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      DateFormat('h:mm a').format(entry.createdAt),
                      style: const TextStyle(
                        fontSize: 9,
                        letterSpacing: 0.5,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              // Text content bottom
              Positioned(
                left: 10, right: 10, bottom: 10,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      displayName,
                      style: AppTheme.headlineSerifMedium.copyWith(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (entry.notes.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        entry.notes,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.white.withValues(alpha: 0.75),
                          height: 1.3,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddMoodCard extends StatelessWidget {
  final VoidCallback onTap;
  const _AddMoodCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white.withValues(alpha: 0.02),
          border: Border.all(color: colors.line, width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.accent.withValues(alpha: 0.12),
              ),
              child: Icon(Icons.add, color: colors.accent, size: 20),
            ),
            const SizedBox(height: 10),
            Text(
              'ADD MOOD',
              style: TextStyle(
                fontSize: 9,
                letterSpacing: 1.5,
                color: colors.accentSoft,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
