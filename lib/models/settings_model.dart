// TODO: settings model | Author: Rajat Mahajan
// Model: Settings — matches DATABASE_SCHEMA.sql settings table

class Settings {
  final String id;
  final String userId;
  final String theme;
  final bool dailyReminderEnabled;
  final String reminderTime;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Settings({
    required this.id,
    required this.userId,
    required this.theme,
    required this.dailyReminderEnabled,
    required this.reminderTime,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Settings.defaults(String userId) {
    final now = DateTime.now();
    return Settings(
      id: userId,
      userId: userId,
      theme: 'dark',
      dailyReminderEnabled: true,
      reminderTime: '20:00',
      createdAt: now,
      updatedAt: now,
    );
  }

  factory Settings.fromMap(Map<String, dynamic> map) {
    return Settings(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      theme: map['theme'] as String? ?? 'dark',
      dailyReminderEnabled: (map['daily_reminder_enabled'] as int? ?? 1) == 1,
      reminderTime: map['reminder_time'] as String? ?? '20:00',
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'theme': theme,
      'daily_reminder_enabled': dailyReminderEnabled ? 1 : 0,
      'reminder_time': reminderTime,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Settings copyWith({
    String? theme,
    bool? dailyReminderEnabled,
    String? reminderTime,
  }) {
    return Settings(
      id: id,
      userId: userId,
      theme: theme ?? this.theme,
      dailyReminderEnabled: dailyReminderEnabled ?? this.dailyReminderEnabled,
      reminderTime: reminderTime ?? this.reminderTime,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
