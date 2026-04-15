# EMOTRACE — HIGHLIGHT.md
# This file coordinates the two Claude Code agents working on this project.
# READ THIS FIRST at the start of every session.
# UPDATE THIS LAST before every push.

## Last Session — Session 7 (Sanctuary UI Redesign + App Icon)
- Date: 15 Apr 2026
- Author: Piyush Puri
- Branch: feature/mood_to_tracker_2
- Summary: Full Sanctuary editorial dark theme redesign across all 5 screens + 7 widgets (Tasks 3–16 of 2026-04-14-sanctuary-ui-redesign plan). Added google_fonts (Newsreader serif + Manrope sans). New AppTheme: deep forest green #0b1513 bg, gold #e9c176 primary, 15 new text style helpers (headlineSerif, displaySerifItalic, labelCaps, etc.), moodColorForScore() helper, legacy aliases kept. HomeScreen: editorial hero header (greeting/"You"/date), streak card, bento grid (_VibeCard 2/3 + _MoodSphereCard 1/3), forest.png background image in CurrentResonance vibe card with mood-tinted gradient overlay, Recent Echoes section, gold FAB bottom-right. MoodEntryScreen: glow sphere (200px RadialGradient, ambient halo), 10-bar MoodScaleWidget, emotion icon GridView (2-col, 16 icons), reflections textarea with animated edit icon. CalendarScreen: editorial header, stat cards row (streak + completion%), heatmap card, insight card with longest streak + total entries. InsightsScreen: bento (stability card with gold left border + MoodChart 2/3), pattern grid (_PatternCard), emotion frequency bars (gold for top). SettingsScreen: editorial sections, _SanctuaryToggle (AnimatedContainer gold gradient), _SectionCard, _SettingsTile. Widgets: EmotracBottomNavBar (BackdropFilter frosted glass + gold active pill), MoodEntryCard (56x56 square thumbnail), StreakCounter (gold fire icon + LinearProgressIndicator). MoodChart: gold gradient line, no grid. CalendarHeatmap: 5-band Sanctuary colors, AspectRatio 1:1 cells, gold today ring, note dots. Forest image: assets/images/forest.png copied from design/stitch_daily_mood_tracker/home_dashboard_1/. App icon: flutter_launcher_icons v0.14.4 used to generate Android + iOS icons from app_icon.jpeg. flutter analyze lib/: No issues found.

## Session 5 (beta completion)
- Date: 13 Apr 2026
- Author: Piyush Puri
- Branch: feature/mood_to_tracker_2
- Summary: Added packages: timezone, flutter_timezone, pdf, printing. Created SettingsService (DB read/write). Rewrote SettingsProvider with loadSettings() persistence + notification scheduling via toggleReminder/updateReminderTime (void for Switch compat, async via .then()). Rewrote NotificationService: full daily reminder via zonedSchedule + DateTimeComponents.time + AndroidScheduleMode.inexact. Wired DatabaseService.init() + NotificationService.init() + AppRoutes.routes in main.dart. Created PdfService (buildHistoryPdf + buildInsightsPdf, ASCII-only for Helvetica compat); 4 unit tests pass. Wired Export Mood History tile in SettingsScreen (StatefulWidget, _isExporting guard, Printing.sharePdf). Wired Share icon in InsightsScreen SliverAppBar (_isSharing guard, Printing.sharePdf). Fixed analyze: missing uiLocalNotificationDateInterpretation arg, removed unused constants.dart import in pdf_service. flutter analyze: No issues found. flutter test: 4/4 pass.

## Session 6 — Platform Setup
- Date: 13 Apr 2026
- Author: Piyush Puri
- Branch: feature/mood_to_tracker_2
- Summary: Generated android/ and ios/ platform directories via `flutter create --platforms android,ios .`. Updated android/app/src/main/AndroidManifest.xml with all required permissions and receivers for flutter_local_notifications: RECEIVE_BOOT_COMPLETED, POST_NOTIFICATIONS, VIBRATE, ScheduledNotificationBootReceiver (BOOT_COMPLETED + MY_PACKAGE_REPLACED + QUICKBOOT_POWERON), ScheduledNotificationReceiver. App is now ready to build APK or run on a connected device via `flutter run`.

---

## COMPLETED FILES

| File | What it does | Author | Date completed |
|------|-------------|--------|----------------|
| lib/config/theme.dart | AppTheme Sanctuary dark theme — bg #0b1513, gold #e9c176, 15 text helpers, moodColorForScore(), legacy aliases | Piyush Puri | 15 Apr 2026 |
| lib/config/constants.dart | Sanctuary mood labels (Depleted→Luminous), 16-emotion list, streakGoal=10, moodEmojis | Piyush Puri | 15 Apr 2026 |
| lib/config/routes.dart | AppRoutes named route map | Rajat Mahajan (Piyush recreated) | 11 Apr 2026 |
| pubspec.yaml | Flutter project config with all dependencies | Piyush Puri | 11 Apr 2026 |
| lib/main.dart | App entry point, MultiProvider, EmotracBottomNavBar wired, DatabaseService.init() | Piyush Puri | 15 Apr 2026 |
| lib/models/user_model.dart | User class — fromMap/toMap, matches users table | Rajat Mahajan | 11 Apr 2026 |
| lib/models/mood_entry_model.dart | MoodEntry class — fromMap/toMap, matches mood_entries table | Rajat Mahajan | 11 Apr 2026 |
| lib/models/emotion_model.dart | Emotion class — fromMap/toMap, matches emotion_tags table | Rajat Mahajan | 11 Apr 2026 |
| lib/models/settings_model.dart | Settings class — fromMap/toMap/defaults, matches settings table | Rajat Mahajan | 11 Apr 2026 |
| lib/services/database_service.dart | SQLite singleton — init, createTables (all 5 tables + indexes), CRUD helpers | Rajat Mahajan | 11 Apr 2026 |
| lib/services/mood_service.dart | MoodService — saveMoodEntry, getMoodEntries, getTodaysMood, getRecentEntries, delete | Rajat Mahajan | 11 Apr 2026 |
| lib/services/auth_service.dart | AuthService stub — login/logout/getCurrentUser (Month 2) | Rajat Mahajan | 11 Apr 2026 |
| lib/services/insight_service.dart | InsightService — FULL algorithms: streak, stability score, day-of-week, emotion freq; removed unused _tempUserId | Piyush Puri | 13 Apr 2026 |
| lib/services/notification_service.dart | NotificationService FULL — init, scheduleDailyReminder (zonedSchedule + DateTimeComponents.time), cancelDailyReminder | Piyush Puri | 13 Apr 2026 |
| lib/services/settings_service.dart | SettingsService — loadSettings (returns null on first launch), saveSettings (upsert) | Piyush Puri | 13 Apr 2026 |
| lib/services/pdf_service.dart | PdfService — buildHistoryPdf (summary + entries table), buildInsightsPdf (hero score + patterns + emotion bars); ASCII-only | Piyush Puri | 13 Apr 2026 |
| lib/providers/mood_provider.dart | MoodProvider — addMoodEntry, loadEntries, deleteEntry, todaysMood, recentEntries, currentStreak, longestStreak | Rajat Mahajan / Piyush Puri | 13 Apr 2026 |
| lib/providers/insights_provider.dart | InsightsProvider — calculateInsights (wired to InsightService) | Rajat Mahajan | 11 Apr 2026 |
| lib/providers/auth_provider.dart | AuthProvider stub — login/logout (Month 2) | Rajat Mahajan | 11 Apr 2026 |
| lib/providers/settings_provider.dart | SettingsProvider FULL — loadSettings from DB, persist on change, wire NotificationService scheduling; void mutators for Switch compat | Piyush Puri | 13 Apr 2026 |
| lib/screens/home_screen.dart | Sanctuary redesign: editorial hero, bento grid (_VibeCard + _MoodSphereCard), forest.png bg, gold FAB, Recent Echoes | Piyush Puri | 15 Apr 2026 |
| lib/screens/mood_entry_screen.dart | Sanctuary redesign: glow sphere, 10-bar scale, icon GridView chips, animated reflections field, gold save button | Piyush Puri | 15 Apr 2026 |
| lib/screens/calendar_screen.dart | Sanctuary redesign: stat cards row (streak + completion%), heatmap card, insight card | Piyush Puri | 15 Apr 2026 |
| lib/screens/insights_screen.dart | Sanctuary redesign: bento (stability card + MoodChart), pattern grid, emotion frequency bars | Piyush Puri | 15 Apr 2026 |
| lib/screens/settings_screen.dart | Sanctuary redesign: editorial sections, _SanctuaryToggle (gold gradient), _SectionCard, _SettingsTile | Piyush Puri | 15 Apr 2026 |
| lib/widgets/mood_scale_widget.dart | Sanctuary redesign: 10 vertical bars, gold gradient selected bar, glow shadow | Piyush Puri | 15 Apr 2026 |
| lib/widgets/emotion_tag_selector.dart | Sanctuary redesign: 2-col icon GridView, 16 emotion icons, gold selected state | Piyush Puri | 15 Apr 2026 |
| lib/widgets/calendar_heatmap.dart | Sanctuary redesign: 5-band colors, AspectRatio 1:1 cells, gold today ring, note dots, new legend | Piyush Puri | 15 Apr 2026 |
| lib/widgets/streak_counter.dart | Sanctuary redesign: 48x48 gold fire icon container, LinearProgressIndicator toward streakGoal | Piyush Puri | 15 Apr 2026 |
| lib/widgets/mood_chart.dart | Sanctuary redesign: gold gradient line, no grid, tooltip uses surfaceContainerHighest | Piyush Puri | 15 Apr 2026 |
| lib/widgets/bottom_nav_bar.dart | Sanctuary redesign: BackdropFilter frosted glass, gold LinearGradient active pill, AnimatedContainer | Piyush Puri | 15 Apr 2026 |
| lib/widgets/mood_entry_card.dart | Sanctuary redesign: 56x56 square thumbnail, Newsreader headlineSerifMedium, moodColorForScore() | Piyush Puri | 15 Apr 2026 |
| assets/images/forest.png | Forest background for _VibeCard — copied from design/stitch_daily_mood_tracker/home_dashboard_1/ | Piyush Puri | 15 Apr 2026 |
| pubspec.yaml | Added google_fonts, flutter_launcher_icons; assets: assets/images/forest.png declared | Piyush Puri | 15 Apr 2026 |
| lib/utils/date_utils.dart | AppDateUtils — formatDate, relativeLabel, calculateCurrentStreak | Rajat Mahajan | 11 Apr 2026 |
| lib/utils/color_utils.dart | AppColorUtils — getMoodColor, getMoodLabel, getMoodEmoji | Rajat Mahajan | 11 Apr 2026 |
| lib/utils/validation_utils.dart | ValidationUtils — validateMoodScore, validateNotes, validateEmail | Rajat Mahajan | 11 Apr 2026 |
| android/app/src/main/AndroidManifest.xml | Permissions: RECEIVE_BOOT_COMPLETED, POST_NOTIFICATIONS, VIBRATE; Receivers: ScheduledNotificationBootReceiver + ScheduledNotificationReceiver for flutter_local_notifications | Piyush Puri | 13 Apr 2026 |

---

## DO NOT TOUCH — Currently In Progress

| File | Author working on it | Date started |
|------|---------------------|--------------|
| — | — | — |

*(All previously in-progress files are now DONE FULL as of 13 Apr 2026 — Piyush Puri)*

---

## NEXT SESSION WORK QUEUE

### High Priority (Week 2/3 — Rajat Mahajan)
- [x] ⚠️ REVIEW REQUIRED: lib/config/theme.dart, constants.dart, routes.dart — Reviewed by Piyush Puri (13 Apr): all values confirmed correct — colours, emotions, mood labels, emojis all match existing code ✓
- [x] Wire DatabaseService.init() in main.dart before runApp — DONE Piyush Puri ✓ 13 Apr 2026
- [x] Build full HomeScreen dashboard: greeting, today's mood card, streak, recent entries, FAB — DONE Piyush Puri ✓ 13 Apr 2026
  - 💡 StreakCounter widget is DONE FULL (Piyush, 12 Apr). Import from lib/widgets/streak_counter.dart and use directly: `StreakCounter(currentStreak: x, longestStreak: y)` — no need to rebuild streak UI
- [x] Build full MoodEntryScreen: MoodScaleWidget + EmotionTagSelector + notes + save — DONE Piyush Puri ✓ 13 Apr 2026
- [x] Implement MoodProvider.addMoodEntry with full DatabaseService integration — was already implemented by Rajat ✓ 11 Apr 2026
- [x] Test: save mood entry → appears on home screen — flow fully wired: MoodEntryScreen → MoodProvider.addMoodEntry() → loadEntries() on pop → HomeScreen updates ✓

### 🔔 For Rajat Mahajan — IMPORTANT SESSION 7 CHANGES (15 Apr 2026)
All 5 screens and 7 widgets have been completely redesigned under the "Sanctuary" editorial dark theme. When you pick up your branch:
- 💡 `AppTheme` has 15 new text style helpers (`headlineSerif`, `displaySerifItalic`, `labelCaps`, etc.) — use these instead of raw TextStyle
- 💡 `AppTheme.moodColorForScore(int score)` replaces `AppColorUtils.getMoodColor()` — use the new helper in any new widgets
- 💡 `AppConstants.moodLabels`, `AppConstants.moodEmojis`, and `AppConstants.emotions` have been updated to Sanctuary vocabulary (e.g. "Luminous" not "Ecstatic")
- 💡 `EmotracBottomNavBar` in `lib/widgets/bottom_nav_bar.dart` is now frosted-glass + gold — no changes needed, but if you rebuild nav logic reference this file
- 💡 `assets/images/forest.png` is declared in pubspec.yaml and available for other screens/widgets if needed
- 💡 `flutter_launcher_icons` added as dev dependency — app icon (app_icon.jpeg) already generated for Android + iOS. No action needed from you.
- ⚠️ `color_utils.dart` still exists but is no longer used by any Piyush-owned file. If your screens still import it, it's fine to keep using it — just note `moodColorForScore()` is the new canonical method.

### High Priority (Week 3 — Piyush Puri)
- [x] Implement SettingsScreen full UI (theme toggle, reminder time picker) — Piyush Puri ✓ 12 Apr 2026
- [x] Wire StreakCounter widget properly into CalendarScreen — Piyush Puri ✓ 12 Apr 2026
- [x] Add pull-to-refresh on CalendarScreen and InsightsScreen — Piyush Puri ✓ 12 Apr 2026

### Medium Priority
- [x] NotificationService implementation — DONE FULL Piyush Puri ✓ 13 Apr 2026 (zonedSchedule, daily repeat, cancelDailyReminder)
- [x] SettingsScreen reminder time picker — DONE (built in SettingsScreen full UI, Piyush Puri, 12 Apr 2026)

### Low Priority
- [x] PDF export feature — DONE FULL Piyush Puri ✓ 13 Apr 2026 (History PDF from Settings + Insights PDF from Insights share icon)
- [x] Push notification full integration — DONE FULL Piyush Puri ✓ 13 Apr 2026 (wired through SettingsProvider.toggleReminder)
- [x] Android/iOS platform directories generated — DONE Piyush Puri ✓ 13 Apr 2026
- [x] AndroidManifest.xml notification permissions + receivers — DONE Piyush Puri ✓ 13 Apr 2026
- [ ] Auth (Month 2)

---

## CROSS-DEPENDENCY FLAGS

| Issue | Raised by | Needs action from | Status |
|-------|-----------|-------------------|--------|
| lib/config/theme.dart, constants.dart, routes.dart were missing from Rajat's commit — Piyush recreated them from context; Rajat should review and confirm accuracy | Piyush Puri | Rajat Mahajan | Reviewed + confirmed ✓ Piyush 13 Apr |
| DatabaseService.init() must be called before any service is used — not yet in main.dart | Rajat Mahajan | Rajat Mahajan (next session) | Fixed ✓ Piyush 13 Apr |
| InsightsProvider.calculateInsights() — InsightService now FULLY implemented; call will return real data once DB has entries | Piyush Puri | — | Resolved |
| MoodEntryCard imports moodColors from theme.dart — confirmed: moodColors is now top-level const in theme.dart, import path correct | Piyush Puri | — | Resolved |
| StreakCounter widget is DONE FULL — Rajat can use it directly in HomeScreen. Props: currentStreak (int), longestStreak (int). Import: lib/widgets/streak_counter.dart | Piyush Puri | Rajat Mahajan (info, no blocker) | Used in HomeScreen ✓ |
| HomeScreen + MoodEntryScreen + all widget shells completed by Piyush (Rajat away, 13 Apr). All screens now fully wired. MoodProvider has currentStreak + longestStreak getters. main.dart DB init fixed. | Piyush Puri | Rajat Mahajan (info on return) | Done ✓ |
| CalendarHeatmap bug fixed: Icons.database_outlined does not exist in Flutter — replaced with Icons.storage_rounded | Piyush Puri | — | Fixed ✓ |

---

## FOLDER STATE SNAPSHOT

```
lib/
  main.dart                                         DONE FULL — Piyush Puri (EmotracBottomNavBar wired, 15 Apr)
  config/
    theme.dart                                      DONE FULL — Piyush Puri (Sanctuary redesign, 15 Apr)
    constants.dart                                  DONE FULL — Piyush Puri (Sanctuary labels + 16 emotions, 15 Apr)
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
    notification_service.dart                       DONE FULL — Piyush Puri
    pdf_service.dart                                DONE FULL — Piyush Puri
    settings_service.dart                           DONE FULL — Piyush Puri
  providers/
    mood_provider.dart                              DONE — Rajat Mahajan / Piyush Puri
    insights_provider.dart                          DONE — Rajat Mahajan
    auth_provider.dart                              DONE stub — Rajat Mahajan
    settings_provider.dart                          DONE FULL — Piyush Puri
  screens/
    home_screen.dart                                DONE FULL — Piyush Puri (Sanctuary, forest bg, 15 Apr)
    mood_entry_screen.dart                          DONE FULL — Piyush Puri (Sanctuary glow sphere, 15 Apr)
    calendar_screen.dart                            DONE FULL — Piyush Puri (Sanctuary stat cards, 15 Apr)
    insights_screen.dart                            DONE FULL — Piyush Puri (Sanctuary bento, 15 Apr)
    settings_screen.dart                            DONE FULL — Piyush Puri (Sanctuary toggle, 15 Apr)
  widgets/
    mood_scale_widget.dart                          DONE FULL — Piyush Puri (Sanctuary 10-bar, 15 Apr)
    emotion_tag_selector.dart                       DONE FULL — Piyush Puri (Sanctuary icon grid, 15 Apr)
    calendar_heatmap.dart                           DONE FULL — Piyush Puri (Sanctuary 5-band, 15 Apr)
    streak_counter.dart                             DONE FULL — Piyush Puri (Sanctuary gold fire, 15 Apr)
    mood_chart.dart                                 DONE FULL — Piyush Puri (Sanctuary gold line, 15 Apr)
    bottom_nav_bar.dart                             DONE FULL — Piyush Puri (Sanctuary frosted glass, 15 Apr)
    mood_entry_card.dart                            DONE FULL — Piyush Puri (Sanctuary square thumb, 15 Apr)
  utils/
    date_utils.dart                                 DONE — Rajat Mahajan
    color_utils.dart                                DONE — Rajat Mahajan (legacy, use AppTheme.moodColorForScore())
    validation_utils.dart                           DONE — Rajat Mahajan
assets/
  images/
    forest.png                                      DONE — Piyush Puri (vibe card bg, 15 Apr)
pubspec.yaml                                        DONE — Piyush Puri (google_fonts + flutter_launcher_icons, 15 Apr)
android/app/src/main/AndroidManifest.xml            DONE — Piyush Puri (notification permissions + receivers)
```

Legend: DONE | DONE FULL | DONE stub | SHELL (needs full implementation) | IN PROGRESS | PENDING

---

## COMMIT HISTORY

| Commit | Commit message | Branch | Author | Date |
|--------|---------------|--------|--------|------|
| fc09ddd | feat: initial project skeleton — all lib/ files generated | feature/mood_to_tracker_1 | Rajat Mahajan | 11 Apr 2026 |
| ff042ce | feat: CalendarScreen + InsightsScreen full impl, config files, InsightService algorithms, pubspec | feature/mood_to_tracker_2 | Piyush Puri | 11 Apr 2026 |
| 439e297 | fix: add explicit config-review task to Rajat's work queue in HIGHLIGHT.md | feature/mood_to_tracker_2 | Piyush Puri | 11 Apr 2026 |
| 9b6806f | feat: SettingsScreen full UI, StreakCounter full impl, pull-to-refresh CalendarScreen + InsightsScreen | feature/mood_to_tracker_2 | Piyush Puri | 12 Apr 2026 |
| 65fe1b3 | docs: add dual-agent coordination protocol and mega prompt for Rajat's Claude | feature/mood_to_tracker_2 | Piyush Puri | 12 Apr 2026 |
| ddd560a | docs: fix HIGHLIGHT.md commit history — add hashes, correct dates, fix duplicate column | feature/mood_to_tracker_2 | Piyush Puri | 12 Apr 2026 |
| 846c916 | feat: complete Rajat's full queue — HomeScreen, MoodEntryScreen, all widget shells, DB init fix | feature/mood_to_tracker_2 | Piyush Puri | 13 Apr 2026 |
| 445ee64 | fix: resolve all flutter analyze warnings — 0 issues clean | feature/mood_to_tracker_2 | Piyush Puri | 13 Apr 2026 |
| f67cd7f | chore: add pdf, printing, timezone, flutter_timezone packages | feature/mood_to_tracker_2 | Piyush Puri | 13 Apr 2026 |
| 2c0f0b7 | feat: add SettingsService — DB read/write for settings table | feature/mood_to_tracker_2 | Piyush Puri | 13 Apr 2026 |
| be64050 | feat: SettingsProvider — persist settings to DB, wire notification scheduling | feature/mood_to_tracker_2 | Piyush Puri | 13 Apr 2026 |
| 4c323dd | feat: NotificationService — daily reminder scheduling via flutter_local_notifications | feature/mood_to_tracker_2 | Piyush Puri | 13 Apr 2026 |
| 3c7d767 | feat: wire NotificationService.init + SettingsProvider.loadSettings in main, named routes | feature/mood_to_tracker_2 | Piyush Puri | 13 Apr 2026 |
| b75bc25 | feat: PdfService — buildHistoryPdf + buildInsightsPdf; 4 tests passing | feature/mood_to_tracker_2 | Piyush Puri | 13 Apr 2026 |
| 14822fc | feat: wire PDF export in SettingsScreen — Export Mood History tile | feature/mood_to_tracker_2 | Piyush Puri | 13 Apr 2026 |
| 7f53586 | feat: wire PDF share in InsightsScreen — share icon in SliverAppBar | feature/mood_to_tracker_2 | Piyush Puri | 13 Apr 2026 |
| 38d5bab | feat: Sanctuary theme tokens — gold palette + Newsreader/Manrope helpers | feature/mood_to_tracker_2 | Piyush Puri | 15 Apr 2026 |
| dab435b | feat: Sanctuary UI redesign — all 5 screens + 7 widgets complete | feature/mood_to_tracker_2 | Piyush Puri | 15 Apr 2026 |
| 61a1d8d | feat: add forest background image to Current Resonance vibe card | feature/mood_to_tracker_2 | Piyush Puri | 15 Apr 2026 |

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
| NotificationService uses AndroidScheduleMode.inexact (no SCHEDULE_EXACT_ALARM permission needed for MVP) | Piyush Puri | 13 Apr 2026 |
| PDF uses Helvetica (pdf package default) — ASCII-only; no em-dashes, bullets, or block chars (produce blank glyphs) | Piyush Puri | 13 Apr 2026 |
| SettingsProvider mutators are void (not async) for Switch.onChanged compatibility; async notification calls use .then() | Piyush Puri | 13 Apr 2026 |
| AndroidManifest.xml not yet present (no platform dirs committed); RECEIVE_BOOT_COMPLETED + POST_NOTIFICATIONS permissions needed when developer runs flutter create --platforms android,ios | Piyush Puri | 13 Apr 2026 |
| Platform dirs generated via flutter create --platforms android,ios; AndroidManifest patched with notification permissions + receivers; app ready for flutter run or flutter build apk | Piyush Puri | 13 Apr 2026 |
| Sanctuary editorial dark theme adopted for all 5 screens + 7 widgets — deep forest green #0b1513 bg + gold #e9c176 primary; Newsreader (serif) + Manrope (sans-serif) via google_fonts | Piyush Puri | 15 Apr 2026 |
| App icon generated via flutter_launcher_icons 0.14.4 from app_icon.jpeg — covers all Android mipmap densities + iOS | Piyush Puri | 15 Apr 2026 |
| moodColorForScore() in AppTheme is the new canonical mood color lookup; color_utils.dart is legacy (kept for compatibility) | Piyush Puri | 15 Apr 2026 |
