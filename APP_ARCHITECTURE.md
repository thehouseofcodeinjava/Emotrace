# EMOTRACE App Architecture

## System Overview

```
┌─────────────────────────────────────────────┐
│           User Interface (5 Screens)        │
├─────────────────────────────────────────────┤
│  Home │ Mood Entry │ Calendar │ Insights │ Settings
└─────────────────────────────────────────────┘
              ↓ (User Interactions)
┌─────────────────────────────────────────────┐
│      State Management (Provider)            │
├─────────────────────────────────────────────┤
│ Auth │ Mood │ Insights │ Settings Providers
└─────────────────────────────────────────────┘
              ↓ (Read/Write State)
┌─────────────────────────────────────────────┐
│        Business Logic (Services)            │
├─────────────────────────────────────────────┤
│ MoodService │ InsightService │ AuthService
└─────────────────────────────────────────────┘
              ↓ (Query/Calculate)
┌─────────────────────────────────────────────┐
│      Local Data (SQLite Database)          │
├─────────────────────────────────────────────┤
│ Users │ MoodEntries │ EmotionTags │ Settings
└─────────────────────────────────────────────┘
```

---

## Data Flow: User Logs a Mood

```
1. User taps "+ Log Mood" on Home Screen
   ↓
2. Opens Mood Entry Screen
   ↓
3. User selects: Mood (7/10) + Emotions (Calm, Focused) + Notes
   ↓
4. User taps "Save Mood Entry"
   ↓
5. MoodProvider.addMoodEntry() called
   ↓
6. MoodService.saveMoodEntry() → SQLite database
   ↓
7. Create mood_entry record with:
   - id: UUID
   - user_id: current_user.id
   - mood_score: 7
   - emotion_tags: ["calm", "focused"]
   - notes: "Had a productive day"
   - created_at: now()
   ↓
8. Database returns success
   ↓
9. Provider updates state
   ↓
10. UI rebuilds → Shows "✓ Saved!"
    ↓
11. Home Screen updates:
    - Today's mood shows 7/10
    - Streak updates
    - Recent entries refreshed
```

---

## Data Flow: User Views Insights

```
1. User taps "Insights" tab
   ↓
2. Insights Screen loads
   ↓
3. InsightsProvider.getInsights() called
   ↓
4. InsightService calculates:
   ├─ Mood stability score (avg of last 30 days)
   ├─ Trend (up/down from last week)
   ├─ Day-of-week patterns (which day best mood?)
   ├─ Emotion frequency (which emotions most common?)
   └─ Pattern alerts (anxiety peaks on Mondays?)
   ↓
5. All data returned to Provider
   ↓
6. UI renders:
   - Stability score: 7.2/10 with trend
   - Line chart showing last 30 days
   - Pattern cards ("You feel better on Tuesdays")
   - Emotion frequency bars
```

---

## Database Operations

### 1. CREATE Mood Entry
```
Input: mood_score=7, emotions=["calm","focused"], notes="Great day"
→ MoodService.saveMoodEntry()
→ SQLite INSERT into mood_entries
→ SQLite INSERT into emotion_tags (one per emotion)
→ Return mood_entry_id
```

### 2. READ Mood Entries
```
Input: user_id, date_range
→ MoodService.getMoodEntries(user_id, fromDate, toDate)
→ SQLite SELECT * FROM mood_entries WHERE user_id=? AND created_at BETWEEN ? AND ?
→ SQLite SELECT * FROM emotion_tags WHERE mood_entry_id IN (...)
→ Return List<MoodEntry>
```

### 3. READ Insights
```
Input: user_id
→ InsightService.getInsights(user_id)
→ SQLite SELECT mood_score FROM mood_entries WHERE user_id=? AND created_at >= (30 days ago)
→ Calculate:
   - Average mood score
   - Standard deviation (stability)
   - Group by day_of_week
   - Count emotion frequencies
→ Return Insights object
```

### 4. UPDATE Settings
```
Input: theme='dark', reminder_time='20:00'
→ SettingsService.updateSettings(user_id, settings)
→ SQLite UPDATE settings WHERE user_id=?
→ Return updated Settings
```

---

## State Management Architecture

### MoodProvider (with Provider package)
```dart
// Controls mood entry state
class MoodProvider extends ChangeNotifier {
  List<MoodEntry> _entries = [];
  
  Future<void> addMoodEntry(int moodScore, List<String> emotions, String notes) async {
    final entry = await MoodService.saveMoodEntry(...);
    _entries.add(entry);
    notifyListeners(); // UI rebuilds
  }
  
  Future<void> loadEntries(int days) async {
    _entries = await MoodService.getMoodEntries(days);
    notifyListeners();
  }
}
```

### InsightsProvider
```dart
class InsightsProvider extends ChangeNotifier {
  Insights _insights = Insights.empty();
  
  Future<void> calculateInsights() async {
    _insights = await InsightService.getInsights();
    notifyListeners();
  }
}
```

### AuthProvider
```dart
class AuthProvider extends ChangeNotifier {
  User? _user;
  
  Future<void> login(email, password) async {
    _user = await AuthService.login(email, password);
    notifyListeners();
  }
  
  Future<void> logout() async {
    await AuthService.logout();
    _user = null;
    notifyListeners();
  }
}
```

---

## Key Algorithms

### 1. Streak Calculation
```
Logic:
- Get all mood entries ordered by date DESC
- Start from today
- Count consecutive days with entries
- Stop at first missing day
- Return current_streak_count

Example:
Today (4/11): Entry exists ✓
Yesterday (4/10): Entry exists ✓
Day before (4/9): Entry exists ✓
Day before (4/8): NO entry ✗
→ Current streak = 3 days
```

### 2. Mood Stability (Standard Deviation)
```
Logic:
- Get all mood scores from last 30 days
- Calculate average
- Calculate standard deviation
- Return as score out of 10
- Lower SD = more stable = higher score

Example:
Scores: [7, 8, 7, 6, 8, 7, 8]
Average: 7.3
SD: 0.75
Stability Score: 8.2/10
```

### 3. Day-of-Week Pattern Detection
```
Logic:
- Get all mood entries from last 90 days
- Group by day-of-week (Monday, Tuesday, etc.)
- Calculate average mood for each day
- Find day with highest average
- Return insight: "You feel better on [Day]"

Example:
Monday avg: 5.8
Tuesday avg: 7.4 ← Highest!
Wednesday avg: 6.2
...
→ "You feel better on Tuesdays"
```

### 4. Emotion Frequency
```
Logic:
- Get all mood entries from last 30 days
- Count occurrences of each emotion tag
- Sort by frequency DESC
- Return top 5-8 emotions with counts

Example:
Calm: 12 times
Stressed: 8 times
Happy: 6 times
→ Display as bars/counts
```

---

## Error Handling

### Database Errors
```
if (database.getError) {
  Show toast: "Error saving mood. Please try again."
  Log error to console
  Don't update UI
}
```

### Validation Errors
```
if (moodScore < 1 || moodScore > 10) {
  Show error: "Please select mood 1-10"
  Disable Save button
}

if (notes.length > 500) {
  Show error: "Notes limited to 500 characters"
}
```

### Missing Data
```
if (no entries for insights) {
  Show empty state: "Need 3+ entries to show patterns"
  Don't show charts/patterns
}
```

---

## Performance Considerations

### 1. Lazy Loading
- Load only last 30 days of moods on app start
- Load calendar heatmap on demand
- Cache insights for 1 hour

### 2. Indexing
- Index mood_entries by user_id
- Index mood_entries by created_at
- Speeds up queries significantly

### 3. Batching
- Save multiple emotion tags in single INSERT
- Load emotions with mood_entries in single query

### 4. Memory Management
- Don't load all mood entries at once
- Use pagination for calendar (load month at a time)
- Clear old cached data

---

## Security

### 1. Local JWT Tokens
- Generated on login
- Stored in secure storage (encrypted)
- Checked on app startup
- Auto-logout if expired

### 2. Password Hashing
- Store password_hash, never plain text
- Use crypto.bcrypt
- Verify on login

### 3. Data Privacy
- ALL data stays on user's device
- No network requests
- No cloud storage
- User can delete all data anytime

---

## Testing Strategy

### Unit Tests
- Test mood color mapping
- Test streak calculation
- Test date utilities
- Test insights algorithms

### Widget Tests
- Test mood scale interaction
- Test emotion tag selection
- Test save button behavior

### Integration Tests
- Test full mood entry flow
- Test data persistence
- Test insights generation

---

## Notes for Development

1. **Start with Database** — Set up SQLite first, test CRUD operations
2. **Then Auth** — Even though no login screen, keep auth logic ready for Month 2
3. **Then Screens** — Build each screen, connect to providers
4. **Then Algorithms** — Implement streak, stability, patterns
5. **Then Polish** — Animations, empty states, error handling
6. **Then Testing** — Write tests for critical paths

---

*EMOTRACE App Architecture*  
*April 11, 2026*
