// TODO: emotion model | Author: Rajat Mahajan
// Model: Emotion — matches DATABASE_SCHEMA.sql emotion_tags table

class Emotion {
  final String id;
  final String moodEntryId;
  final String tagName;

  const Emotion({
    required this.id,
    required this.moodEntryId,
    required this.tagName,
  });

  factory Emotion.fromMap(Map<String, dynamic> map) {
    return Emotion(
      id: map['id'] as String,
      moodEntryId: map['mood_entry_id'] as String,
      tagName: map['tag_name'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'mood_entry_id': moodEntryId,
      'tag_name': tagName,
    };
  }
}
