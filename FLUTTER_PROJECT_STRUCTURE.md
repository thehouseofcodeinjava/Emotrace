# EMOTRACE Flutter Project Structure

```
emotrace/
│
├── lib/
│   ├── main.dart                 # App entry point
│   ├── config/
│   │   ├── theme.dart            # Colors, TextThemes, dark/light modes
│   │   ├── constants.dart        # App constants, mood colors, etc.
│   │   └── routes.dart           # Navigation routes
│   │
│   ├── models/
│   │   ├── user_model.dart       # User class
│   │   ├── mood_entry_model.dart # MoodEntry class
│   │   ├── emotion_model.dart    # Emotion class
│   │   └── settings_model.dart   # Settings class
│   │
│   ├── services/
│   │   ├── database_service.dart # SQLite operations
│   │   ├── auth_service.dart     # Authentication (local JWT)
│   │   ├── mood_service.dart     # Mood entry CRUD
│   │   ├── insight_service.dart  # Pattern detection algorithms
│   │   └── notification_service.dart # Push notifications
│   │
│   ├── providers/
│   │   ├── auth_provider.dart    # Auth state
│   │   ├── mood_provider.dart    # Mood entries state
│   │   ├── insights_provider.dart # Insights state
│   │   └── settings_provider.dart # Settings state
│   │
│   ├── screens/
│   │   ├── home_screen.dart      # Home Dashboard
│   │   ├── mood_entry_screen.dart # Mood Entry (mood + emotions + notes)
│   │   ├── calendar_screen.dart  # Calendar heatmap
│   │   ├── insights_screen.dart  # Insights/patterns
│   │   └── settings_screen.dart  # Settings
│   │
│   ├── widgets/
│   │   ├── mood_scale_widget.dart    # 1-10 mood scale with emojis
│   │   ├── emotion_tag_selector.dart # Emotion selection chips
│   │   ├── calendar_heatmap.dart     # Calendar grid
│   │   ├── streak_counter.dart       # Streak badge
│   │   ├── mood_chart.dart           # Line chart for trends
│   │   ├── bottom_nav_bar.dart       # Bottom navigation
│   │   └── mood_entry_card.dart      # Mood entry summary card
│   │
│   └── utils/
│       ├── date_utils.dart       # Date formatting, streak calculation
│       ├── color_utils.dart      # Mood color mapping
│       └── validation_utils.dart # Input validation
│
├── test/
│   ├── unit/
│   │   ├── models_test.dart
│   │   ├── services_test.dart
│   │   └── utils_test.dart
│   ├── widget/
│   │   └── screens_test.dart
│   └── integration/
│       └── app_test.dart
│
├── assets/
│   ├── images/
│   │   ├── logo.png
│   │   └── app_icon.png
│   └── fonts/
│       └── (if custom fonts needed)
│
├── pubspec.yaml              # Dependencies
├── pubspec.lock
├── .gitignore
├── README.md
└── analysis_options.yaml     # Lint rules

```

## Key Folders Explained

**lib/models/** — Data classes (User, MoodEntry, etc.)
**lib/services/** — Business logic (database, auth, calculations)
**lib/providers/** — State management (Provider/Riverpod)
**lib/screens/** — Full page screens (5 screens from design)
**lib/widgets/** — Reusable UI components
**lib/config/** — App settings, themes, routes
**lib/utils/** — Helper functions (dates, colors, validation)

## Dependencies (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.0.0          # State management
  sqflite: ^2.3.0           # SQLite
  path: ^1.8.0
  intl: ^0.19.0             # Date formatting
  uuid: ^4.0.0              # Unique IDs
  flutter_local_notifications: ^14.0.0  # Push notifications
  flutter_secure_storage: ^9.0.0        # Encrypt JWT tokens
  fl_chart: ^0.63.0         # Charts
  crypto: ^3.0.0            # Password hashing
  shared_preferences: ^2.0.0 # Simple key-value storage

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
```

## File Creation Checklist

- [ ] Create folders structure above
- [ ] Create empty dart files in each folder
- [ ] Update pubspec.yaml with dependencies
- [ ] Run `flutter pub get`
- [ ] Verify app compiles: `flutter run`
