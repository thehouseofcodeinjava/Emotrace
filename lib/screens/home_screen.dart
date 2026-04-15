// Screen: HomeScreen | Author: Rajat Mahajan | Date: 11 Apr 2026
// BMS redesign: Rajat Mahajan | Date: 15 Apr 2026
// BookMyShow-inspired: dark bg, red accent, poster cards, carousels

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../config/constants.dart';
import '../config/routes.dart';
import '../config/theme.dart';
import '../models/mood_entry_model.dart';
import '../providers/mood_provider.dart';

// ─── BMS palette ──────────────────────────────────────────────────────────────
const Color _kBg         = Color(0xFF0A0A0A);
const Color _kSurface    = Color(0xFF1A1A1A);
const Color _kRed        = Color(0xFFE31E24);
const Color _kRedDark    = Color(0xFFC1121F);
const Color _kText       = Color(0xFFFFFFFF);
const Color _kTextSec    = Color(0xFF9E9E9E);
const Color _kBorder     = Color(0xFF2E2E2E);
const Color _kOrange     = Color(0xFFF5A623);

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
      backgroundColor: _kBg,
      body: Consumer<MoodProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.entries.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: _kRed),
            );
          }

          return Stack(
            children: [
              RefreshIndicator(
                color: _kRed,
                backgroundColor: _kSurface,
                onRefresh: provider.loadEntries,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    _BmsAppBar(onCheckIn: _goToMoodEntry),
                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Today's mood banner
                          _TodayBanner(
                            entry: provider.todaysMood,
                            onCheckIn: _goToMoodEntry,
                          ),
                          const SizedBox(height: 28),

                          // Streak + stats row
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: _StatsRow(
                              streak: provider.currentStreak,
                              total: provider.entries.length,
                            ),
                          ),
                          const SizedBox(height: 28),

                          // Recent echoes horizontal carousel
                          _SectionHeader(
                            title: 'RECENT ECHOES',
                            onSeeAll: () {},
                          ),
                          const SizedBox(height: 12),
                          _RecentCarousel(entries: provider.recentEntries),
                          const SizedBox(height: 120),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Red FAB — BMS "Book Now" style
              Positioned(
                right: 20,
                bottom: 100,
                child: GestureDetector(
                  onTap: _goToMoodEntry,
                  child: Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [_kRed, _kRedDark],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x55E31E24),
                          blurRadius: 18,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.add, color: _kText, size: 26),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─── App bar ──────────────────────────────────────────────────────────────────

class _BmsAppBar extends StatelessWidget {
  final VoidCallback onCheckIn;
  const _BmsAppBar({required this.onCheckIn});

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('EEE, d MMM').format(DateTime.now());
    return SliverAppBar(
      floating: true,
      snap: true,
      backgroundColor: _kBg,
      elevation: 0,
      leadingWidth: 140,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
        child: Row(
          children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: _kRed,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text('E',
                  style: TextStyle(
                    color: _kText,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Text('EMOTRACE',
              style: TextStyle(
                color: _kText,
                fontWeight: FontWeight.w900,
                fontSize: 16,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
      actions: [
        // Date chip — BMS city selector style
        Container(
          margin: const EdgeInsets.only(right: 8, top: 10, bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: _kSurface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _kBorder),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.calendar_today_rounded, color: _kRed, size: 12),
              const SizedBox(width: 4),
              Text(date,
                style: const TextStyle(
                  color: _kText, fontSize: 11, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.notifications_none_rounded, color: _kTextSec),
          onPressed: () {},
        ),
      ],
    );
  }
}

// ─── Today's mood banner ──────────────────────────────────────────────────────

class _TodayBanner extends StatelessWidget {
  final MoodEntry? entry;
  final VoidCallback onCheckIn;
  const _TodayBanner({required this.entry, required this.onCheckIn});

  @override
  Widget build(BuildContext context) {
    final score = entry?.moodScore;
    final label = score != null
        ? (AppConstants.moodLabels[score] ?? 'Unknown')
        : null;
    final moodColor = score != null
        ? AppTheme.moodColorForScore(score)
        : _kRed;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: _kSurface,
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Top gradient using mood color
          Positioned(
            top: 0, left: 0, right: 0,
            height: 120,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    moodColor.withValues(alpha: 0.5),
                    _kSurface.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // NOW SHOWING badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _kRed,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('NOW SHOWING',
                    style: TextStyle(
                      color: _kText,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  label ?? "Today's Check-In",
                  style: const TextStyle(
                    color: _kText,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  score != null
                      ? 'You logged your mood today'
                      : 'You haven\'t checked in yet',
                  style: const TextStyle(color: _kTextSec, fontSize: 13),
                ),
                const Spacer(),
                Row(
                  children: [
                    // Rating badge — like IMDb rating on BMS
                    if (score != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: _kOrange.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: _kOrange.withValues(alpha: 0.4)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star_rounded,
                                color: _kOrange, size: 14),
                            const SizedBox(width: 4),
                            Text('$score/10',
                              style: const TextStyle(
                                color: _kOrange,
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                    // CTA button
                    GestureDetector(
                      onTap: onCheckIn,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              colors: [_kRed, _kRedDark]),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          score != null ? 'UPDATE MOOD' : 'LOG MOOD',
                          style: const TextStyle(
                            color: _kText,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Stats row ────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final int streak;
  final int total;
  const _StatsRow({required this.streak, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatChip(
            icon: Icons.local_fire_department_rounded,
            iconColor: _kOrange,
            value: '$streak',
            label: 'Day Streak',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatChip(
            icon: Icons.edit_note_rounded,
            iconColor: _kRed,
            value: '$total',
            label: 'Total Entries',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatChip(
            icon: Icons.bar_chart_rounded,
            iconColor: const Color(0xFF4FC3F7),
            value: '–',
            label: 'Avg Score',
          ),
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;
  const _StatChip({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(height: 6),
          Text(value,
            style: const TextStyle(
              color: _kText,
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
          Text(label,
            style: const TextStyle(
              color: _kTextSec,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─── Section header ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;
  const _SectionHeader({required this.title, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
            style: const TextStyle(
              color: _kText,
              fontWeight: FontWeight.w800,
              fontSize: 15,
              letterSpacing: 0.5,
            ),
          ),
          if (onSeeAll != null)
            GestureDetector(
              onTap: onSeeAll,
              child: const Text('SEE ALL',
                style: TextStyle(
                  color: _kRed,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Recent horizontal carousel ───────────────────────────────────────────────

class _RecentCarousel extends StatelessWidget {
  final List<MoodEntry> entries;
  const _RecentCarousel({required this.entries});

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          height: 120,
          decoration: BoxDecoration(
            color: _kSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _kBorder),
          ),
          child: const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.auto_awesome_outlined, color: _kRed, size: 28),
                SizedBox(height: 8),
                Text('No entries yet — start logging!',
                  style: TextStyle(color: _kTextSec, fontSize: 13)),
              ],
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 160,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: entries.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) => _MoodPosterCard(entry: entries[i]),
      ),
    );
  }
}

class _MoodPosterCard extends StatelessWidget {
  final MoodEntry entry;
  const _MoodPosterCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.moodColorForScore(entry.moodScore);
    final label = AppConstants.moodLabels[entry.moodScore] ?? '';
    final date = DateFormat('d MMM').format(entry.createdAt);

    return Container(
      width: 120,
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kBorder),
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Color band at top
          Positioned(
            top: 0, left: 0, right: 0, height: 60,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    color.withValues(alpha: 0.7),
                    _kSurface.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Score badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: _kOrange.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star_rounded,
                          color: _kOrange, size: 10),
                      const SizedBox(width: 3),
                      Text('${entry.moodScore}/10',
                        style: const TextStyle(
                          color: _kOrange,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(label,
                  style: const TextStyle(
                    color: _kText,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(date,
                  style: const TextStyle(
                    color: _kTextSec,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
