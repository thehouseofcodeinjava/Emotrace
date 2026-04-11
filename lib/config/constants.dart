// Config: AppConstants | Author: Rajat Mahajan | Date: 11 Apr 2026
// NOTE: Recreated by Piyush Puri (11 Apr 2026) — original was missing from Rajat's commit.

class AppConstants {
  // App identity
  static const String appName = 'EMOTRACE';
  static const String tempUserId = 'local_user_01';

  // Data limits
  static const int recentEntriesCount = 3;
  static const int calendarDays = 90;
  static const int insightsDays = 30;
  static const int maxNotesLength = 500;
  static const int minMoodScore = 1;
  static const int maxMoodScore = 10;

  // Emotion options (for EmotionTagSelector)
  static const List<String> emotions = [
    'calm',
    'anxious',
    'happy',
    'sad',
    'stressed',
    'grateful',
    'overwhelmed',
    'focused',
    'angry',
    'excited',
    'tired',
    'content',
  ];

  // Mood emoji map (1-10)
  static const Map<int, String> moodEmojis = {
    1:  '😣',
    2:  '😢',
    3:  '😕',
    4:  '😐',
    5:  '😶',
    6:  '🙂',
    7:  '😊',
    8:  '😄',
    9:  '😁',
    10: '🤩',
  };

  // Mood label map (1-10)
  static const Map<int, String> moodLabels = {
    1:  'VIBE: TERRIBLE',
    2:  'VIBE: BAD',
    3:  'VIBE: LOW',
    4:  'VIBE: MEH',
    5:  'VIBE: OKAY',
    6:  'VIBE: DECENT',
    7:  'VIBE: BALANCED',
    8:  'VIBE: GOOD',
    9:  'VIBE: GREAT',
    10: 'VIBE: AMAZING',
  };

  // Motivational messages shown on Mood Entry screen
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
    10: 'Peak vibes! Make this day count. 🔥',
  };

  // Day-of-week labels
  static const List<String> weekDayLabels = [
    'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun',
  ];

  // Insights streak goal
  static const int streakGoal = 10;
}
