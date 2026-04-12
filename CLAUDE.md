# EMOTRACE — DUAL AGENT COORDINATION PROTOCOL
# Auto-loaded every session via CLAUDE.md
# Project: Emotrace | Rajat Mahajan (feature/mood_to_tracker_1) | Piyush Puri (feature/mood_to_tracker_2)
# For full detail on merge conflicts, dependency blockers, HIGHLIGHT.md format → read .claude/DUAL_AGENT_MEGA_PROMPT.md

---

## IDENTITY

You are one of two parallel Flutter developer AI agents working on EMOTRACE.
Determine which developer's session you are in from the active git branch:
- `feature/mood_to_tracker_1` → You are Rajat Mahajan
- `feature/mood_to_tracker_2` → You are Piyush Puri

Sign EVERYTHING with your author name — commits, file headers, HIGHLIGHT.md entries, TODO comments.
Branch structure: main → develop → your feature branch. Never push to develop or main directly.

---

## PRE-SESSION SANITY CHECK (Run first, before anything else)

```bash
git status                          # Must be clean. If not: commit WIP first.
git branch | grep "^\*"             # Must show YOUR feature branch. Not main. Not develop.
head -5 HIGHLIGHT.md                # Must exist. If missing → S1 (Fresh Start).
git diff --stat && git diff --cached --stat  # Both must be empty.
```

If ANY check fails → STOP and fix before continuing.

---

## EVERY SESSION — RUN IN THIS ORDER

1. Pass all 4 sanity checks above
2. `git fetch origin && git pull origin develop` — pull latest from develop
3. If CONFLICT appears → resolve fully before any code (see DUAL_AGENT_MEGA_PROMPT.md for merge rules)
4. Read HIGHLIGHT.md → understand current state
5. Work only your PENDING queue, independently
6. Update HIGHLIGHT.md fully → push → raise PR to develop

---

## THE 6 SITUATIONS

| # | Condition | Action |
|---|-----------|--------|
| S1 | No HIGHLIGHT.md + no code | Build skeleton from .md specs only. Create HIGHLIGHT.md. Push. |
| S2 | HIGHLIGHT.md exists | Normal session — read it, work your queue, update it. |
| S3 | Merge conflicts | Resolve before any code. Never discard either side. |
| S4 | Dependency blocked | Specs complete → build it yourself. Specs missing → message other dev, wait 30 min, then skeleton only. |
| S5 | HIGHLIGHT.md outdated | Reconcile with actual lib/ files first, commit, then proceed as S2. |
| S6 | Built code differs from spec | Trust built code. Log drift. Never silently overwrite working code. |

---

## SPEC AUTHORITY HIERARCHY

When sources conflict, this order wins:

1. `DATABASE_SCHEMA.md` — field names, types, relationships
2. `APP_ARCHITECTURE.md` — layer patterns, state management, navigation
3. Built code in git — if working and committed, trust it over spec
4. `WEEK_1_BREAKDOWN.md` — sprint priorities
5. `FLUTTER_PROJECT_STRUCTURE.md` — naming, folders
6. `EMOTRACE_BUILD_PLAN_COMPLETE.md` — future vision only

---

## CODING LAWS

1. **git pull from develop first. Always.** Before anything else, after sanity checks.
2. **Conflicts resolved before any code. Always.**
3. **Read HIGHLIGHT.md before writing anything. Always.**
4. **Work only your queue. Work independently.** Do not wait for the other developer.
5. **Dependency blocked? Check specs first.** Complete specs → build real code. Incomplete → message, wait 30 min, skeleton.
6. **Never delete HIGHLIGHT.md entries. Only add.**
7. **Sign everything with your author name.** Every commit, file header, decision.
8. **Feature branch only. Never push to develop or main.**
9. **PR to develop every session end.** Raise it. Notify other developer.
10. **Spec authority hierarchy applies always.**
11. **Spec drifted? Trust what is built. Log the drift. Never silently overwrite.**
12. **HIGHLIGHT.md is your coordination file. If it is not there, it does not exist for the team.**

---

## HIGHLIGHT.md UPDATE DISCIPLINE

These rules exist because missing them causes merge conflicts, duplicate work, and stale coordination state.

**After EVERY task you complete:**

**1. Re-read before editing — never assume.**
Before writing any update, Read the full Last Session block. Do NOT assume the date or summary is already correct from a previous edit this session.

**2. Update dates on every file you touched today.**
If you edited a file already in COMPLETED FILES, update its date AND description. A file touched today must not show yesterday's date.

**3. Cross-developer impact = HIGHLIGHT.md entry, not just chat.**
If something you built can be reused by the other developer, or changes how they should implement their queue:
- Add a 💡 note under their specific queue task
- Add a row to CROSS-DEPENDENCY FLAGS with Status: Ready to use
Mentioning it in chat output is NOT enough — the other developer's Claude never reads this chat.

**4. Medium/Low Priority: mark done when done.**
If a task in Medium or Low Priority is completed as part of another task, mark it [x] immediately.

**5. Before closing, run this checklist:**
- [ ] Last Session date matches today's actual date
- [ ] Last Session summary covers ALL tasks done this session
- [ ] Every file touched today has today's date + updated description in COMPLETED FILES
- [ ] Other developer's queue has 💡 tips for anything they can reuse
- [ ] CROSS-DEPENDENCY FLAGS has an entry for any shared output
- [ ] Medium/Low Priority tasks completed incidentally are checked off

---

## END OF SESSION CHECKLIST

- [ ] All HIGHLIGHT.md UPDATE DISCIPLINE checks above passed
- [ ] FOLDER SNAPSHOT in HIGHLIGHT.md matches `find lib/ -name "*.dart" | sort`
- [ ] All files created today have author name + date in header comment
- [ ] All TODO comments have your author name inline
- [ ] `flutter analyze` passes with 0 errors (warnings OK)
- [ ] Any new packages in pubspec.yaml logged in DECISIONS LOG
- [ ] Any spec drift logged in SPEC DRIFT LOG
- [ ] `git status` shows clean working tree
- [ ] PR raised: your branch → develop
- [ ] Other developer notified

---

# Claude.md - Working with Claude Code for EMOTRACE

**Purpose:** Guide for using Claude Code to accelerate development  
**Status:** Ready for Week 2+ (after foundation is set)  
**Decision:** YOU decide if you want to use Claude Code or code solo

---

## WHEN TO USE CLAUDE CODE

### ✅ Good Use Cases (Accelerates Development)
- Generating boilerplate UI screens (mood_entry_screen.dart, calendar_screen.dart)
- Creating widget components (mood_scale_widget.dart, emotion_tags.dart)
- Writing data service CRUD operations
- Generating state management providers
- Creating test files
- Refactoring code for clarity

### ❌ Poor Use Cases (Slows You Down)
- Complex algorithms (pattern detection - you should write this)
- App architecture decisions (you should understand the structure)
- Authentication logic (you should know how JWT works)
- Database migrations (you should understand SQL)
- Performance optimization (requires deep understanding)

---

## HOW TO USE CLAUDE CODE EFFECTIVELY

### Step 1: Set Up in Week 1
After Week 1 foundation is complete:
- Ensure all files are in correct folders
- Database working with sample data
- Code compiles without errors
- All committed to GitHub

### Step 2: Create `.claude` Project File

In project root, create a file `.claude` with context:

```
EMOTRACE Project Overview
========================

Project: EMOTRACE - Mood Tracking App
Language: Flutter/Dart
Database: SQLite (local-first)

Folder Structure:
- lib/models/ = Data classes
- lib/services/ = Business logic
- lib/providers/ = State management
- lib/screens/ = Full page screens
- lib/widgets/ = Reusable components
- lib/config/ = Theme, routes, constants
- lib/utils/ = Helper functions

5 Screens to Build:
1. Home Dashboard - Shows today's mood, streaks, recent entries
2. Mood Entry - All-in-one: mood (1-10) + emotions + notes
3. Calendar - GitHub-style heatmap of moods
4. Insights - Patterns, trends, analytics
5. Settings - Theme, notifications, data management

Key Algorithms:
- Streak calculation: Count consecutive days with entries
- Stability score: Standard deviation of mood last 30 days
- Pattern detection: Group moods by day-of-week, find patterns
- Emotion frequency: Count emotion tags, sort by frequency

Dependencies:
- provider: State management
- sqflite: SQLite database
- fl_chart: Charts for insights
- flutter_local_notifications: Push notifications
- intl: Date formatting

App Structure:
- Dark theme (teal #06D6A0, orange #F77F00)
- No authentication in MVP
- All data local (no servers)
- 30-second mood check-in

Current Status:
- Week 1: Foundation complete (database, navigation, blank screens)
- Week 2: About to build Home Dashboard
- Using Claude Code for boilerplate + components
```

### Step 3: When to Ask Claude Code (Examples)

**Example 1: Generate Home Dashboard Screen**
```
Prompt to Claude Code:

"Generate home_screen.dart with:
- Greeting 'Hello, [Name]'
- Today's mood card showing emoji + score + vibe label
- Streak counter (current + longest)
- Recent entries list (last 3 entries)
- Big green '+Log Mood' button at bottom
- Connect to MoodProvider to fetch data
- Use AppTheme for styling
- Add loading skeleton if data not ready"

Claude Code generates: Entire screen with proper imports, state management, styling
You do: Review code, test interactions, adjust if needed
```

**Example 2: Generate Mood Scale Widget**
```
Prompt to Claude Code:

"Generate mood_scale_widget.dart:
- Show emoji faces for moods 1-10
- Color gradient (red → green)
- Tap to select
- Show 'SELECTED' with sparkle when chosen
- Show motivational text based on mood
- Return selected mood score to parent"

Claude Code generates: Complete widget with interaction logic
You do: Test it, integrate into mood_entry_screen
```

**Example 3: Generate Calendar Heatmap**
```
Prompt to Claude Code:

"Generate calendar_heatmap.dart:
- Display last 90 days as color grid
- Red (1-2) Orange (3-4) Yellow (5-6) Green (7-8) DarkGreen (9-10)
- Show week labels (M T W T F S S)
- Month navigation (arrows)
- Tap day → show mood/emotions/notes
- Show total entries count
- Fetch data from MoodProvider"

Claude Code generates: Full calendar component
You do: Test interactions, handle tap events
```

---

## WORKFLOW: Using Claude Code

### Daily Workflow (Week 2+)

**Morning (You):**
1. Open next screen or component from build plan
2. Review what needs to be built
3. Write prompt for Claude Code (be specific)
4. Commit current code to GitHub

**Claude Code (AI):**
1. Receives prompt with context (from .claude file)
2. Generates complete, production-ready component
3. Includes imports, state management, styling
4. Returns code ready to use

**Afternoon (You):**
1. Copy generated code into project
2. Run `flutter run` to test
3. Make adjustments if needed
4. Commit changes to GitHub
5. Move to next screen/component

### Speed Estimate

| Task | Without Claude | With Claude |
|------|---|---|
| Home Dashboard screen | 6 hours | 2 hours (review + test) |
| Mood scale widget | 3 hours | 1 hour |
| Calendar heatmap | 8 hours | 3 hours |
| Emotion tag selector | 4 hours | 1.5 hours |
| State management | 6 hours | 2 hours |
| **Total (5 screens)** | **~50 hours** | **~20 hours** |

**Time saved: ~30 hours per week (40% faster!)**

---

## PROMPTING BEST PRACTICES FOR EMOTRACE

### ✅ GOOD PROMPTS

```
"Generate home_screen.dart that:
- Shows greeting: 'Hello, [Name]'
- Shows today's mood if logged (emoji + score + vibe label)
- Shows 'Tap to log mood' if no mood for today
- Shows streak counter (7 days 🔥)
- Shows longest streak (23 days)
- Shows recent entries list:
  - Last 3 entries
  - Format: Date - Score/10 - Emotions
  - Tap to expand details
- Big green button at bottom: '+Log Mood'
- Use Consumer<MoodProvider> to get data
- Add loading skeleton while data fetches
- Use AppTheme colors for styling
- Match design from emotrace_design_validation.md"
```

### ❌ BAD PROMPTS

```
"Make the home screen"  // Too vague
"Generate home_screen"  // No details
"Build a mood tracker"  // Wrong scope
"Make it pretty"  // Subjective
```

### TEMPLATE FOR GOOD PROMPTS

```
"Generate [filename].dart that:
- [Requirement 1]
- [Requirement 2]
- [Requirement 3]
- Uses [Provider/Service] for data
- Styled with [AppTheme/Colors]
- Matches [design reference]
- [Any special logic]"
```

---

## WHAT CLAUDE CODE CANNOT DO WELL

❌ **Pattern detection algorithms** - You should code these:
- Streak calculation logic
- Stability score formula
- Day-of-week pattern detection
- These are business-critical, need your understanding

❌ **Critical algorithms** - Understand every line:
- Authentication (even basic JWT)
- Database operations
- State management flow

❌ **Architecture decisions** - You decide:
- Where to put logic
- How screens connect
- Provider structure

---

## CODE REVIEW CHECKLIST (After Claude Code)

When you receive code from Claude Code, review:

- [ ] Imports are correct
- [ ] No unused imports
- [ ] Follows Dart style (camelCase, etc.)
- [ ] Uses correct Provider syntax
- [ ] Database queries correct
- [ ] Error handling present
- [ ] Loading states included
- [ ] Empty states handled
- [ ] Comments explain complex logic
- [ ] Matches your design
- [ ] No hardcoded values (use constants)

If anything looks wrong, ask Claude Code to fix it:

```
"The calendar_heatmap.dart you generated has an issue:
- The color mapping is wrong (off by 1)
- The null check is missing
- The date formatting doesn't match

Can you fix these three things?"
```

---

## DECISION: SHOULD YOU USE CLAUDE CODE?

### ✅ USE CLAUDE CODE IF:
- You want to launch faster (Week 8 vs Week 12)
- You're comfortable reviewing + testing code
- You want to focus on algorithms + logic
- You have partner helping (divide work)
- You understand the architecture

### ❌ DON'T USE CLAUDE CODE IF:
- You want to learn every line of code
- You have plenty of time (12+ weeks)
- You don't trust code from AI
- You prefer coding everything yourself

### RECOMMENDATION

**Use Claude Code for boilerplate + UI components (Week 2-6)**
**Write algorithms yourself (Week 5-7)**
**Review + test all code (throughout)**

This gives you ~40% speed improvement while keeping you in control.

---

## SAMPLE CLAUDE CODE SESSION (Week 2)

### You Write Prompt:

```
Generate home_screen.dart for EMOTRACE that:

1. GREETING SECTION:
   - "Hello, [Name]" (get from MoodProvider)
   - "Monday, April 11" (current date formatted)

2. TODAY'S MOOD CARD:
   - If mood logged: Show emoji + "7/10" + "VIBE: BALANCED"
   - If no mood: Show "Tap to log mood"
   - Tap → Navigate to mood_entry_screen

3. STREAK SECTION:
   - Current streak: "7 day streak 🔥" (big, prominent)
   - Longest streak: "Longest: 23 days"
   - Get from MoodProvider

4. RECENT ENTRIES:
   - Title: "Recent entries"
   - Show last 3 entries
   - Each entry: [emoji] Yesterday - 7/10 - Calm, Productive
   - Tap entry → Show full details
   - Empty state if no entries

5. ACTION BUTTON:
   - Big green button at bottom: "+ Log Mood"
   - Tap → Navigate to mood_entry_screen

Use:
- Consumer<MoodProvider> to get moods
- AppTheme for colors (teal #06D6A0, orange #F77F00)
- flutter_intl for date formatting
- Loading skeleton while data fetches
- Error handling with try-catch

Style:
- Dark theme by default
- Rounded corners (radius 12)
- Smooth animations (300ms fade-in)
- No hardcoded values - use CONSTANTS
```

### Claude Code Returns:

Complete `home_screen.dart` with:
- All imports
- Consumer<MoodProvider> setup
- All widgets styled correctly
- Navigation logic
- Error handling
- Loading states
- Empty states
- Comments explaining logic
- Ready to use!

### You:

1. Copy code into lib/screens/home_screen.dart
2. Run `flutter run`
3. Test:
   - Tap "+ Log Mood" → navigates to mood entry
   - Tap entry → shows details
   - Refresh data → updates
   - No mood → empty state shows
4. If issues, ask Claude Code to fix
5. Commit to GitHub
6. Move to next screen (Mood Entry)

**Total time: 2 hours (review, test, fix, commit)**

---

## TL;DR

**Use Claude Code to:**
- Generate boilerplate code
- Build UI screens + components
- Create CRUD services
- Write test files

**Don't use Claude Code for:**
- Business logic algorithms
- Architecture decisions
- Critical calculations

**Result:** 40% faster development while staying in control

---

## FINAL NOTE

**You're the architect. Claude Code is your assistant.**

You make decisions. Claude Code implements them quickly. You review, test, and own the code.

This is how professional teams work: Senior developer decides what to build, junior builds it, senior reviews.

---

*Claude.md - EMOTRACE Development Guide*  
*April 11, 2026*
