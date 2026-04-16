// TODO: mood service | Author: Rajat Mahajan
// Service: MoodService — CRUD operations for mood entries

import '../models/mood_entry_model.dart';
import 'database_service.dart';

class MoodService {
  final DatabaseService _db = DatabaseService();

  Future<void> saveMoodEntry(MoodEntry entry) async {
    await _db.insert('mood_entries', entry.toMap());
  }

  Future<List<MoodEntry>> getMoodEntries(int days) async {
    final fromDate = DateTime.now().subtract(Duration(days: days));
    final rows = await _db.query(
      'mood_entries',
      where: 'created_at >= ?',
      whereArgs: [fromDate.toIso8601String()],
      orderBy: 'created_at DESC',
    );
    return rows.map(MoodEntry.fromMap).toList();
  }

  Future<MoodEntry?> getTodaysMood(String userId) async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day).toIso8601String();
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59).toIso8601String();

    final rows = await _db.query(
      'mood_entries',
      where: 'user_id = ? AND created_at BETWEEN ? AND ?',
      whereArgs: [userId, startOfDay, endOfDay],
      orderBy: 'created_at DESC',
      limit: 1,
    );

    if (rows.isEmpty) return null;
    return MoodEntry.fromMap(rows.first);
  }

  Future<List<MoodEntry>> getRecentEntries(String userId, int count) async {
    final rows = await _db.query(
      'mood_entries',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
      limit: count,
    );
    return rows.map(MoodEntry.fromMap).toList();
  }

  static Map<DateTime, List<MoodEntry>> groupMoodsByDay(List<MoodEntry> moods) {
    final grouped = <DateTime, List<MoodEntry>>{};
    for (final mood in moods) {
      final key = DateTime(
          mood.createdAt.year, mood.createdAt.month, mood.createdAt.day);
      grouped.putIfAbsent(key, () => []).add(mood);
    }
    return grouped;
  }

  static double calculateDailyAverage(
      DateTime date, List<MoodEntry> moods) {
    final dayMoods = moods.where((m) =>
        m.createdAt.year == date.year &&
        m.createdAt.month == date.month &&
        m.createdAt.day == date.day).toList();
    if (dayMoods.isEmpty) return 0.0;
    final sum = dayMoods.fold<int>(0, (s, m) => s + m.moodScore);
    return sum / dayMoods.length;
  }

  Future<void> deleteMoodEntry(String id) async {
    await _db.delete('mood_entries', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<MoodEntry>> getEntriesForDateRange(
    String userId,
    DateTime from,
    DateTime to,
  ) async {
    final rows = await _db.query(
      'mood_entries',
      where: 'user_id = ? AND created_at BETWEEN ? AND ?',
      whereArgs: [userId, from.toIso8601String(), to.toIso8601String()],
      orderBy: 'created_at ASC',
    );
    return rows.map(MoodEntry.fromMap).toList();
  }
}
