# Sanctuary UI Redesign — Design Spec
**Author:** Piyush Puri | **Date:** 2026-04-14  
**Branch:** feature/mood_to_tracker_2  
**Status:** Approved — ready for implementation planning

---

## Overview

Replace Emotrace's current teal/orange Material 3 UI with the "Sanctuary" editorial dark theme
from `design/stitch_daily_mood_tracker/`. Pure visual change — all providers, services, models,
database logic, notification logic, and PDF export remain completely untouched.

**Approach:** Layer by Layer — Theme → Nav → Screens → Widgets

---

## Constraints

- No changes to any file under `lib/models/`, `lib/services/`, `lib/providers/`, `lib/utils/`
- All widget public interfaces (callbacks, data inputs) remain identical
- `flutter analyze` must pass with 0 errors after every layer
- App name stays **EMOTRACE** (not "Sanctuary")
- Navigation stays **4 tabs**: Home, Calendar, Insights, Settings

---

## Layer 1 — Design Tokens

### Files: `pubspec.yaml`, `lib/config/theme.dart`, `lib/config/constants.dart`

### New Package
```yaml
google_fonts: ^6.2.1
```

### Color Palette (AppTheme constants + ColorScheme)

| Token | Hex | Replaces |
|---|---|---|
| `background` | `#0b1513` | `#131313` |
| `surface` | `#0b1513` | `#131313` |
| `surfaceContainer` | `#18221f` | `#201F1F` |
| `surfaceContainerLow` | `#141e1b` | — |
| `surfaceContainerHigh` | `#222c29` | `#2A2A2A` |
| `surfaceContainerHighest` | `#2d3734` | `#353534` |
| `primary` | `#e9c176` | `#47F3BB` (teal) |
| `primaryContainer` | `#c5a059` | `#06D6A0` |
| `onPrimary` | `#412d00` | `#003827` |
| `secondary` | `#b5ccc1` | `#FFB784` |
| `secondaryContainer` | `#394d45` | `#F47D00` |
| `onSurface` | `#dae5e0` | `#E5E2E1` |
| `onSurfaceVariant` | `#d1c5b4` | `#BACAC1` |
| `outline` | `#9a8f80` | `#85948C` |
| `outlineVariant` | `#4e4639` | `#3B4A43` |
| `error` | `#ffb4ab` | unchanged |
| `errorContainer` | `#93000a` | unchanged |
| `onPrimaryFixed` | `#261900` | — (new, used for mood sphere text) |

### Mood Color Scale (moodColors map — replaces 10-step gradient)

| Score | Color | Semantic |
|---|---|---|
| 1–2 | `#93000a` | Error red (heavy) |
| 3–4 | `#c5a059` | Dark gold |
| 5–6 | `#b5ccc1` | Sage |
| 7–8 | `#394d45` | Dark sage |
| 9–10 | `#21342d` | Forest (light) |

Implementation: `moodColors` map updated to 5 bands. Helper `moodColorForScore(int score)` in
`AppTheme` maps 1–10 to the 5 bands above.

### Typography (TextTheme via google_fonts)

| Style name | Font | Size | Weight | Style | Use |
|---|---|---|---|---|---|
| `displaySerif` | Newsreader | 52px | 600 | normal | Hero headers |
| `displaySerifItalic` | Newsreader | 52px | 400 | italic | Name accents |
| `headlineSerif` | Newsreader | 32px | 600 | normal | Section headers |
| `headlineSerifMedium` | Newsreader | 24px | 500 | normal | Card titles |
| `headlineSerifItalic` | Newsreader | 24px | 400 | italic | Accent titles |
| `bodyMedium` | Manrope | 14px | 400 | normal | Body text |
| `bodySmall` | Manrope | 12px | 400 | normal | Muted body |
| `labelCaps` | Manrope | 10px | 700 | normal | Uppercase metadata, tracking 0.15em |
| `labelMedium` | Manrope | 11px | 700 | normal | Nav labels |

All added as extensions on `AppTheme` (static getters returning `TextStyle`) — not replacing the
base `TextTheme` (keeps Material widgets working correctly).

### Mood Labels (constants.dart)

| Score | Old label | New label |
|---|---|---|
| 1 | `VIBE: TERRIBLE` | `Depleted` |
| 2 | `VIBE: BAD` | `Heavy` |
| 3 | `VIBE: LOW` | `Low` |
| 4 | `VIBE: MEH` | `Unsettled` |
| 5 | `VIBE: OKAY` | `Steady` |
| 6 | `VIBE: DECENT` | `Decent` |
| 7 | `VIBE: BALANCED` | `Balanced` |
| 8 | `VIBE: GOOD` | `Vibrant` |
| 9 | `VIBE: GREAT` | `Radiant` |
| 10 | `VIBE: AMAZING` | `Luminous` |

Scale endpoints for mood entry screen: `Tired` (low end) / `Radiant` (high end).

---

## Layer 2 — Navigation + App Shell

### Files: `lib/main.dart`, `lib/widgets/bottom_nav_bar.dart`

### BottomNavBar Widget (full rebuild)

Replace `BottomNavigationBar` with custom `StatelessWidget`:

```
EmotracBottomNavBar({
  required int currentIndex,
  required ValueChanged<int> onTap,
})
```

**Structure:**
- `ClipRRect` with `borderRadius: BorderRadius.vertical(top: Radius.circular(24))`
- `BackdropFilter(filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20))`
- Background: `Color(0x990b1513)` (60% opacity deep green)
- Top shadow: `BoxShadow(offset: Offset(0, -20), blurRadius: 40, color: Color(0x660b1513))`
- 4 tabs laid out in `Row` with `MainAxisAlignment.spaceAround`
- Padding: horizontal 16px, bottom 32px (safe area), top 12px

**Active tab:**
- `Container` with `BoxDecoration(gradient: LinearGradient(#e9c176 → #c5a059), borderRadius: BorderRadius.circular(20))`
- Padding: horizontal 20px, vertical 8px
- Icon with `font-variation-settings FILL=1` equivalent: use `Icons.*` filled variant or `fill: 1` via `Icon` with custom rendering
- Label: Manrope 11px bold uppercase

**Inactive tab:**
- No container background
- Icon + label in `Color(0x99c5a059)` (60% opacity dark gold)

**4 tabs:**

| Index | Label | Icon (inactive) | Icon (active) |
|---|---|---|---|
| 0 | HOME | `Icons.home_outlined` | `Icons.home` |
| 1 | CALENDAR | `Icons.calendar_month_outlined` | `Icons.calendar_month` |
| 2 | INSIGHTS | `Icons.analytics_outlined` | `Icons.analytics` |
| 3 | SETTINGS | `Icons.settings_outlined` | `Icons.settings` |

### main.dart

- Replace `BottomNavigationBar` usage with `EmotracBottomNavBar`
- Screens array: `[HomeScreen, CalendarScreen, InsightsScreen, SettingsScreen]`
- `MoodEntryScreen` removed from tab list — accessed only via FAB on HomeScreen
- `Scaffold` `bottomNavigationBar` → `EmotracBottomNavBar`
- FAB moved to `HomeScreen` (not in main scaffold)

---

## Layer 3 — Screens

### home_screen.dart

**AppBar:**
- Leading: circular avatar (40px, `surface-container-highest` bg, `outline-variant` border)
- Title: "EMOTRACE" in `AppTheme.displaySerifItalic` style, gold color — left-aligned
- Action: notification bell in primary color

**Hero Section:**
- "Good morning," in `displaySerif` on-surface, then user name on new line in `displaySerifItalic` primary
- Subtext: Manrope 16px on-surface-variant, max 1–2 lines
- Streak card floated right: `surface-container-low` bg, `BorderRadius.circular(12)`, fire icon in 48×48 gold gradient square, "X Days" Newsreader bold 22px, "CURRENT STREAK" label-caps above

**Bento Grid (2-column):**

*Vibe card (2/3 width):*
- `BorderRadius.circular(24)`, min height 320px
- Background: `secondary-container` color. Image overlay: use a bundled local asset (`assets/images/vibe_bg.jpg`) if available, otherwise solid `secondary-container` bg. Opacity 60% when image present.
- Gradient overlay: `LinearGradient` from `surface` (bottom) to transparent (top)
- "CURRENT RESONANCE" pill badge: `surface/40` bg, blur, primary dot pulse, primary text
- Mood score "Decent 6/10" in `headlineSerif` 36px + `headlineSerifItalic` for score
- Descriptor text in Manrope
- "Check In" button: gold gradient, `BorderRadius.circular(12)`, `edit_note` icon

*Mood sphere (1/3 width):*
- `surface-container-high` bg, `BorderRadius.circular(24)`
- Ambient blur orb (primary/10 color, 80px blur)
- 128px circle with gradient border + `filter_drama` icon in primary
- "Weekly Sky" header in `headlineSerifMedium`
- 5-bar mini chart (week mood trend) using `surfaceContainerHighest` → primary colors

**Recent Echoes:**
- "Recent Echoes" in `headlineSerif` 28px + "View All →" link in primary
- 2-column card grid, each card:
  - `surface-container` bg, `BorderRadius.circular(12)`, hover → `surface-container-high`
  - 64×64px thumbnail (mood-color bg), date/time in `labelCaps`, title in `headlineSerifMedium`, 1-line note preview

**FAB:**
- `FloatingActionButton` custom: 64×64px, `BorderRadius.circular(20)`, gold gradient, `add` icon in `onPrimary`
- Positioned via `Stack` in `Scaffold` body, `right: 24, bottom: 24`
- Taps → `Navigator.push(MoodEntryScreen)`

### mood_entry_screen.dart

- No `AppBar` — custom header row: X button (`surface-container` bg, `close` icon) + centered "How are you feeling?" in `headlineSerif` + spacer
- No bottom nav bar (full-screen task flow)

**Mood Sphere:**
- 256×256px `Container`, `BoxShape.circle`
- Radial gradient: `#e9c176` center → `#c5a059` mid → `#0b1513` edge
- `BoxShadow`: `Color(0x26e9c176)` blur 60px
- Ambient halo behind: 100px blur `primary/20`
- Score number: Newsreader 60px bold `on-primary-fixed`
- Mood label: Manrope 12px uppercase tracking `on-primary-fixed` at 60%

**Scale Bar:**
- `surface-container-low` card, `BorderRadius.circular(24)`, padding 24px
- "Tired" / "Radiant" labels at ends in `labelCaps`
- 10 `GestureDetector` bars in a `Row`, heights: `[32, 38, 44, 50, 56, 50, 44, 56, 50, 64]` px (bell-ish curve)
- Active bar: gold gradient + `BoxShadow` gold glow
- Inactive: `surface-container-highest` at 30% opacity
- All bars: round top corners `BorderRadius.vertical(top: Radius.circular(8))`
- Tapping a bar updates sphere score + label

**Emotion Chips:**
- "REFINE YOUR STATE" label-caps header
- `GridView` 2 columns, `childAspectRatio: 3.5`
- Each chip: `Row(icon + label)`, `surface-container-low` bg, `BorderRadius.circular(12)`, subtle border
- Selected: `secondary-container` bg + `Border.all(color: primary, width: 1)` + `ring` shadow
- Icon map (Material Icons):
  - calm → `water_drop`, focused → `filter_center_focus`, inspired → `light_mode`
  - grounded → `eco`, peaceful → `auto_awesome`, energetic → `energy_savings_leaf`
  - anxious → `waves`, happy → `mood`, sad → `sentiment_dissatisfied`
  - stressed → `psychology_alt`, grateful → `favorite`, overwhelmed → `cloud`
  - angry → `local_fire_department`, excited → `bolt`, tired → `bedtime`, content → `spa`

**Reflections textarea:**
- `surface-container-highest` at 40% opacity, `BorderRadius.circular(24)`, min 140px height
- Placeholder: "Capture the texture of this moment..." in `on-surface-variant` at 40%
- `edit_note` icon bottom-right, fades in on focus

**Save button:**
- Full-width, gold gradient, `BorderRadius.circular(24)`, "SAVE REFLECTION" label-caps
- Wired to existing `MoodProvider.addEntry()` — no logic change

### calendar_screen.dart

**Header:**
- Same app bar pattern as home
- "Your Emotional" on one line + `Calendar` in `headlineSerifItalic` primary on next
- Subtext: Manrope muted
- Stat cards row: streak card (from `MoodProvider.currentStreak`) + completion % card — completion = `(entriesThisMonth / daysElapsedThisMonth * 100)`, computed in calendar screen from `MoodProvider.entries`. Both cards bento style, `surface-container-low` / `surface-container-high`.

**Calendar Grid:**
- `surface-container-low` card, padding 32px
- Month nav: `surface-container-highest` 40px square buttons, `chevron_left/right`, month in `headlineSerifMedium`
- Day headers: label-caps, `on-surface-variant` at 50%
- `GridView` 7 columns:
  - Each cell: `AspectRatio(1.0)`, `BorderRadius.circular(12)`, bg from `moodColorForScore()`
  - Empty/no entry: `surface-container-highest` + `outline-variant/20` border
  - Today: gold `Border.all` ring + `ring-offset` effect (outer container trick)
  - Has note: small white dot `Positioned` at bottom-center

**Sidebar (shown below grid on mobile, beside on tablet):**
- "Today's Insight" card: `secondary-container` bg + atmospheric image overlay + insight text + "Full Analysis" button
- "Historical Peak" card: most active day + average mood rows in `surface-container-low`

### insights_screen.dart

**Header:**
- "Your Patterns" in `headlineSerif` 36px
- Subtext: "last 30 days of reflection"

**Bento Grid:**
- Stability score card (1/3): left `primary/30` border accent (`Border(left: BorderSide(color: primary.withOpacity(0.3), width: 2))`), "STABILITY SCORE" label-caps, large score in Newsreader gold, trend sentence
- Mood trend chart (2/3): "Mood Trend" + "Daily average sentiment" header, restyled `fl_chart` line chart (gold gradient line, area fill, no grid, date labels)
- 4 insight cards (2-col, full-width): day pattern card, nightly ritual (atmospheric image overlay), movement+mood, growth opportunity (italic quote)

### settings_screen.dart

**Header:**
- "Settings" in `displaySerif`, subtext "Curate your experience"

**Sections** (Appearance, Notifications, Data & Privacy, About):
- Section title: Newsreader 22px semibold, primary color
- Cards: `surface-container-low`, `BorderRadius.circular(12)`, inner padding 8px, items inside `BorderRadius.circular(8)` hover

**Custom toggle:**
- `GestureDetector` wrapping pill `Container` (48×24px)
- ON: `primary-container` bg, thumb slides right
- OFF: `surface-container-highest` bg, `outline` thumb slides left
- Animated via `AnimatedPositioned` (200ms ease)
- Wired to existing `SettingsProvider` booleans — no logic change

**Export tile:** Wired to `PdfService` — no change  
**Premium card:** Atmospheric image bg + blur overlay, "Upgrade Now" button (UI only)  
**Footer:** "Built by EMOTRACE" in `headlineSerifItalic` gold

---

## Layer 4 — Widgets

### bottom_nav_bar.dart
See Layer 2 spec above — full rebuild as custom widget.

### mood_scale_widget.dart
- Replace emoji `Row` with 10-bar chart interface
- Public interface unchanged: `int selectedMood`, `ValueChanged<int> onMoodChanged`
- Internal: `StatefulWidget`, `_selected` int state, bar tap updates sphere via callback

### emotion_tag_selector.dart
- Replace `Wrap` chips with 2-column `GridView`
- Public interface unchanged: `List<String> selectedEmotions`, `ValueChanged<List<String>> onChanged`
- Add icon map (see mood_entry_screen section above)

### calendar_heatmap.dart
- Replace heatmap cells with square grid cells
- New color scale: 5 bands via `moodColorForScore()`
- Today ring: outer-container ring trick
- Note dot: `Positioned` white 6px circle
- Public interface unchanged: `Map<DateTime, int> moodData`, `Function(DateTime) onDayTap`

### mood_chart.dart
- Keep `fl_chart`, restyle:
  - Line: `LinearGradient` gold stroke (use `LineChartBarData.gradient`)
  - Area: gold at 15% opacity
  - Grid: removed (`gridData: FlGridData(show: false)`)
  - Last point: custom dot with glow `BoxShadow`
  - Axis labels: Manrope 10px
- Public interface unchanged: `List<MoodEntry> entries`

### mood_entry_card.dart
- Headline → Newsreader `headlineSerifMedium`
- Date → `labelCaps`
- Score → "X/10" in `headlineSerifItalic`
- Left thumbnail: 64×64 `BorderRadius.circular(8)`, mood color bg
- Public interface unchanged: `MoodEntry entry`

### streak_counter.dart
- Fire icon in 48×48 gold gradient `BorderRadius.circular(12)` box
- "X Days" in Newsreader 22px bold
- "CURRENT STREAK" label-caps above
- "Longest: X days" Manrope small muted below
- Public interface unchanged: `int currentStreak`, `int longestStreak`

---

## Files Changed Summary

| File | Change type |
|---|---|
| `pubspec.yaml` | Add `google_fonts: ^6.2.1` |
| `lib/config/theme.dart` | Full rewrite — new palette, typography, helpers |
| `lib/config/constants.dart` | Mood labels updated |
| `lib/main.dart` | Nav bar swap, FAB moved to HomeScreen |
| `lib/screens/home_screen.dart` | Full visual redesign |
| `lib/screens/mood_entry_screen.dart` | Full visual redesign |
| `lib/screens/calendar_screen.dart` | Full visual redesign |
| `lib/screens/insights_screen.dart` | Full visual redesign |
| `lib/screens/settings_screen.dart` | Full visual redesign |
| `lib/widgets/bottom_nav_bar.dart` | Full rebuild |
| `lib/widgets/mood_scale_widget.dart` | Bar chart replaces emoji row |
| `lib/widgets/emotion_tag_selector.dart` | Grid chips with icons |
| `lib/widgets/calendar_heatmap.dart` | Square cells, new color scale |
| `lib/widgets/mood_chart.dart` | Restyle only |
| `lib/widgets/mood_entry_card.dart` | Restyle only |
| `lib/widgets/streak_counter.dart` | Restyle only |

**Files NOT changed (zero touch):**
`lib/models/*`, `lib/services/*`, `lib/providers/*`, `lib/utils/*`

---

## Success Criteria

- [ ] All 5 screens visually match `design/stitch_daily_mood_tracker/` screenshots
- [ ] All existing features work: mood logging, calendar, insights, notifications, PDF export
- [ ] `flutter analyze` passes with 0 errors
- [ ] Bottom nav 4-tab navigation works correctly
- [ ] MoodEntry opens via FAB (not nav tab)
- [ ] No backend regressions
