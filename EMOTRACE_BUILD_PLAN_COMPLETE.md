# EMOTRACE Complete Build Plan (8 Weeks)

**Timeline:** Week 1 (Setup) → Week 8 (Launch)  
**Total Hours:** 480 hours solo developer at 60 hrs/week  
**Cost:** ₹10,100 (app store fees only) + ₹0/month maintenance  

---

## WEEK 1: Foundation (Setup + Database + Navigation)

**Hours:** 60  
**Goal:** Have blank app with working database and 5 screens

### Daily Breakdown
- **Mon:** Environment + project setup
- **Tue:** Theme system + config + data models
- **Wed:** SQLite database + CRUD operations
- **Thu:** State management (providers)
- **Fri:** Screens skeleton + bottom navigation

### Deliverable
✅ Working Flutter app  
✅ SQLite database functional  
✅ 5 blank screens with tab navigation  
✅ Code on GitHub  

### Success Criteria
- App compiles without errors
- Database saves/loads data
- Can navigate between screens
- No console warnings

---

## WEEK 2: Home Dashboard (Most Important Screen)

**Hours:** 50  
**Goal:** Complete Home Dashboard screen

### What to Build
1. **Greeting Section** (2 hours)
   - "Hello, [Name]"
   - Date label "Monday, April 11"
   
2. **Today's Mood Card** (6 hours)
   - Show emoji + mood score (7/10)
   - Show "VIBE: BALANCED" label
   - Show yesterday's mood if available
   - If no mood logged: Show "Tap to log mood"

3. **Streak Counter** (4 hours)
   - Display current streak (e.g., "7 day streak 🔥")
   - Calculate streak from database
   - Show longest streak if available
   - Progress bar toward goal

4. **Recent Entries List** (10 hours)
   - Show last 3 mood entries
   - Each entry: Date | Emoji | Mood | Emotions
   - Example: "Yesterday - 7/10 😊 - Calm, Productive"
   - Click entry → Show details
   - Empty state if no entries

5. **Big Green Button** (2 hours)
   - "+ Log Mood" button
   - Tap → Navigate to Mood Entry screen
   - Always accessible at bottom

6. **Polish** (6 hours)
   - Animations (fade-in, slide)
   - Loading states
   - Error handling
   - Empty states
   - Test on device

### Key Code Components
- home_screen.dart (main screen)
- home_dashboard_card.dart (mood card widget)
- recent_entries_list.dart (recent moods widget)
- streak_counter.dart (streak badge)

### Testing
- Tap mood card → details show
- Tap recent entry → details show
- Tap "+ Log Mood" → navigate to mood entry
- Refresh data → shows latest moods
- Empty state → friendly message if no data

### Deliverable
✅ Beautiful home dashboard matching design  
✅ All interactive elements working  
✅ Data persisting from database  
✅ Smooth animations  

---

## WEEK 3: Mood Entry Screen (Core Feature)

**Hours:** 50  
**Goal:** Complete all-in-one mood entry (mood + emotions + notes)

### What to Build
1. **Mood Scale 1-10** (12 hours)
   - Display 10 emoji options (😢 😟 😕 😐 🙂 😊 😄 😁 🤩 🌟)
   - Color gradient (red → green)
   - Tap to select
   - Show "SELECTED" highlight with sparkle
   - Show motivational text based on mood:
     - 1-3: "It's okay, you're noticing"
     - 4-6: "You're handling it"
     - 7-10: "You're doing great!"

2. **Emotion Tag Selector** (10 hours)
   - Display 8 emotions in grid:
     - Anxious, Calm, Stressed, Happy, Sad, Grateful, Overwhelmed, Focused
   - Multi-select (checkboxes or toggles)
   - Show checkmarks when selected
   - Clear visual feedback

3. **Notes Input Field** (6 hours)
   - "REFLECTION NOTES" title
   - Text input (optional)
   - Character count (0/500)
   - Placeholder: "What happened? Why do you feel this way?"
   - Auto-grow as user types

4. **Save Button** (4 hours)
   - Large green "Save Mood Entry" button
   - Tap → Save to database
   - Show "✓ Saved!" confirmation
   - Disable button while saving
   - Handle errors gracefully

5. **Headers + Labels** (4 hours)
   - "DAILY CHECK-IN" label
   - "How are you feeling?"
   - "It takes 30 seconds" subtitle
   - All labels from design

6. **Navigation** (4 hours)
   - Back button to Home
   - After save → return to Home
   - Show success message

### Key Code Components
- mood_entry_screen.dart (main screen)
- mood_scale_widget.dart (1-10 scale)
- emotion_tag_selector.dart (emotion grid)
- notes_input.dart (text field)

### Testing
- Tap each mood score → shows selected
- Select multiple emotions → all show
- Type notes → character count updates
- Tap Save → Saves to database
- Go back → Home shows new entry
- No mood selected → Show error
- Notes > 500 chars → Show error

### Deliverable
✅ Complete mood entry screen  
✅ All-in-one experience (mood + emotions + notes)  
✅ Data saved to database  
✅ Proper validation + error handling  

---

## WEEK 4: Calendar Heatmap (Visual Analytics)

**Hours:** 50  
**Goal:** GitHub-style calendar showing emotional patterns

### What to Build
1. **Month/Year Navigation** (4 hours)
   - Show "April 2026"
   - Left/right arrows to change month
   - Jump to current month button

2. **Color-Coded Grid** (12 hours)
   - Display last 90 days in grid
   - Each day = colored square
   - Colors based on mood:
     - Red (1-2) | Orange (3-4) | Yellow (5-6) | Green (7-8) | Dark Green (9-10)
     - Gray = no entry
   - Row labels: M T W T F S S (weekdays)
   - Optimize for performance (lazy load if needed)

3. **Tap Day → See Details** (8 hours)
   - Tap any day → Show popup/modal
   - Display:
     - Date
     - Mood score + emoji
     - Emotions selected
     - Notes from that day
   - Close popup → return to calendar

4. **Streak Counters** (6 hours)
   - Current Streak: "7 days 🔥"
   - Longest Streak: "23 days"
   - Progress bar toward goal
   - Calculate from database

5. **Legend** (4 hours)
   - Show color meanings
   - "1-2: Red | 3-4: Orange | 5-6: Yellow | 7-8: Light Green | 9-10: Dark Green"
   - Total entries count

6. **Insights Below Calendar** (6 hours)
   - "April Trends"
   - Example: "You've been 15% more positive this month compared to March"
   - Calculate trend from data

7. **Loading + Empty States** (4 hours)
   - Loading skeleton while data fetches
   - Empty state if no entries: "No data yet. Log your first mood!"

### Key Code Components
- calendar_screen.dart (main)
- calendar_heatmap.dart (grid)
- day_detail_modal.dart (popup)
- streak_widget.dart (streak counter)

### Testing
- Navigate months → calendar updates
- Tap day with mood → shows details
- Tap day without mood → shows empty
- Streak calculation correct
- Colors match mood scores
- Legend clear and visible

### Deliverable
✅ Beautiful heatmap calendar  
✅ Interactive (tap to see details)  
✅ Streak tracking working  
✅ Visual pattern insights  

---

## WEEK 5: Insights + Pattern Detection (Algorithms)

**Hours:** 60  
**Goal:** Show mood patterns, trends, and analytics

### What to Build
1. **Stability Score** (8 hours)
   - Calculate average mood (last 30 days)
   - Calculate standard deviation (variance)
   - Convert to 1-10 scale
   - Display: "7.2/10" with trend arrow (↑ or ↓)
   - Show change from last week

2. **Mood Trend Chart** (12 hours)
   - Line chart (last 30 days)
   - X-axis: Days (Mon-Sun)
   - Y-axis: Mood 1-10
   - Smooth curve connecting points
   - Color: Teal
   - Use fl_chart library

3. **Day-of-Week Patterns** (10 hours)
   - Analyze last 90 days
   - Group moods by day of week
   - Find patterns:
     - Best day: "You feel better on Tuesdays"
     - Worst day: "Anxiety peaks on Mondays"
   - Show confidence (need min 7 data points)
   - Display as cards with icons

4. **Emotion Frequency** (8 hours)
   - Count emotion occurrences (last 30 days)
   - Top emotions: Calm (12), Stressed (8), Happy (6)
   - Display as:
     - Horizontal bar chart, OR
     - Colored tags with counts
   - Sort by frequency

5. **Pattern Insights** (10 hours)
   - Detect correlations (if user tracks activities):
     - "Mood ↑15% on days you exercise"
     - "Sleep quality impacts stability"
   - Generate actionable advice:
     - "Try scheduling hard tasks on Tuesdays"
     - "Weekend mood lower - plan relaxation"
   - Require min data (avoid false patterns)

6. **Empty State** (4 hours)
   - If <3 entries: "Need more data to show patterns"
   - If <30 entries: Show available data, note "More data = better insights"
   - Encourage: "Keep logging!"

7. **Loading + Animation** (8 hours)
   - Load data asynchronously
   - Show skeleton while loading
   - Smooth chart animations
   - Refresh button

### Key Code Components
- insights_screen.dart (main)
- stability_score.dart
- mood_trend_chart.dart (fl_chart)
- pattern_card.dart
- insight_service.dart (algorithms)

### Algorithms to Implement

**Stability Score:**
```
avg = mean(moods_30_days)
std_dev = standardDeviation(moods_30_days)
stability = 10 - (std_dev * 1.5)  // normalize to 1-10
trend = compare(stability_this_week, stability_last_week)
```

**Day of Week Pattern:**
```
for each day (Mon-Sun):
  avg_mood = average(moods where day==Monday/Tuesday/etc)
best_day = max(avg_mood)
insight = "You feel better on " + best_day
```

**Emotion Frequency:**
```
emotions = flatten(all emotion_tags from entries)
frequency = count(emotions)
sort by frequency DESC
top_5 = take(5)
```

### Testing
- Add 30 moods with variety → See trend
- Add moods all high on Tuesday → Pattern shows
- < 3 entries → Empty state shows
- Chart renders smoothly
- Stability score calculates correctly
- Emotions sorted by frequency

### Deliverable
✅ Complete insights dashboard  
✅ Working algorithms for patterns  
✅ Beautiful data visualizations  
✅ Actionable insights displayed  

---

## WEEK 6: Settings + Data Management

**Hours:** 30  
**Goal:** Complete settings screen + data export + notifications

### What to Build
1. **Theme Toggle** (4 hours)
   - Dark Mode toggle (on by default)
   - Switch immediately
   - Save preference to database
   - Light mode option for future

2. **Notifications** (8 hours)
   - Daily Reminder toggle
   - Reminder Time picker (default 8:00 PM)
   - Use flutter_local_notifications
   - Test: Can receive notification
   - Permission handling

3. **About Section** (2 hours)
   - App Name: EMOTRACE
   - Version: 1.0.0
   - Privacy notice: "Your data stays on your device"

4. **Delete Data** (4 hours)
   - "Delete All Data" button (red, dangerous)
   - Confirmation dialog: "Are you sure?"
   - Delete all mood entries, settings
   - Reset app state
   - Return to home

5. **Logout Button** (2 hours)
   - "Logout" button for future auth
   - For now: Non-functional placeholder
   - Will implement in Month 2

6. **Privacy Policy** (2 hours)
   - Simple privacy policy text:
     - Data stays on device
     - No cloud sync
     - No tracking
     - User can delete anytime

7. **Polish** (2 hours)
   - Smooth transitions
   - Loading states for long operations
   - Success messages
   - Error handling

### Key Code Components
- settings_screen.dart
- theme_toggle.dart
- notification_settings.dart
- data_deletion_dialog.dart

### Testing
- Toggle dark mode → theme changes
- Set reminder time → notification fires at correct time
- Delete all data → all moods gone
- Refresh app → settings persist
- Privacy policy readable

### Deliverable
✅ Complete settings screen  
✅ Notifications working  
✅ Data management (delete)  
✅ Theme persistence  

---

## WEEK 7: Testing + Optimization + Polish

**Hours:** 70  
**Goal:** Make app production-ready

### What to Do
1. **Unit Tests** (15 hours)
   - Test mood color mapping
   - Test streak calculation
   - Test stability score algorithm
   - Test day-of-week pattern detection
   - Test emotion frequency calculation
   - Aim for 80%+ coverage

2. **Widget Tests** (15 hours)
   - Test mood scale interaction
   - Test emotion tag selection
   - Test calendar grid rendering
   - Test chart rendering
   - Test button actions

3. **Integration Tests** (10 hours)
   - Full flow: Log mood → See on home
   - Full flow: Log mood → See on calendar
   - Full flow: Log 30 moods → See insights
   - Database persistence across restarts
   - Empty state handling

4. **Manual QA** (15 hours)
   - Test on actual device (iOS + Android)
   - All screen rotations (portrait/landscape)
   - Dark mode appearance
   - All buttons/interactions
   - Edge cases:
     - No data
     - Huge amounts of data
     - 500+ character notes
     - Special characters in notes
   - Performance (app launch time <2s)

5. **Optimization** (10 hours)
   - Reduce app size (remove unused packages)
   - Optimize calendar rendering (virtualization)
   - Cache insights calculations
   - Database query optimization (use indexes)
   - Target: <50MB app, 60FPS animations

6. **Bug Fixes** (5 hours)
   - Fix any bugs found during testing
   - Handle edge cases
   - Improve error messages

### Success Criteria
- ✅ 0 console errors/warnings
- ✅ 80%+ test coverage
- ✅ App launches in <2 seconds
- ✅ 60 FPS animations
- ✅ <50MB app size
- ✅ Works on iOS + Android
- ✅ Dark mode looks great
- ✅ All interactions smooth

### Deliverable
✅ Production-ready code  
✅ Comprehensive tests  
✅ Optimized performance  
✅ Zero known bugs  

---

## WEEK 8: App Store Submission + Launch

**Hours:** 50  
**Goal:** Get app on iOS App Store + Google Play Store

### iOS (App Store)
1. **Xcode Setup** (4 hours)
   - Configure signing certificates
   - Create provisioning profiles
   - Set bundle identifier
   - Set app version (1.0.0)

2. **App Store Connect** (4 hours)
   - Create app listing
   - Write description (from design)
   - Create 5 sets of screenshots (2-3 each):
     - Home Dashboard
     - Mood Entry
     - Calendar
     - Insights
     - Settings
   - Set keywords, category, rating
   - Write privacy policy
   - Review all info

3. **Build + Upload** (2 hours)
   - Create release build
   - Upload to App Store Connect
   - Set release notes

4. **Review** (2-3 days)
   - Apple reviews app
   - May request changes
   - Respond quickly
   - Approved → Live on App Store

### Android (Google Play)
1. **Google Play Setup** (2 hours)
   - Create signing key
   - Create app listing in Google Play Console
   - Write description (same as iOS)
   - Create 4-8 screenshots
   - Set privacy policy

2. **Build + Upload** (2 hours)
   - Create release APK
   - Upload to Google Play Console
   - Set version, release notes

3. **Review** (2-4 hours)
   - Google reviews (fast, often same day)
   - Approved → Live on Google Play

### Marketing + Launch
1. **Landing Page** (2 hours)
   - Simple one-pager at emotrace.app
   - Show screenshots
   - "Available on iOS + Android"
   - Email signup (optional)
   - Use Carrd.co (free tier)

2. **Reddit + Social** (3 hours)
   - Post on r/mentalhealth, r/flutter, r/iOS, r/android
   - Post on Twitter/X
   - Post on ProductHunt (optional)
   - Get feedback from early users

3. **Email List** (1 hour)
   - Send to waitlist (if any)
   - Announce app is live

### Success Criteria
✅ App on iOS App Store  
✅ App on Google Play Store  
✅ Both showing 5-star design  
✅ First users downloading  
✅ Positive reviews  

### Deliverable
✅ App live on both stores  
✅ First users using EMOTRACE  
✅ Ready for Month 2 (add auth, cloud sync, etc.)  

---

## COMPLETE TIMELINE

| Week | Phase | Hours | Status |
|------|-------|-------|--------|
| **1** | Foundation | 60 | ✓ Complete |
| **2** | Home Dashboard | 50 | ✓ Working |
| **3** | Mood Entry | 50 | ✓ Working |
| **4** | Calendar | 50 | ✓ Working |
| **5** | Insights | 60 | ✓ Working |
| **6** | Settings | 30 | ✓ Working |
| **7** | Testing + Optimize | 70 | ✓ Polished |
| **8** | Launch | 50 | ✓ Live |
| **TOTAL** | | **420 hours** | **🚀 LAUNCHED** |

---

## AFTER LAUNCH (Month 2+)

Once app is live and has users:

**Month 2-3 Ideas:**
- Authentication (email/password)
- Cloud backup (Firebase Firestore)
- Multi-device sync
- Apple Health integration
- Share insights with therapist (PDF export)
- Custom emotions
- Habit correlation (track exercises, sleep)

But for now: **Focus on these 8 weeks to get MVP live!**

---

## NOTES

- **Stay focused:** Don't add features beyond these 5 screens
- **Test thoroughly:** Week 7 is critical
- **Get feedback:** Launch early, iterate based on users
- **Keep simple:** Complexity = bugs = delays
- **Ship it:** Perfect is enemy of done

---

*EMOTRACE Complete Build Plan*  
*April 11, 2026*
