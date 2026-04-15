// Config: AppConstants | Author: Rajat Mahajan | Date: 11 Apr 2026
// Updated: Piyush Puri | Date: 15 Apr 2026 — Sanctuary mood labels + expanded emotions

class AppConstants {
  static const String appName = 'EMOTRACE';
  static const String tempUserId = 'local_user_01';

  static const int recentEntriesCount = 3;
  static const int calendarDays = 90;
  static const int insightsDays = 30;
  static const int maxNotesLength = 500;
  static const int minMoodScore = 1;
  static const int maxMoodScore = 10;
  static const int streakGoal = 10;

  static const List<String> weekDayLabels = [
    'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun',
  ];

  // Expanded emotion list for Sanctuary icon-grid selector
  static const List<String> emotions = [
    'calm', 'focused', 'inspired', 'grounded', 'peaceful', 'energetic',
    'anxious', 'happy', 'sad', 'stressed', 'grateful', 'overwhelmed',
    'angry', 'excited', 'tired', 'content',
  ];

  // Mood emojis — kept for bottom-sheet detail modal in CalendarHeatmap
  static const Map<int, String> moodEmojis = {
    1: '😣', 2: '😢', 3: '😕', 4: '😐', 5: '😶',
    6: '🙂', 7: '😊', 8: '😄', 9: '😁', 10: '🤩',
  };

  // Sanctuary mood labels
  static const Map<int, String> moodLabels = {
    1:  'Depleted',
    2:  'Heavy',
    3:  'Low',
    4:  'Unsettled',
    5:  'Steady',
    6:  'Decent',
    7:  'Balanced',
    8:  'Vibrant',
    9:  'Radiant',
    10: 'Luminous',
  };

  // Motivational messages (mood entry screen)
  static const Map<int, String> moodMotivations = {
    1:  'Every storm runs out of rain. Hang in there.',
    2:  'It\'s okay to not be okay. One step at a time.',
    3:  'You\'re doing better than you think.',
    4:  'Neutral is a foundation — build from here.',
    5:  'Okay is a starting point. You\'ve got this.',
    6:  'Decent is underrated. Keep going.',
    7:  'Balance is a superpower. Own it.',
    8:  'You\'re in a great space. Enjoy it.',
    9:  'Amazing energy. Spread some light today.',
    10: 'Peak vibes! Make this day count.',
  };
}
