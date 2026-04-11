# EMOTRACE — HIGHLIGHT.md
# This file coordinates the two Claude Code agents working on this project.
# READ THIS FIRST at the start of every session.
# UPDATE THIS LAST before every push.

## Last Session
- Date: 11 Apr 2026
- Author: Piyush Puri
- Branch: feature/mood_to_tracker_2
- Summary: Session 2 — Created all missing lib/config/ files (theme, constants, routes) which were absent from Rajat's commit. Implemented InsightService algorithms (streak, stability, day-of-week pattern, emotion frequency). Built full CalendarScreen with streak bento grid, month-navigable 90-day heatmap, and trends summary card. Built full InsightsScreen with stability score hero, 30-day fl_chart line chart, pattern bento grid, and emotion frequency bars. Added pubspec.yaml. All Piyush Week 2 tasks complete.

---

## COMPLETED FILES

| File | What it does | Author | Date completed |
|------|-------------|--------|----------------|
| lib/config/theme.dart | AppTheme dark theme, moodColors map | Rajat Mahajan (Piyush recreated) | 11 Apr 2026 |
| lib/config/constants.dart | All app constants — emotions, mood labels, emojis, motivations | Rajat Mahajan (Piyush recreated) | 11 Apr 2026 |
| lib/config/routes.dart | AppRoutes named route map | Rajat Mahajan (Piyush recreated) | 11 Apr 2026 |
| pubspec.yaml | Flutter project config with all dependencies | Piyush Puri | 11 Apr 2026 |
| lib/main.dart | App entry point, MultiProvider, MainNavigation with bottom nav | Rajat Mahajan | 11 Apr 2026 |
| lib/models/user_model.dart | User class — fromMap/toMap, matches users table | Rajat Mahajan | 11 Apr 2026 |
| lib/models/mood_entry_model.dart | MoodEntry class — fromMap/toMap, matches mood_entries table | Rajat Mahajan | 11 Apr 2026 |
| lib/models/emotion_model.dart | Emotion class — fromMap/toMap, matches emotion_tags table | Rajat Mahajan | 11 Apr 2026 |
| lib/models/settings_model.dart | Settings class — fromMap/toMap/defaults, matches settings table | Rajat Mahajan | 11 Apr 2026 |
| lib/services/database_service.dart | SQLite singleton — init, createTables (all 5 tables + indexes), CRUD helpers | Rajat Mahajan | 11 Apr 2026 |
| lib/services/mood_service.dart | MoodService — saveMoodEntry, getMoodEntries, getTodaysMood, getRecentEntries, delete | Rajat Mahajan | 11 Apr 2026 |
| lib/services/auth_service.dart | AuthService stub — login/logout/getCurrentUser (Month 2) | Rajat Mahajan | 11 Apr 2026 |
| lib/services/insight_service.dart | InsightService — FULL algorithms: streak, stability score, day-of-week, emotion freq | Piyush Puri | 11 Apr 2026 |
| lib/services/notification_service.dart | NotificationService stub — schedule/cancel daily reminder (Week 5) | Rajat Mahajan | 11 Apr 2026 |
| lib/providers/mood_provider.dart | MoodProvider — addMoodEntry, loadEntries, deleteEntry, todaysMood, recentEntries | Rajat Mahajan | 11 Apr 2026 |
| lib/providers/insights_provider.dart | InsightsProvider — calculateInsights (wired to InsightService) | Rajat Mahajan | 11 Apr 2026 |
| lib/providers/auth_provider.dart | AuthProvider stub — login/logout (Month 2) | Rajat Mahajan | 11 Apr 2026 |
| lib/providers/settings_provider.dart | SettingsProvider — theme, reminders, reminderTime | Rajat Mahajan | 11 Apr 2026 |
| lib/screens/home_screen.dart | HomeScreen shell — loads MoodProvider, placeholder UI | Rajat Mahajan | 11 Apr 2026 |
| lib/screens/mood_entry_screen.dart | MoodEntryScreen shell — mood score/emoji display, ready for MoodScaleWidget | Rajat Mahajan | 11 Apr 2026 |
| lib/screens/calendar_screen.dart | CalendarScreen FULL — streak bento grid, 90-day heatmap, month nav, trends card | Piyush Puri | 11 Apr 2026 |
| lib/screens/insights_screen.dart | InsightsScreen FULL — stability score, 30-day chart, pattern cards, emotion bars | Piyush Puri | 11 Apr 2026 |
| lib/screens/settings_screen.dart | SettingsScreen shell — reminder toggle wired to SettingsProvider | Rajat Mahajan | 11 Apr 2026 |
| lib/widgets/mood_scale_widget.dart | MoodScaleWidget — emoji + mood circles, tap-to-select skeleton | Rajat Mahajan | 11 Apr 2026 |
| lib/widgets/emotion_tag_selector.dart | EmotionTagSelector — FilterChip row from AppConstants.emotions | Rajat Mahajan | 11 Apr 2026 |
| lib/widgets/calendar_heatmap.dart | CalendarHeatmap FULL — month nav, color grid, tap-to-view, legend, entry count | Piyush Puri | 11 Apr 2026 |
| lib/widgets/streak_counter.dart | StreakCounter — currentStreak + longestStreak display | Rajat Mahajan | 11 Apr 2026 |
| lib/widgets/mood_chart.dart | MoodChart FULL — fl_chart line chart, 30-day trend, gradient fill, tooltips | Piyush Puri | 11 Apr 2026 |
| lib/widgets/bottom_nav_bar.dart | EmotracBottomNavBar — custom nav shell | Rajat Mahajan | 11 Apr 2026 |
| lib/widgets/mood_entry_card.dart | MoodEntryCard — ListTile with mood color circle, date, emotions | Rajat Mahajan | 11 Apr 2026 |
| lib/utils/date_utils.dart | AppDateUtils — formatDate, relativeLabel, calculateCurrentStreak | Rajat Mahajan | 11 Apr 2026 |
| lib/utils/color_utils.dart | AppColorUtils — getMoodColor, getMoodLabel, getMoodEmoji | Rajat Mahajan | 11 Apr 2026 |
| lib/utils/validation_utils.dart | ValidationUtils — validateMoodScore, validateNotes, validateEmail | Rajat Mahajan | 11 Apr 2026 |

---

## DO NOT TOUCH — Currently In Progress

| File | Author working on it | Date started |
|------|---------------------|--------------|
| lib/screens/home_screen.dart | Rajat Mahajan | Week 2 |
| lib/screens/mood_entry_screen.dart | Rajat Mahajan | Week 3 |
| lib/widgets/mood_scale_widget.dart | Rajat Mahajan | Week 3 |
| lib/widgets/emotion_tag_selector.dart | Rajat Mahajan | Week 3 |

---

## NEXT SESSION WORK QUEUE

### High Priority (Week 2/3 — Rajat Mahajan)
- [ ] Wire DatabaseService.init() in main.dart before runApp — Rajat Mahajan
- [ ] Build full HomeScreen dashboard: greeting, today's mood card, streak, recent entries, FAB — Rajat Mahajan
- [ ] Build full MoodEntryScreen: MoodScaleWidget + EmotionTagSelector + notes + save — Rajat Mahajan
- [ ] Implement MoodProvider.addMoodEntry with full DatabaseService integration — Rajat Mahajan
- [ ] Test: save mood entry → appears on home screen — Rajat Mahajan

### High Priority (Week 3 — Piyush Puri)
- [ ] Implement SettingsScreen full UI (theme toggle, reminder time picker) — Piyush Puri
- [ ] Wire StreakCounter widget properly into CalendarScreen (already used, verify display) — Piyush Puri
- [ ] Add pull-to-refresh on CalendarScreen and InsightsScreen — Piyush Puri

### Medium Priority
- [ ] NotificationService implementation — Week 5
- [ ] SettingsScreen reminder time picker — Week 5

### Low Priority
- [ ] PDF export feature
- [ ] Push notification full integration
- [ ] Auth (Month 2)

---

## CROSS-DEPENDENCY FLAGS

| Issue | Raised by | Needs action from | Status |
|-------|-----------|-------------------|--------|
| lib/config/theme.dart, constants.dart, routes.dart were missing from Rajat's commit — Piyush recreated them from context; Rajat should review and confirm accuracy | Piyush Puri | Rajat Mahajan | Needs review |
| DatabaseService.init() must be called before any service is used — not yet in main.dart | Rajat Mahajan | Rajat Mahajan (next session) | Pending |
| InsightsProvider.calculateInsights() — InsightService now FULLY implemented; call will return real data once DB has entries | Piyush Puri | — | Resolved |
| MoodEntryCard imports moodColors from theme.dart — confirmed: moodColors is now top-level const in theme.dart, import path correct | Piyush Puri | — | Resolved |

---

## FOLDER STATE SNAPSHOT

```
lib/
  main.dart                                         DONE — Rajat Mahajan
  config/
    theme.dart                                      DONE — Rajat Mahajan (Piyush recreated)
    constants.dart                                  DONE — Rajat Mahajan (Piyush recreated)
    routes.dart                                     DONE — Rajat Mahajan (Piyush recreated)
  models/
    user_model.dart                                 DONE — Rajat Mahajan
    mood_entry_model.dart                           DONE — Rajat Mahajan
    emotion_model.dart                              DONE — Rajat Mahajan
    settings_model.dart                             DONE — Rajat Mahajan
  services/
    database_service.dart                           DONE — Rajat Mahajan
    mood_service.dart                               DONE — Rajat Mahajan
    auth_service.dart                               DONE stub — Rajat Mahajan
    insight_service.dart                            DONE FULL — Piyush Puri
    notification_service.dart                       DONE stub — Rajat Mahajan
  providers/
    mood_provider.dart                              DONE — Rajat Mahajan
    insights_provider.dart                          DONE — Rajat Mahajan
    auth_provider.dart                              DONE stub — Rajat Mahajan
    settings_provider.dart                          DONE — Rajat Mahajan
  screens/
    home_screen.dart                                SHELL — Rajat Mahajan (Week 2: full impl)
    mood_entry_screen.dart                          SHELL — Rajat Mahajan (Week 3: full impl)
    calendar_screen.dart                            DONE FULL — Piyush Puri
    insights_screen.dart                            DONE FULL — Piyush Puri
    settings_screen.dart                            SHELL — Rajat Mahajan (Week 5)
  widgets/
    mood_scale_widget.dart                          SHELL — Rajat Mahajan (Week 3)
    emotion_tag_selector.dart                       SHELL — Rajat Mahajan (Week 3)
    calendar_heatmap.dart                           DONE FULL — Piyush Puri
    streak_counter.dart                             SHELL — Rajat Mahajan
    mood_chart.dart                                 DONE FULL — Piyush Puri
    bottom_nav_bar.dart                             SHELL — Rajat Mahajan
    mood_entry_card.dart                            SHELL — Rajat Mahajan
  utils/
    date_utils.dart                                 DONE — Rajat Mahajan
    color_utils.dart                                DONE — Rajat Mahajan
    validation_utils.dart                           DONE — Rajat Mahajan
pubspec.yaml                                        DONE — Piyush Puri
```

Legend: DONE | DONE FULL | DONE stub | SHELL (needs full implementation) | IN PROGRESS | PENDING

---

## COMMIT HISTORY

| Commit message | Branch | Author | Date |
|---------------|--------|--------|------|
| feat: initial project skeleton — all lib/ files generated | feature/mood_to_tracker_1 | Rajat Mahajan | 11 Apr 2026 |
| feat: CalendarScreen + InsightsScreen full impl, config files, InsightService algorithms, pubspec | feature/mood_to_tracker_2 | Piyush Puri | 11 Apr 2026 |

---

## TEAM DECISIONS LOG

| Decision | Made by | Date |
|----------|---------|------|
| State management: Provider (ChangeNotifier) | Rajat Mahajan | 11 Apr 2026 |
| Database: sqflite (SQLite local-first) | Rajat Mahajan | 11 Apr 2026 |
| No auth in MVP — local_user_01 hardcoded until Month 2 | Rajat Mahajan | 11 Apr 2026 |
| emotion_tags stored as comma-separated string in mood_entries.emotion_tags column | Rajat Mahajan | 11 Apr 2026 |
| Bottom nav: 4 tabs (Home, Calendar, Insights, Settings) — Mood Entry via FAB/push | Rajat Mahajan | 11 Apr 2026 |
| moodColors defined as top-level const in theme.dart (not inside AppTheme class) — required by MoodEntryCard import | Piyush Puri | 11 Apr 2026 |
| InsightService algorithms implemented in Session 2 (not Week 5-6 as originally planned) — algorithms were simple enough to do now | Piyush Puri | 11 Apr 2026 |
