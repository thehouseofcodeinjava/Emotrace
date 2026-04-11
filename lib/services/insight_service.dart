// Service: InsightService — pattern detection algorithms | Author: Piyush Puri | Date: 11 Apr 2026
// Algorithms implemented: streak, stability score, day-of-week pattern, emotion frequency.
// See APP_ARCHITECTURE.md §Key Algorithms for full spec.

import 'dart:math';

import '../models/mood_entry_model.dart';
import 'database_service.dart';

class Insights {
  final double averageMood;
  final double stabilityScore;
  final int currentStreak;
  final int longestStreak;
  final String bestDay;
  final String worstDay;
  final Map<String, int> emotionFrequency;
  final List<MoodEntry> last30Days;

  const Insights({
    required this.averageMood,
    required this.stabilityScore,
    required this.currentStreak,
    required this.longestStreak,
    required this.bestDay,
    required this.worstDay,
    required this.emotionFrequency,
    required this.last30Days,
  });

  static Insights empty() => const Insights(
        averageMood: 0,
        stabilityScore: 0,
        currentStreak: 0,
        longestStreak: 0,
        bestDay: '',
        worstDay: '',
        emotionFrequency: {},
        last30Days: [],
      );

  bool get hasData => last30Days.isNotEmpty;
}

class InsightService {
  final DatabaseService _db = DatabaseService();

  static const String _tempUserId = 'local_user_01';

  Future<Insights> getInsights(String userId) async {
    final from90 = DateTime.now().subtract(const Duration(days: 90));
    final from30 = DateTime.now().subtract(const Duration(days: 30));

    final rows90 = await _db.query(
      'mood_entries',
      where: 'user_id = ? AND created_at >= ?',
      whereArgs: [userId, from90.toIso8601String()],
      orderBy: 'created_at DESC',
    );
    final rows30 = await _db.query(
      'mood_entries',
      where: 'user_id = ? AND created_at >= ?',
      whereArgs: [userId, from30.toIso8601String()],
      orderBy: 'created_at DESC',
    );

    final entries90 = rows90.map(MoodEntry.fromMap).toList();
    final entries30 = rows30.map(MoodEntry.fromMap).toList();

    if (entries90.isEmpty) return Insights.empty();

    final scores30 = entries30.map((e) => e.moodScore).toList();
    final avg = scores30.isEmpty ? 0.0 : _mean(scores30);
    final stability = scores30.length < 2 ? 0.0 : _stabilityScore(scores30);

    final currentStreak = calculateCurrentStreak(entries90);
    final longestStreak = _calculateLongestStreak(entries90);
    final bestDay = detectBestDay(entries90);
    final worstDay = _detectWorstDay(entries90);
    final emotionFreq = getEmotionFrequency(entries30);

    return Insights(
      averageMood: avg,
      stabilityScore: stability,
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      bestDay: bestDay,
      worstDay: worstDay,
      emotionFrequency: emotionFreq,
      last30Days: entries30,
    );
  }

  // ─── Streak calculation ───────────────────────────────────────────────────
  // Counts consecutive days from today backwards that have at least one entry.
  // See APP_ARCHITECTURE.md §Key Algorithms — Streak Calculation.

  int calculateCurrentStreak(List<MoodEntry> entriesSortedDesc) {
    if (entriesSortedDesc.isEmpty) return 0;

    final uniqueDays = _uniqueDays(entriesSortedDesc);
    uniqueDays.sort((a, b) => b.compareTo(a)); // most-recent first

    final today = _dayOnly(DateTime.now());
    int streak = 0;
    DateTime cursor = today;

    for (final day in uniqueDays) {
      final d = _dayOnly(day);
      if (d == cursor || d == cursor.subtract(const Duration(days: 1))) {
        streak++;
        cursor = d;
      } else {
        break;
      }
    }
    return streak;
  }

  int _calculateLongestStreak(List<MoodEntry> entriesSortedDesc) {
    if (entriesSortedDesc.isEmpty) return 0;

    final uniqueDays = _uniqueDays(entriesSortedDesc)
      ..sort(); // oldest first
    if (uniqueDays.isEmpty) return 0;

    int longest = 1;
    int current = 1;
    for (int i = 1; i < uniqueDays.length; i++) {
      final diff = _dayOnly(uniqueDays[i])
          .difference(_dayOnly(uniqueDays[i - 1]))
          .inDays;
      if (diff == 1) {
        current++;
        if (current > longest) longest = current;
      } else {
        current = 1;
      }
    }
    return longest;
  }

  // ─── Stability score (standard deviation → 0–10 scale) ───────────────────
  // Lower SD = more stable = higher score.
  // See APP_ARCHITECTURE.md §Key Algorithms — Mood Stability.

  double calculateStabilityScore(List<int> moodScores) => _stabilityScore(moodScores);

  double _stabilityScore(List<int> scores) {
    if (scores.length < 2) return 10.0;
    final sd = _stdDev(scores);
    // SD ranges 0–4.5 for scores 1–10; map to 0–10 inverted
    const maxSd = 4.5;
    return ((1 - (sd / maxSd).clamp(0.0, 1.0)) * 10).clamp(0.0, 10.0);
  }

  // ─── Day-of-week pattern detection ───────────────────────────────────────
  // Groups entries by weekday, returns the day with the highest average mood.
  // See APP_ARCHITECTURE.md §Key Algorithms — Day-of-Week Pattern Detection.

  String detectBestDay(List<MoodEntry> entries) => _topDay(entries, highest: true);

  String _detectWorstDay(List<MoodEntry> entries) => _topDay(entries, highest: false);

  String _topDay(List<MoodEntry> entries, {required bool highest}) {
    if (entries.isEmpty) return '';
    final Map<int, List<int>> byWeekday = {};
    for (final e in entries) {
      byWeekday.putIfAbsent(e.createdAt.weekday, () => []).add(e.moodScore);
    }
    final dayLabels = ['', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    int? bestWeekday;
    double bestAvg = highest ? -1 : 12;
    byWeekday.forEach((wd, scores) {
      final avg = _mean(scores);
      if (highest ? avg > bestAvg : avg < bestAvg) {
        bestAvg = avg;
        bestWeekday = wd;
      }
    });
    return bestWeekday != null ? dayLabels[bestWeekday!] : '';
  }

  // ─── Emotion frequency ────────────────────────────────────────────────────
  // Counts occurrences of each emotion tag, returns sorted map (highest first).
  // See APP_ARCHITECTURE.md §Key Algorithms — Emotion Frequency.

  Map<String, int> getEmotionFrequency(List<MoodEntry> entries) {
    final Map<String, int> freq = {};
    for (final e in entries) {
      for (final tag in e.emotionTags) {
        if (tag.isNotEmpty) freq[tag] = (freq[tag] ?? 0) + 1;
      }
    }
    final sorted = freq.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(sorted.take(8));
  }

  // ─── Private helpers ─────────────────────────────────────────────────────

  double _mean(List<int> scores) =>
      scores.fold(0.0, (s, v) => s + v) / scores.length;

  double _stdDev(List<int> scores) {
    final avg = _mean(scores);
    final variance = scores.fold(0.0, (s, v) => s + pow(v - avg, 2)) / scores.length;
    return sqrt(variance);
  }

  List<DateTime> _uniqueDays(List<MoodEntry> entries) {
    final seen = <String>{};
    final result = <DateTime>[];
    for (final e in entries) {
      final key = '${e.createdAt.year}-${e.createdAt.month}-${e.createdAt.day}';
      if (seen.add(key)) result.add(e.createdAt);
    }
    return result;
  }

  DateTime _dayOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);
}
