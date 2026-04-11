// TODO: date utilities | Author: Rajat Mahajan

import 'package:intl/intl.dart';

class AppDateUtils {
  static String formatDate(DateTime date) => DateFormat('EEE, d MMM yyyy').format(date);

  static String formatShortDate(DateTime date) => DateFormat('d MMM').format(date);

  static String formatTime(DateTime date) => DateFormat('HH:mm').format(date);

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static bool isToday(DateTime date) => isSameDay(date, DateTime.now());

  static bool isYesterday(DateTime date) =>
      isSameDay(date, DateTime.now().subtract(const Duration(days: 1)));

  static String relativeLabel(DateTime date) {
    if (isToday(date)) return 'Today';
    if (isYesterday(date)) return 'Yesterday';
    return formatShortDate(date);
  }

  // TODO: streak calculation — count consecutive days with entries
  // See APP_ARCHITECTURE.md §Key Algorithms — Streak Calculation
  static int calculateCurrentStreak(List<DateTime> entryDates) {
    if (entryDates.isEmpty) return 0;

    final sorted = entryDates.toList()..sort((a, b) => b.compareTo(a));
    int streak = 0;
    DateTime cursor = DateTime.now();

    for (final date in sorted) {
      if (isSameDay(date, cursor) || isSameDay(date, cursor.subtract(const Duration(days: 1)))) {
        streak++;
        cursor = DateTime(date.year, date.month, date.day);
      } else {
        break;
      }
    }

    return streak;
  }
}
