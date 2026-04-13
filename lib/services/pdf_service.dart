// Service: PdfService | Author: Piyush Puri | Date: 13 Apr 2026
// Static PDF builders for mood history and insights reports.
// Usage: Printing.sharePdf(bytes: await PdfService.buildXxx(...))

import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../config/constants.dart';
import '../models/mood_entry_model.dart';
import 'insight_service.dart';

class PdfService {
  static final PdfColor _teal = PdfColor(6 / 255, 214 / 255, 160 / 255);

  // ─── Full History PDF ─────────────────────────────────────────────────────
  // Used by: Settings → Export Mood History

  static Future<Uint8List> buildHistoryPdf(
    List<MoodEntry> entries,
    int currentStreak,
    int longestStreak,
  ) async {
    final pdf = pw.Document();

    final total = entries.length;
    final avgMood = total == 0
        ? 0.0
        : entries.map((e) => e.moodScore).reduce((a, b) => a + b) / total;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        header: (_) => _pageHeader('Mood History Report'),
        footer: (_) => _pageFooter(),
        build: (_) => [
          pw.SizedBox(height: 16),

          // Summary stats row
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
            children: [
              _statCell('Total Entries', '$total'),
              _statCell('Avg Mood', avgMood.toStringAsFixed(1)),
              _statCell('Current Streak', '$currentStreak days'),
              _statCell('Longest Streak', '$longestStreak days'),
            ],
          ),
          pw.SizedBox(height: 24),

          pw.Text(
            'MOOD ENTRIES',
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: _teal,
              letterSpacing: 1.5,
            ),
          ),
          pw.SizedBox(height: 8),

          if (entries.isEmpty)
            pw.Text(
              'No entries yet.',
              style: pw.TextStyle(color: PdfColors.grey600, fontSize: 12),
            )
          else
            pw.TableHelper.fromTextArray(
              headers: ['Date', 'Score', 'Emotions', 'Notes'],
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
                fontSize: 10,
              ),
              headerDecoration: pw.BoxDecoration(
                color: PdfColor(28 / 255, 27 / 255, 27 / 255),
              ),
              cellStyle: const pw.TextStyle(fontSize: 9),
              cellHeight: 28,
              columnWidths: {
                0: const pw.FixedColumnWidth(72),
                1: const pw.FixedColumnWidth(52),
                2: const pw.FlexColumnWidth(1.5),
                3: const pw.FlexColumnWidth(2),
              },
              data: entries.map((e) {
                return [
                  _formatDate(e.createdAt),
                  '${e.moodScore}/10',
                  e.emotionTags.isEmpty ? '-' : e.emotionTags.join(', '),
                  e.notes.isEmpty
                      ? '-'
                      : e.notes.length > 60
                          ? '${e.notes.substring(0, 60)}...'
                          : e.notes,
                ];
              }).toList(),
            ),
        ],
      ),
    );

    return pdf.save();
  }

  // ─── Insights PDF ─────────────────────────────────────────────────────────
  // Used by: Insights → share icon

  static Future<Uint8List> buildInsightsPdf(
    Insights insights,
    List<MoodEntry> entries,
  ) async {
    final pdf = pw.Document();
    final now = DateTime.now();
    final from = now.subtract(const Duration(days: 30));

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _pageHeader('Monthly Insights Report'),
            pw.SizedBox(height: 4),
            pw.Text(
              '${_formatDate(from)}  to  ${_formatDate(now)}',
              style: const pw.TextStyle(
                  fontSize: 10, color: PdfColors.grey500),
            ),
            pw.Divider(color: PdfColors.grey300),
            pw.SizedBox(height: 20),

            // Hero score
            pw.Text(
              insights.stabilityScore > 0
                  ? '${insights.stabilityScore.toStringAsFixed(1)}/10'
                  : '${insights.averageMood.toStringAsFixed(1)}/10',
              style: pw.TextStyle(
                fontSize: 52,
                fontWeight: pw.FontWeight.bold,
                color: _teal,
              ),
            ),
            pw.Text(
              'STABILITY SCORE',
              style: pw.TextStyle(
                fontSize: 10,
                color: PdfColors.grey500,
                letterSpacing: 1.5,
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              'Avg mood: ${insights.averageMood.toStringAsFixed(1)}'
              '  |  Streak: ${insights.currentStreak} days'
              '  |  Entries: ${entries.length}',
              style: const pw.TextStyle(
                  fontSize: 11, color: PdfColors.grey600),
            ),
            pw.SizedBox(height: 20),

            // Day-of-week patterns
            if (insights.bestDay.isNotEmpty ||
                insights.worstDay.isNotEmpty) ...[
              pw.Text(
                'PATTERNS',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: _teal,
                  letterSpacing: 1.5,
                ),
              ),
              pw.SizedBox(height: 8),
              if (insights.bestDay.isNotEmpty)
                pw.Text(
                  '+ You feel better on ${insights.bestDay}s',
                  style: const pw.TextStyle(fontSize: 12),
                ),
              if (insights.worstDay.isNotEmpty)
                pw.Text(
                  '! Watch out on ${insights.worstDay}s',
                  style: const pw.TextStyle(
                      fontSize: 12, color: PdfColors.grey700),
                ),
              pw.SizedBox(height: 20),
            ],

            // Emotion frequency bars
            if (insights.emotionFrequency.isNotEmpty) ...[
              pw.Text(
                'TOP EMOTIONS',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: _teal,
                  letterSpacing: 1.5,
                ),
              ),
              pw.SizedBox(height: 8),
              ...insights.emotionFrequency.entries.take(5).map((e) {
                final maxVal = insights.emotionFrequency.values.first;
                final pct = maxVal > 0 ? e.value / maxVal : 0.0;
                final filled = (pct * 20).round().clamp(0, 20);
                final bar = '[${('=' * filled).padRight(20, ' ')}]';
                return pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 6),
                  child: pw.Row(children: [
                    pw.SizedBox(
                      width: 90,
                      child: pw.Text(
                        e.key.toUpperCase(),
                        style: pw.TextStyle(
                          fontSize: 9,
                          letterSpacing: 0.5,
                          color: PdfColors.grey800,
                        ),
                      ),
                    ),
                    pw.Text(
                      bar,
                      style: pw.TextStyle(fontSize: 9, color: _teal),
                    ),
                    pw.SizedBox(width: 8),
                    pw.Text(
                      '${e.value}',
                      style: const pw.TextStyle(
                          fontSize: 9, color: PdfColors.grey600),
                    ),
                  ]),
                );
              }),
            ],

            pw.Spacer(),
            _pageFooter(),
          ],
        ),
      ),
    );

    return pdf.save();
  }

  // ─── Shared helpers ───────────────────────────────────────────────────────

  static pw.Widget _pageHeader(String subtitle) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          'EMOTRACE',
          style: pw.TextStyle(
            fontSize: 24,
            fontWeight: pw.FontWeight.bold,
            color: _teal,
          ),
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(
              subtitle,
              style: const pw.TextStyle(
                  fontSize: 12, color: PdfColors.grey600),
            ),
            pw.Text(
              'Generated ${_formatDate(DateTime.now())}',
              style: const pw.TextStyle(
                  fontSize: 9, color: PdfColors.grey400),
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _pageFooter() {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(top: 8),
      child: pw.Column(children: [
        pw.Divider(color: PdfColors.grey300),
        pw.Text(
          'Generated by EMOTRACE - Your Personal Mood Tracker',
          style: const pw.TextStyle(
              fontSize: 9, color: PdfColors.grey400),
          textAlign: pw.TextAlign.center,
        ),
      ]),
    );
  }

  static pw.Widget _statCell(String label, String value) {
    return pw.Column(children: [
      pw.Text(
        value,
        style: pw.TextStyle(
          fontSize: 18,
          fontWeight: pw.FontWeight.bold,
          color: _teal,
        ),
      ),
      pw.SizedBox(height: 2),
      pw.Text(
        label,
        style: const pw.TextStyle(
            fontSize: 8, color: PdfColors.grey600),
      ),
    ]);
  }

  static String _formatDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }
}
