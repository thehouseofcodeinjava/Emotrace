// Test: PdfService | Author: Piyush Puri | Date: 13 Apr 2026

import 'package:flutter_test/flutter_test.dart';
import 'package:emotrace/models/mood_entry_model.dart';
import 'package:emotrace/services/insight_service.dart';
import 'package:emotrace/services/pdf_service.dart';

void main() {
  final now = DateTime.now();

  final sampleEntries = List.generate(
    5,
    (i) => MoodEntry(
      id: 'id_$i',
      userId: 'local_user_01',
      moodScore: 5 + i % 5,
      emotionTags: ['calm', 'happy'],
      notes: 'Note $i',
      createdAt: now.subtract(Duration(days: i)),
      updatedAt: now.subtract(Duration(days: i)),
    ),
  );

  final sampleInsights = Insights(
    averageMood: 7.2,
    stabilityScore: 8.5,
    currentStreak: 5,
    longestStreak: 12,
    bestDay: 'Monday',
    worstDay: 'Friday',
    emotionFrequency: {'calm': 8, 'happy': 6, 'focused': 4},
    last30Days: sampleEntries,
  );

  group('PdfService.buildHistoryPdf', () {
    test('returns non-empty bytes for populated entries', () async {
      final bytes = await PdfService.buildHistoryPdf(
        sampleEntries,
        5,
        12,
      );
      expect(bytes, isNotEmpty);
      expect(bytes.length, greaterThan(500));
    });

    test('returns bytes even for empty entry list', () async {
      final bytes = await PdfService.buildHistoryPdf([], 0, 0);
      expect(bytes, isNotEmpty);
    });
  });

  group('PdfService.buildInsightsPdf', () {
    test('returns non-empty bytes for full insights', () async {
      final bytes = await PdfService.buildInsightsPdf(
        sampleInsights,
        sampleEntries,
      );
      expect(bytes, isNotEmpty);
      expect(bytes.length, greaterThan(500));
    });

    test('returns bytes when insights has no patterns or emotions', () async {
      final minimal = Insights(
        averageMood: 6.0,
        stabilityScore: 7.0,
        currentStreak: 1,
        longestStreak: 1,
        bestDay: '',
        worstDay: '',
        emotionFrequency: {},
        last30Days: sampleEntries,
      );
      final bytes = await PdfService.buildInsightsPdf(minimal, sampleEntries);
      expect(bytes, isNotEmpty);
    });
  });
}
