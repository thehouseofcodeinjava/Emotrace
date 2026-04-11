// TODO: insight service | Author: Rajat Mahajan
// Service: InsightService — pattern detection algorithms (streak, stability, day-of-week)

import '../models/mood_entry_model.dart';
import 'database_service.dart';

class Insights {
  final double averageMood;
  final double stabilityScore;
  final int currentStreak;
  final int longestStreak;
  final String bestDay;
  final Map<String, int> emotionFrequency;
  final List<MoodEntry> last30Days;

  const Insights({
    required this.averageMood,
    required this.stabilityScore,
    required this.currentStreak,
    required this.longestStreak,
    required this.bestDay,
    required this.emotionFrequency,
    required this.last30Days,
  });

  static Insights empty() => const Insights(
        averageMood: 0,
        stabilityScore: 0,
        currentStreak: 0,
        longestStreak: 0,
        bestDay: '',
        emotionFrequency: {},
        last30Days: [],
      );
}

class InsightService {
  final DatabaseService _db = DatabaseService();

  // TODO: implement full insight calculations | Author: Rajat Mahajan
  Future<Insights> getInsights(String userId) async {
    // Placeholder — will implement algorithms in Week 5-6
    return Insights.empty();
  }

  // TODO: streak calculation algorithm
  int calculateCurrentStreak(List<MoodEntry> entriesSortedDesc) {
    // Logic: count consecutive days from today with entries
    // See APP_ARCHITECTURE.md §Key Algorithms — Streak Calculation
    return 0;
  }

  // TODO: stability score (standard deviation)
  double calculateStabilityScore(List<int> moodScores) {
    // Logic: lower SD = more stable = higher score out of 10
    // See APP_ARCHITECTURE.md §Key Algorithms — Mood Stability
    return 0;
  }

  // TODO: day-of-week pattern
  String detectBestDay(List<MoodEntry> entries) {
    // Logic: group by weekday, find highest average
    // See APP_ARCHITECTURE.md §Key Algorithms — Day-of-Week Pattern Detection
    return '';
  }

  // TODO: emotion frequency
  Map<String, int> getEmotionFrequency(List<MoodEntry> entries) {
    // Logic: count emotion tags, sort by frequency DESC
    // See APP_ARCHITECTURE.md §Key Algorithms — Emotion Frequency
    return {};
  }
}
