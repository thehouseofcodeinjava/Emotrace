// TODO: mood entry model | Author: Rajat Mahajan
// Model: MoodEntry — matches DATABASE_SCHEMA.sql mood_entries table

class MoodEntry {
  final String id;
  final String userId;
  final int moodScore;
  final List<String> emotionTags;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  DateTime get date => DateTime(createdAt.year, createdAt.month, createdAt.day);

  const MoodEntry({
    required this.id,
    required this.userId,
    required this.moodScore,
    required this.emotionTags,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MoodEntry.fromMap(Map<String, dynamic> map) {
    return MoodEntry(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      moodScore: map['mood_score'] as int,
      emotionTags: (map['emotion_tags'] as String? ?? '')
          .split(',')
          .where((e) => e.isNotEmpty)
          .toList(),
      notes: map['notes'] as String? ?? '',
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'mood_score': moodScore,
      'emotion_tags': emotionTags.join(','),
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  MoodEntry copyWith({
    String? id,
    String? userId,
    int? moodScore,
    List<String>? emotionTags,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MoodEntry(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      moodScore: moodScore ?? this.moodScore,
      emotionTags: emotionTags ?? this.emotionTags,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
