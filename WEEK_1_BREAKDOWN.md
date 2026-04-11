# EMOTRACE Week 1: Setup + Foundation (60 hours)

**Timeline:** Monday-Friday, 60 hours total (10-12 hrs/day)  
**Goal:** Have a working Flutter app with database + blank screens ready for content

---

## DAY 1 (Monday) - Environment + Project Setup

### Morning (4 hours)
- [ ] Install Flutter SDK (if not already done)
- [ ] Install Android Studio + Xcode (Mac only)
- [ ] Create new Flutter project: `flutter create emotrace`
- [ ] Create folder structure (lib/, test/, assets/)
- [ ] Verify project compiles: `flutter run`
- [ ] Create GitHub repo "emotrace"
- [ ] Push empty project to GitHub

**Deliverable:** Empty Flutter app that compiles and is on GitHub

### Afternoon (4 hours)
- [ ] Create all folders in lib/ (models/, services/, providers/, screens/, widgets/, config/, utils/)
- [ ] Create empty.dart files in each folder (placeholder)
- [ ] Update pubspec.yaml with all dependencies (provider, sqflite, intl, uuid, etc.)
- [ ] Run `flutter pub get`
- [ ] Verify all imports work without errors

**Deliverable:** Project structure complete, dependencies installed

---

## DAY 2 (Tuesday) - Theme + Config

### Morning (5 hours)
- [ ] Create lib/config/theme.dart
  - Define colors: teal #06D6A0, orange #F77F00, red #E63946
  - Define TextThemes (heading, body, caption)
  - Create dark theme + light theme (for future)
  - Create mood color mapping (1=red, 2=orange, ..., 10=darkgreen)
- [ ] Create lib/config/constants.dart
  - Emotion options: ["anxious", "calm", "stressed", "happy", "sad", "grateful", "overwhelmed", "focused"]
  - Max notes length: 500
  - Min/max mood: 1-10
- [ ] Create lib/utils/color_utils.dart
  - Function: `Color getMoodColor(int moodScore)` → returns color for mood
  - Function: `String getMoodLabel(int moodScore)` → returns "VIBE: BALANCED" etc.

### Afternoon (5 hours)
- [ ] Create lib/models/ (data classes)
  - user_model.dart: User class (id, name, email, password_hash, created_at)
  - mood_entry_model.dart: MoodEntry class (id, moodScore, emotions[], notes, created_at)
  - emotion_model.dart: Emotion class (id, name)
  - settings_model.dart: Settings class (theme, remindersEnabled, reminderTime)

**Deliverable:** Theme system + data models ready

**Code Example - theme.dart:**
```dart
class AppTheme {
  static final darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Color(0xFF121212),
    primaryColor: Color(0xFF06D6A0), // Teal
    colorScheme: ColorScheme.dark(
      primary: Color(0xFF06D6A0),
      secondary: Color(0xFFF77F00), // Orange
    ),
  );
}

// Mood color mapping
const Map<int, Color> MOOD_COLORS = {
  1: Color(0xFFE63946), // Red
  2: Color(0xFFF77F00), // Orange
  3: Color(0xFFFFD60A), // Yellow
  // ... up to 10
};
```

---

## DAY 3 (Wednesday) - Database Layer

### Morning (6 hours)
- [ ] Create lib/services/database_service.dart
  - Initialize SQLite database
  - Create tables (users, mood_entries, emotion_tags, settings, sessions)
  - Handle migrations
  - Test: Can create, read, update, delete records
- [ ] Run DATABASE_SCHEMA.sql to create tables
- [ ] Test database operations:
  - Save a test mood entry
  - Read it back
  - Verify data persisted

### Afternoon (4 hours)
- [ ] Create lib/services/mood_service.dart
  - `Future<void> saveMoodEntry(MoodEntry entry)`
  - `Future<List<MoodEntry>> getMoodEntries(int days)`
  - `Future<MoodEntry?> getTodaysMood()`
  - Test all CRUD operations

**Deliverable:** SQLite database fully working

**Code Example - database_service.dart:**
```dart
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  
  factory DatabaseService() => _instance;
  
  DatabaseService._internal();
  
  late Database _db;
  
  Future<void> init() async {
    final dbPath = await getDatabasesPath();
    _db = await openDatabase(
      join(dbPath, 'emotrace.db'),
      version: 1,
      onCreate: _createTables,
    );
  }
  
  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password_hash TEXT NOT NULL,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    ''');
    // ... rest of tables
  }
  
  Future<int> insertMoodEntry(Map<String, dynamic> entry) async {
    return await _db.insert('mood_entries', entry);
  }
}
```

---

## DAY 4 (Thursday) - State Management

### Morning (5 hours)
- [ ] Create lib/providers/mood_provider.dart
  - Extend ChangeNotifier
  - List<MoodEntry> _entries = []
  - addMoodEntry() → saves to DB + notifies listeners
  - loadEntries() → loads from DB
  - getTodaysMood() → returns today's mood or null
  - getRecentEntries(int count) → last 3 entries
- [ ] Create lib/providers/settings_provider.dart
  - theme (dark/light)
  - remindersEnabled
  - reminderTime
  - Save/load from database

### Afternoon (5 hours)
- [ ] Create lib/providers/auth_provider.dart (basic, for future use)
  - currentUser property
  - login() → for Month 2
  - logout() → for Month 2
- [ ] Set up Provider in main.dart
  - Wrap MaterialApp with MultiProvider
  - Add MoodProvider, SettingsProvider, AuthProvider

**Deliverable:** State management working, providers integrated

**Code Example - mood_provider.dart:**
```dart
class MoodProvider extends ChangeNotifier {
  final MoodService _moodService = MoodService();
  List<MoodEntry> _entries = [];
  
  List<MoodEntry> get entries => _entries;
  
  Future<void> addMoodEntry(int score, List<String> emotions, String notes) async {
    final entry = MoodEntry(
      id: uuid.v4(),
      moodScore: score,
      emotions: emotions,
      notes: notes,
      createdAt: DateTime.now(),
    );
    
    await _moodService.saveMoodEntry(entry);
    _entries.add(entry);
    notifyListeners();
  }
  
  Future<void> loadEntries(int days) async {
    _entries = await _moodService.getMoodEntries(days);
    notifyListeners();
  }
}
```

---

## DAY 5 (Friday) - Screens Skeleton + Navigation

### Morning (4 hours)
- [ ] Create 5 blank screen files:
  - lib/screens/home_screen.dart
  - lib/screens/mood_entry_screen.dart
  - lib/screens/calendar_screen.dart
  - lib/screens/insights_screen.dart
  - lib/screens/settings_screen.dart
- [ ] Each screen has basic structure:
  ```dart
  class HomeScreen extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(title: Text('EMOTRACE')),
        body: Center(child: Text('Home Screen')),
      );
    }
  }
  ```
- [ ] Create lib/config/routes.dart for navigation

### Afternoon (6 hours)
- [ ] Create lib/widgets/bottom_nav_bar.dart
  - 4 tabs: Home, Calendar, Insights, Settings
  - Icons: Home, Calendar, Chart, Settings
  - Highlight active tab
- [ ] Integrate into main.dart:
  - Use StatefulWidget for tab switching
  - Bottom nav switches between screens
- [ ] Test: Can tap tabs and switch screens

**Deliverable:** 5 blank screens + bottom navigation working

**Code Example - main.dart:**
```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MoodProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return MaterialApp(
            theme: AppTheme.darkTheme,
            home: HomeWidget(),
          );
        },
      ),
    );
  }
}

class HomeWidget extends StatefulWidget {
  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  int _currentIndex = 0;
  
  final List<Widget> _screens = [
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
        items: [...],
      ),
    );
  }
}
```

---

## WEEK 1 SUMMARY

| Day | Tasks | Hours | Deliverable |
|-----|-------|-------|-------------|
| Mon | Setup + Project | 8 | Empty Flutter app on GitHub |
| Tue | Theme + Config + Models | 10 | Theme system + data classes |
| Wed | Database setup | 10 | SQLite working, CRUD tested |
| Thu | State management | 10 | Providers integrated |
| Fri | Screens skeleton + Nav | 10 | 5 blank screens + working nav |
| **Total** | | **48** | **Ready for Week 2** |

---

## SUCCESS CRITERIA (Week 1 Complete When...)

✅ App compiles without errors  
✅ Can run on emulator/device  
✅ Database tables created  
✅ Can save/load mood entries from database  
✅ State management working (providers integrated)  
✅ Can navigate between 5 screens using bottom nav  
✅ Code committed to GitHub  
✅ All files in correct folders  
✅ No warnings in console  

---

## TESTING (Day 5 Afternoon)

```dart
// Test database
void testDatabase() async {
  final db = DatabaseService();
  await db.init();
  
  final entry = MoodEntry(
    id: '1',
    moodScore: 7,
    emotions: ['calm', 'focused'],
    notes: 'Great day!',
    createdAt: DateTime.now(),
  );
  
  await db.saveMoodEntry(entry);
  final saved = await db.getMoodEntry('1');
  
  assert(saved!.moodScore == 7);
  print('✓ Database test passed');
}

// Test state management
void testProvider() {
  final provider = MoodProvider();
  provider.addMoodEntry(7, ['calm'], 'Great!');
  
  assert(provider.entries.length == 1);
  assert(provider.entries[0].moodScore == 7);
  print('✓ Provider test passed');
}
```

---

## Common Pitfalls to Avoid

❌ Forgetting to run `flutter pub get`  
❌ Wrong folder structure (will cause import errors)  
❌ Not creating indexes in database (slow queries later)  
❌ Forgetting to initialize database in main.dart  
❌ Mixing state management logic in screens  

---

## NEXT WEEK (Week 2) Preview

Once Week 1 is complete:
- Week 2: Build Home Dashboard screen
- Week 3: Build Mood Entry screen
- Week 4: Build Calendar + Insights
- Week 5: Build Settings
- Week 6: Patterns/algorithms
- Week 7: Testing + polish
- Week 8: App store submission

---

*EMOTRACE Week 1 Breakdown*  
*April 11, 2026*
