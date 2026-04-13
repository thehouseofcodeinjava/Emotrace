// TODO: mood provider | Author: Rajat Mahajan
// Provider: MoodProvider — state management for mood entries

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/mood_entry_model.dart';
import '../services/mood_service.dart';
import '../config/constants.dart';
import '../utils/date_utils.dart';

class MoodProvider extends ChangeNotifier {
  final MoodService _moodService = MoodService();
  final _uuid = const Uuid();

  // Temporary placeholder user until auth is implemented in Month 2
  static const String _tempUserId = 'local_user_01';

  List<MoodEntry> _entries = [];
  bool _isLoading = false;
  String? _error;

  List<MoodEntry> get entries => _entries;
  bool get isLoading => _isLoading;
  String? get error => _error;

  MoodEntry? get todaysMood {
    final today = DateTime.now();
    try {
      return _entries.firstWhere((e) =>
          e.createdAt.year == today.year &&
          e.createdAt.month == today.month &&
          e.createdAt.day == today.day);
    } catch (_) {
      return null;
    }
  }

  List<MoodEntry> get recentEntries =>
      _entries.take(AppConstants.recentEntriesCount).toList();

  int get currentStreak {
    final dates = _entries.map((e) => e.createdAt).toList();
    return AppDateUtils.calculateCurrentStreak(dates);
  }

  int get longestStreak {
    if (_entries.isEmpty) return 0;
    final days = _entries
        .map((e) => DateTime(e.createdAt.year, e.createdAt.month, e.createdAt.day))
        .toSet()
        .toList()
      ..sort();
    int longest = 1;
    int current = 1;
    for (int i = 1; i < days.length; i++) {
      if (days[i].difference(days[i - 1]).inDays == 1) {
        current++;
        if (current > longest) longest = current;
      } else {
        current = 1;
      }
    }
    return longest;
  }

  Future<void> addMoodEntry(
    int moodScore,
    List<String> emotions,
    String notes,
  ) async {
    final now = DateTime.now();
    final entry = MoodEntry(
      id: _uuid.v4(),
      userId: _tempUserId,
      moodScore: moodScore,
      emotionTags: emotions,
      notes: notes,
      createdAt: now,
      updatedAt: now,
    );

    try {
      await _moodService.saveMoodEntry(entry);
      _entries.insert(0, entry);
      notifyListeners();
    } catch (e) {
      _error = 'Error saving mood. Please try again.';
      notifyListeners();
    }
  }

  Future<void> loadEntries() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _entries = await _moodService.getMoodEntries(AppConstants.calendarDays);
    } catch (e) {
      _error = 'Error loading entries.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteEntry(String id) async {
    await _moodService.deleteMoodEntry(id);
    _entries.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
