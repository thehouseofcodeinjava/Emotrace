# Beta Completion Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Complete SettingsProvider persistence, NotificationService, PDF export (history + insights), and AppRoutes wiring so the app is fully beta-ready.

**Architecture:** Approach A — new `SettingsService` follows the same pattern as `MoodService` (provider → service → DB). `NotificationService` is wired into `SettingsProvider` so toggle/time changes immediately schedule/cancel. `PdfService` is a static utility called from the two screens. No new providers or models needed.

**Tech Stack:** `sqflite` (existing), `flutter_local_notifications ^17.2.3` (existing), `timezone ^0.9.4` + `flutter_timezone ^1.0.4` (new — required for scheduled notifications), `pdf ^3.10.8` + `printing ^5.13.1` (new).

---

## File Map

| Action | File | Responsibility |
|--------|------|---------------|
| Modify | `pubspec.yaml` | Add pdf, printing, timezone, flutter_timezone |
| Create | `lib/services/settings_service.dart` | DB read/write for settings table |
| Modify | `lib/providers/settings_provider.dart` | Add loadSettings(), persist on every mutator, wire notifications |
| Modify | `lib/services/notification_service.dart` | Full impl: init, scheduleDailyReminder, cancelDailyReminder |
| Modify | `lib/main.dart` | Call NotificationService.init() + SettingsProvider.loadSettings() after DB init |
| Create | `lib/services/pdf_service.dart` | buildHistoryPdf() + buildInsightsPdf() static methods |
| Create | `test/services/pdf_service_test.dart` | Unit tests for both PDF builders |
| Modify | `lib/screens/settings_screen.dart` | Wire Export Data button → PdfService.buildHistoryPdf() |
| Modify | `lib/screens/insights_screen.dart` | Add share icon → PdfService.buildInsightsPdf() |
| Modify | `lib/config/routes.dart` | Remove `/` from routes map (conflicts with home:) |
| Modify | `lib/main.dart` | Add routes: AppRoutes.routes |
| Modify | `lib/screens/home_screen.dart` | Use Navigator.pushNamed for mood entry |
| Modify | `android/app/src/main/AndroidManifest.xml` | Add RECEIVE_BOOT_COMPLETED permission |
| Modify | `HIGHLIGHT.md` | Session 5 update |

---

## Task 1: Add packages to pubspec.yaml

**Files:** Modify `pubspec.yaml`

- [ ] **Step 1: Add dependencies**

Open `pubspec.yaml`. Replace the dependencies block with:

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.2
  sqflite: ^2.3.3+1
  path: ^1.9.0
  uuid: ^4.4.0
  intl: ^0.19.0
  fl_chart: ^0.69.0
  flutter_local_notifications: ^17.2.3
  timezone: ^0.9.4
  flutter_timezone: ^1.0.4
  pdf: ^3.10.8
  printing: ^5.13.1
```

- [ ] **Step 2: Get packages**

```bash
flutter pub get
```

Expected: resolves without conflicts. If version conflict on `pdf` or `printing`, lower to `pdf: ^3.10.0` and `printing: ^5.12.0`.

- [ ] **Step 3: Commit**

```bash
git add pubspec.yaml pubspec.lock
git commit -m "chore: add pdf, printing, timezone, flutter_timezone packages"
```

---

## Task 2: SettingsService

**Files:** Create `lib/services/settings_service.dart`

- [ ] **Step 1: Create the service**

```dart
// Service: SettingsService | Author: Piyush Puri | Date: 13 Apr 2026
// Single responsibility: read/write the settings table via DatabaseService.

import '../models/settings_model.dart';
import 'database_service.dart';

class SettingsService {
  final DatabaseService _db = DatabaseService();

  /// Returns null on first launch (no row in DB yet).
  Future<Settings?> loadSettings(String userId) async {
    final rows = await _db.query(
      'settings',
      where: 'user_id = ?',
      whereArgs: [userId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return Settings.fromMap(rows.first);
  }

  /// Upsert — DatabaseService.insert uses ConflictAlgorithm.replace.
  Future<void> saveSettings(Settings settings) async {
    await _db.insert('settings', settings.toMap());
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/services/settings_service.dart
git commit -m "feat: add SettingsService — DB read/write for settings table"
```

---

## Task 3: SettingsProvider with persistence + notification wiring

**Files:** Modify `lib/providers/settings_provider.dart`

- [ ] **Step 1: Replace the entire file**

The key changes: `loadSettings()` added, each mutator calls `_saveQuietly()` (fire-and-forget async — keeps `void` signatures so `Switch.onChanged` compatibility is preserved), `toggleReminder` and `updateReminderTime` also call `NotificationService`.

```dart
// Provider: SettingsProvider | Author: Rajat Mahajan | Date: 11 Apr 2026
// Persistence + notification wiring: Piyush Puri | Date: 13 Apr 2026

import 'package:flutter/foundation.dart';

import '../models/settings_model.dart';
import '../services/notification_service.dart';
import '../services/settings_service.dart';

class SettingsProvider extends ChangeNotifier {
  static const String _tempUserId = 'local_user_01';

  final SettingsService _settingsService = SettingsService();

  Settings _settings = Settings.defaults(_tempUserId);

  Settings get settings => _settings;
  String get theme => _settings.theme;
  bool get dailyReminderEnabled => _settings.dailyReminderEnabled;
  String get reminderTime => _settings.reminderTime;

  /// Called once from main.dart after DatabaseService.init().
  /// Falls back to Settings.defaults() silently on any error.
  Future<void> loadSettings() async {
    try {
      final saved = await _settingsService.loadSettings(_tempUserId);
      if (saved != null) {
        _settings = saved;
        notifyListeners();
      }
    } catch (_) {
      // defaults already set — never crash on settings load
    }
  }

  void updateTheme(String theme) {
    _settings = _settings.copyWith(theme: theme);
    notifyListeners();
    _saveQuietly();
  }

  void toggleReminder(bool enabled) {
    _settings = _settings.copyWith(dailyReminderEnabled: enabled);
    notifyListeners();
    _saveQuietly().then((_) {
      if (enabled) {
        NotificationService().scheduleDailyReminder(_settings.reminderTime);
      } else {
        NotificationService().cancelDailyReminder();
      }
    });
  }

  void updateReminderTime(String time) {
    _settings = _settings.copyWith(reminderTime: time);
    notifyListeners();
    _saveQuietly().then((_) {
      if (_settings.dailyReminderEnabled) {
        NotificationService().scheduleDailyReminder(time);
      }
    });
  }

  Future<void> _saveQuietly() async {
    try {
      await _settingsService.saveSettings(_settings);
    } catch (_) {
      // state is already updated in memory — DB failure must not block UX
    }
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/providers/settings_provider.dart
git commit -m "feat: SettingsProvider — persist settings to DB, wire notification scheduling"
```

---

## Task 4: NotificationService full implementation + AndroidManifest

**Files:** Modify `lib/services/notification_service.dart`, modify `android/app/src/main/AndroidManifest.xml`

- [ ] **Step 1: Replace notification_service.dart**

```dart
// Service: NotificationService | Author: Rajat Mahajan | Date: 11 Apr 2026
// Full impl: Piyush Puri | Date: 13 Apr 2026
// Daily mood reminder via flutter_local_notifications + timezone.

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static const int _dailyReminderId = 1;
  static bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    // Initialize timezone database and set device local timezone.
    tz.initializeTimeZones();
    try {
      final timezoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timezoneName));
    } catch (_) {
      // Fall back to UTC — notification still fires, just at UTC time.
    }

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );

    // Create the Android notification channel (required for Android 8+).
    const channel = AndroidNotificationChannel(
      'emotrace_daily',
      'Daily Reminder',
      description: 'Daily mood check-in reminder',
      importance: Importance.high,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    _initialized = true;
  }

  /// Schedule a daily repeating notification at [time] ('HH:mm' format).
  /// Cancels any existing schedule first.
  Future<void> scheduleDailyReminder(String time) async {
    final parts = time.split(':');
    final hour = int.tryParse(parts[0]) ?? 20;
    final minute = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;

    await _plugin.cancel(_dailyReminderId);

    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local, now.year, now.month, now.day, hour, minute,
    );
    // If today's time has already passed, schedule for tomorrow.
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      _dailyReminderId,
      'Time to check in 🌿',
      'How are you feeling today?',
      scheduled,
      NotificationDetails(
        android: const AndroidNotificationDetails(
          'emotrace_daily',
          'Daily Reminder',
          channelDescription: 'Daily mood check-in reminder',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexact,
      matchDateTimeComponents: DateTimeComponents.time, // repeats daily
    );
  }

  Future<void> cancelDailyReminder() async {
    await _plugin.cancel(_dailyReminderId);
  }
}
```

- [ ] **Step 2: Add Android permission**

Open `android/app/src/main/AndroidManifest.xml`. Inside `<manifest>` but **before** `<application>`, add:

```xml
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
```

- [ ] **Step 3: Commit**

```bash
git add lib/services/notification_service.dart android/app/src/main/AndroidManifest.xml
git commit -m "feat: NotificationService — daily reminder scheduling via flutter_local_notifications"
```

---

## Task 5: Wire everything in main.dart

**Files:** Modify `lib/main.dart`

- [ ] **Step 1: Update main() and add routes**

Replace `lib/main.dart` entirely:

```dart
// Screen: App Entry Point | Author: Rajat Mahajan | Date: 11 Apr 2026
// Updated: Piyush Puri | Date: 13 Apr 2026
// Wired: DatabaseService.init, NotificationService.init, SettingsProvider.loadSettings

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'config/routes.dart';
import 'config/theme.dart';
import 'providers/auth_provider.dart';
import 'providers/insights_provider.dart';
import 'providers/mood_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/calendar_screen.dart';
import 'screens/home_screen.dart';
import 'screens/insights_screen.dart';
import 'screens/settings_screen.dart';
import 'services/database_service.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseService().init();
  await NotificationService().init();
  runApp(const EmotracApp());
}

class EmotracApp extends StatelessWidget {
  const EmotracApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MoodProvider()),
        ChangeNotifierProvider(create: (_) => InsightsProvider()),
        ChangeNotifierProvider(
          create: (_) => SettingsProvider()..loadSettings(),
        ),
      ],
      child: MaterialApp(
        title: 'EMOTRACE',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const MainNavigation(),
        routes: AppRoutes.routes,
      ),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    CalendarScreen(),
    InsightsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month_outlined),
              activeIcon: Icon(Icons.calendar_month_rounded),
              label: 'Calendar'),
          BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined),
              activeIcon: Icon(Icons.bar_chart_rounded),
              label: 'Insights'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings_rounded),
              label: 'Settings'),
        ],
      ),
    );
  }
}
```

Note: `SettingsProvider()..loadSettings()` calls `loadSettings()` immediately after construction. The `..` cascade fires the future but doesn't await it — settings load asynchronously in the background, UI shows defaults then rebuilds when loaded.

- [ ] **Step 2: Update routes.dart — remove '/' route to avoid conflict with home:**

Replace `lib/config/routes.dart`:

```dart
// Config: AppRoutes | Author: Rajat Mahajan | Date: 11 Apr 2026
// Updated: Piyush Puri | Date: 13 Apr 2026
// Note: '/' intentionally excluded — home: MainNavigation handles root.

import 'package:flutter/material.dart';

import '../screens/mood_entry_screen.dart';

class AppRoutes {
  static const String home      = '/';
  static const String moodEntry = '/mood-entry';
  static const String calendar  = '/calendar';
  static const String insights  = '/insights';
  static const String settings  = '/settings';

  /// Named routes registered in MaterialApp.
  /// '/' excluded — handled by MaterialApp(home: MainNavigation()).
  static Map<String, WidgetBuilder> get routes => {
    moodEntry: (_) => const MoodEntryScreen(),
  };
}
```

- [ ] **Step 3: Update HomeScreen._goToMoodEntry to use named route**

In `lib/screens/home_screen.dart`, find `_goToMoodEntry()` and replace its body:

```dart
void _goToMoodEntry() {
  Navigator.pushNamed(context, AppRoutes.moodEntry)
      .then((_) => context.read<MoodProvider>().loadEntries());
}
```

Also add the import at the top of `home_screen.dart`:
```dart
import '../config/routes.dart';
```

And remove the now-unused import:
```dart
// Remove this line:
import 'mood_entry_screen.dart';
```

- [ ] **Step 4: Commit**

```bash
git add lib/main.dart lib/config/routes.dart lib/screens/home_screen.dart
git commit -m "feat: wire NotificationService.init + SettingsProvider.loadSettings in main, add named routes"
```

---

## Task 6: PdfService + unit tests

**Files:** Create `lib/services/pdf_service.dart`, create `test/services/pdf_service_test.dart`

- [ ] **Step 1: Write the failing tests first**

Create `test/services/pdf_service_test.dart`:

```dart
// Test: PdfService | Author: Piyush Puri | Date: 13 Apr 2026

import 'package:flutter_test/flutter_test.dart';
import 'package:emotrace/models/mood_entry_model.dart';
import 'package:emotrace/services/insight_service.dart';
import 'package:emotrace/services/pdf_service.dart';

void main() {
  final now = DateTime.now();

  final sampleEntries = List.generate(5, (i) => MoodEntry(
    id: 'id_$i',
    userId: 'local_user_01',
    moodScore: 5 + i % 5,
    emotionTags: ['calm', 'happy'],
    notes: 'Note $i',
    createdAt: now.subtract(Duration(days: i)),
    updatedAt: now.subtract(Duration(days: i)),
  ));

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
    test('returns non-empty bytes', () async {
      final bytes = await PdfService.buildHistoryPdf(
        sampleEntries, 5, 12,
      );
      expect(bytes, isNotEmpty);
      expect(bytes.length, greaterThan(500));
    });

    test('returns bytes for empty entry list', () async {
      final bytes = await PdfService.buildHistoryPdf([], 0, 0);
      expect(bytes, isNotEmpty);
    });
  });

  group('PdfService.buildInsightsPdf', () {
    test('returns non-empty bytes', () async {
      final bytes = await PdfService.buildInsightsPdf(
        sampleInsights, sampleEntries,
      );
      expect(bytes, isNotEmpty);
      expect(bytes.length, greaterThan(500));
    });

    test('returns bytes when insights has no patterns', () async {
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
```

- [ ] **Step 2: Run tests — expect failure (PdfService not defined)**

```bash
flutter test test/services/pdf_service_test.dart
```

Expected: compile error — `package:emotrace/services/pdf_service.dart` not found.

- [ ] **Step 3: Create PdfService**

Create `lib/services/pdf_service.dart`:

```dart
// Service: PdfService | Author: Piyush Puri | Date: 13 Apr 2026
// Static PDF builders for mood history and insights reports.
// Consumers call Printing.sharePdf(bytes: await PdfService.buildXxx(...)).

import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../config/constants.dart';
import '../models/mood_entry_model.dart';
import 'insight_service.dart';

class PdfService {
  // Brand colour
  static final PdfColor _teal = PdfColor(6 / 255, 214 / 255, 160 / 255);

  // ─── History PDF ─────────────────────────────────────────────────────────

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
          // Summary row
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
              headerDecoration:
                  pw.BoxDecoration(color: PdfColor(28 / 255, 27 / 255, 27 / 255)),
              cellStyle: const pw.TextStyle(fontSize: 9),
              cellHeight: 28,
              columnWidths: {
                0: const pw.FixedColumnWidth(72),
                1: const pw.FixedColumnWidth(52),
                2: const pw.FlexColumnWidth(1.5),
                3: const pw.FlexColumnWidth(2),
              },
              data: entries.map((e) {
                final emoji = AppConstants.moodEmojis[e.moodScore] ?? '';
                return [
                  _formatDate(e.createdAt),
                  '${e.moodScore}/10 $emoji',
                  e.emotionTags.isEmpty ? '—' : e.emotionTags.join(', '),
                  e.notes.isEmpty
                      ? '—'
                      : e.notes.length > 60
                          ? '${e.notes.substring(0, 60)}…'
                          : e.notes,
                ];
              }).toList(),
            ),
        ],
      ),
    );

    return pdf.save();
  }

  // ─── Insights PDF ────────────────────────────────────────────────────────

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
              '${_formatDate(from)}  –  ${_formatDate(now)}',
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey500),
            ),
            pw.Divider(color: PdfColors.grey300),
            pw.SizedBox(height: 20),

            // Hero
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
                  letterSpacing: 1.5),
            ),
            pw.Text(
              'Avg mood: ${insights.averageMood.toStringAsFixed(1)}  ·  '
              'Streak: ${insights.currentStreak} days  ·  '
              'Entries: ${entries.length}',
              style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey600),
            ),
            pw.SizedBox(height: 20),

            // Patterns
            if (insights.bestDay.isNotEmpty || insights.worstDay.isNotEmpty) ...[
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
                pw.Text('✓  You feel better on ${insights.bestDay}s',
                    style: const pw.TextStyle(fontSize: 12)),
              if (insights.worstDay.isNotEmpty)
                pw.Text('△  Watch out on ${insights.worstDay}s',
                    style: const pw.TextStyle(
                        fontSize: 12, color: PdfColors.grey700)),
              pw.SizedBox(height: 20),
            ],

            // Top emotions
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
                            color: PdfColors.grey800),
                      ),
                    ),
                    pw.Text(
                      '█' * filled + '░' * (20 - filled),
                      style: pw.TextStyle(fontSize: 9, color: _teal),
                    ),
                    pw.SizedBox(width: 8),
                    pw.Text('${e.value}',
                        style: const pw.TextStyle(
                            fontSize: 9, color: PdfColors.grey600)),
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

  // ─── Shared helpers ──────────────────────────────────────────────────────

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
        pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
          pw.Text(subtitle,
              style: const pw.TextStyle(
                  fontSize: 12, color: PdfColors.grey600)),
          pw.Text(
            'Generated ${_formatDate(DateTime.now())}',
            style:
                const pw.TextStyle(fontSize: 9, color: PdfColors.grey400),
          ),
        ]),
      ],
    );
  }

  static pw.Widget _pageFooter() {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(top: 8),
      child: pw.Column(children: [
        pw.Divider(color: PdfColors.grey300),
        pw.Text(
          'Generated by EMOTRACE — Your Personal Mood Tracker',
          style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey400),
          textAlign: pw.TextAlign.center,
        ),
      ]),
    );
  }

  static pw.Widget _statCell(String label, String value) {
    return pw.Column(children: [
      pw.Text(value,
          style: pw.TextStyle(
              fontSize: 18, fontWeight: pw.FontWeight.bold, color: _teal)),
      pw.SizedBox(height: 2),
      pw.Text(label,
          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
    ]);
  }

  static String _formatDate(DateTime d) {
    const months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }
}
```

- [ ] **Step 4: Run tests — expect pass**

```bash
flutter test test/services/pdf_service_test.dart
```

Expected:
```
00:XX +4: All tests passed!
```

If any test fails with a PDF package error, ensure `flutter pub get` ran successfully.

- [ ] **Step 5: Commit**

```bash
git add lib/services/pdf_service.dart test/services/pdf_service_test.dart
git commit -m "feat: PdfService — buildHistoryPdf + buildInsightsPdf; 4 tests passing"
```

---

## Task 7: Wire Export Data button in SettingsScreen

**Files:** Modify `lib/screens/settings_screen.dart`

- [ ] **Step 1: Add printing import at the top of settings_screen.dart**

After the existing imports, add:

```dart
import 'package:printing/printing.dart';
import '../providers/mood_provider.dart';
import '../services/pdf_service.dart';
```

- [ ] **Step 2: Replace _showComingSoon call and update subtitle for Export Data tile**

Find this block (lines 70-80):

```dart
_SettingsTile(
  icon: Icons.download_rounded,
  iconColor: AppTheme.teal,
  title: 'Export Data',
  subtitle: 'Download all your mood entries as CSV',
  trailing: const Icon(
    Icons.chevron_right_rounded,
    color: AppTheme.textSecondary,
  ),
  onTap: () => _showComingSoon(context, 'Export Data'),
),
```

Replace with:

```dart
_SettingsTile(
  icon: Icons.download_rounded,
  iconColor: AppTheme.teal,
  title: 'Export Mood History',
  subtitle: 'Share all your mood entries as a PDF report',
  trailing: const Icon(
    Icons.chevron_right_rounded,
    color: AppTheme.textSecondary,
  ),
  onTap: () => _exportHistoryPdf(context),
),
```

- [ ] **Step 3: Add _exportHistoryPdf method to SettingsScreen class**

Inside the `SettingsScreen` class (after `_showComingSoon`), add:

```dart
Future<void> _exportHistoryPdf(BuildContext context) async {
  final moodProvider = context.read<MoodProvider>();
  try {
    final bytes = await PdfService.buildHistoryPdf(
      moodProvider.entries,
      moodProvider.currentStreak,
      moodProvider.longestStreak,
    );
    await Printing.sharePdf(
      bytes: bytes,
      name:
          'emotrace_history_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to generate PDF. Please try again.'),
          backgroundColor: AppTheme.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
```

- [ ] **Step 4: Commit**

```bash
git add lib/screens/settings_screen.dart
git commit -m "feat: Settings — Export Mood History button generates and shares PDF"
```

---

## Task 8: Wire Share icon in InsightsScreen

**Files:** Modify `lib/screens/insights_screen.dart`

- [ ] **Step 1: Add imports**

After the existing imports in `insights_screen.dart`, add:

```dart
import 'package:printing/printing.dart';
import '../services/pdf_service.dart';
```

- [ ] **Step 2: Add actions to SliverAppBar**

Find the `SliverAppBar` widget (around line 64). It currently has no `actions`. Replace:

```dart
SliverAppBar(
  pinned: true,
  backgroundColor: AppTheme.background,
  title: const Text('EMOTRACE',
      style: TextStyle(
        color: AppTheme.teal,
        fontSize: 22,
        fontWeight: FontWeight.w900,
        letterSpacing: -0.5,
      )),
  elevation: 0,
),
```

With:

```dart
SliverAppBar(
  pinned: true,
  backgroundColor: AppTheme.background,
  title: const Text('EMOTRACE',
      style: TextStyle(
        color: AppTheme.teal,
        fontSize: 22,
        fontWeight: FontWeight.w900,
        letterSpacing: -0.5,
      )),
  elevation: 0,
  actions: [
    if (insights != null && insights.hasData)
      IconButton(
        icon: const Icon(Icons.ios_share_rounded,
            color: AppTheme.textSecondary),
        tooltip: 'Share Insights PDF',
        onPressed: () =>
            _shareInsightsPdf(context, insights, entries),
      ),
  ],
),
```

Note: `insights` and `entries` are already in scope inside the `Consumer2` builder where this `SliverAppBar` lives.

- [ ] **Step 3: Add _shareInsightsPdf method to _InsightsScreenState class**

Inside `_InsightsScreenState`, add:

```dart
Future<void> _shareInsightsPdf(
  BuildContext context,
  Insights insights,
  List entries,
) async {
  try {
    final bytes = await PdfService.buildInsightsPdf(
      insights,
      entries.cast(),
    );
    await Printing.sharePdf(
      bytes: bytes,
      name:
          'emotrace_insights_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to generate PDF. Please try again.'),
          backgroundColor: AppTheme.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
```

- [ ] **Step 4: Commit**

```bash
git add lib/screens/insights_screen.dart
git commit -m "feat: Insights — share icon generates and shares 30-day PDF report"
```

---

## Task 9: Final verification

**Files:** All

- [ ] **Step 1: Run flutter analyze**

```bash
flutter analyze
```

Expected: `No issues found!`

If there are any import errors (e.g. unused import from removed `mood_entry_screen.dart` import in home_screen.dart), fix them and re-run.

- [ ] **Step 2: Run all tests**

```bash
flutter test
```

Expected: `All tests passed!` (4 tests in pdf_service_test.dart).

- [ ] **Step 3: Update HIGHLIGHT.md**

Update Last Session, mark tasks done, add all new/modified files to COMPLETED FILES, add CROSS-DEPENDENCY FLAGS entry, update FOLDER SNAPSHOT, add new commits to COMMIT HISTORY.

New files to add to COMPLETED FILES:
- `lib/services/settings_service.dart`
- `lib/services/pdf_service.dart`
- `test/services/pdf_service_test.dart`

Modified files to update dates:
- `lib/main.dart` → 13 Apr 2026
- `lib/providers/settings_provider.dart` → 13 Apr 2026
- `lib/services/notification_service.dart` → 13 Apr 2026
- `lib/screens/settings_screen.dart` → 13 Apr 2026
- `lib/screens/insights_screen.dart` → 13 Apr 2026
- `lib/config/routes.dart` → 13 Apr 2026
- `lib/screens/home_screen.dart` → 13 Apr 2026
- `android/app/src/main/AndroidManifest.xml` → 13 Apr 2026
- `pubspec.yaml` → 13 Apr 2026

- [ ] **Step 4: Final commit + push**

```bash
git add HIGHLIGHT.md
git commit -m "docs: HIGHLIGHT.md — Session 5 update, beta completion"
git push origin feature/mood_to_tracker_2
```

---

## Self-Review

**Spec coverage check:**
- ✅ SettingsProvider persistence → Task 2 + 3
- ✅ NotificationService full impl → Task 4
- ✅ Wire notification in SettingsProvider → Task 3
- ✅ Wire NotificationService.init in main → Task 5
- ✅ SettingsProvider.loadSettings wired in main → Task 5
- ✅ PDF history export from Settings → Task 6 + 7
- ✅ PDF insights export from Insights → Task 6 + 8
- ✅ AppRoutes wiring → Task 5 (routes: AppRoutes.routes added)
- ✅ AppRoutes conflict with home: fixed → Task 5 (routes.dart updated)
- ✅ HomeScreen uses named route → Task 5
- ✅ AndroidManifest permissions → Task 4
- ✅ Tests for PdfService → Task 6
- ✅ HIGHLIGHT.md update → Task 9
- ✅ flutter analyze clean → Task 9

**Placeholder scan:** No TBDs, no "similar to Task N", all code is complete.

**Type consistency:**
- `PdfService.buildHistoryPdf(List<MoodEntry>, int, int)` → used in Task 7 with `moodProvider.entries, moodProvider.currentStreak, moodProvider.longestStreak` ✅
- `PdfService.buildInsightsPdf(Insights, List<MoodEntry>)` → used in Task 8 with `insights, entries.cast()` ✅
- `SettingsService.loadSettings(String)` → called in `SettingsProvider.loadSettings()` with `_tempUserId` ✅
- `SettingsService.saveSettings(Settings)` → called with `_settings` ✅
- `NotificationService().scheduleDailyReminder(String)` → called with `_settings.reminderTime` ✅
- `AppRoutes.routes` → returns `Map<String, WidgetBuilder>` with only `moodEntry` key ✅
