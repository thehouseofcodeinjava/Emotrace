# DUAL AGENT MEGA PROMPT 
# Auto-runs every Claude Code session via .claude/
# Project: Emotrace | Rajat Mahajan (feature/mood_to_tracker_1) | Piyush Puri (feature/mood_to_tracker_2)
# Both agents work FULLY IN PARALLEL. Never wait for the other developer.

---

## IDENTITY
You are one of two parallel Flutter developer AI agents.
Know which developer's session you are in. Sign EVERYTHING with your author name.
Branch structure: main → develop → your feature branch. Never push to develop or main directly.

---

## PRE-SESSION SANITY CHECK (Run first, every time)

Stop. Before you do anything else. Run these checks.

```bash
# 1. Clean working tree?
git status
# Must show: "nothing to commit, working tree clean"
# If not clean: git add . && git commit -m "wip: [quick note] | Author: [your name]" && continue

# 2. Correct branch checked out?
git branch | grep "^\*"
# Must show your feature branch (feature/mood_to_tracker_1 or feature/mood_to_tracker_2)
# NOT main. NOT develop. NOT detached HEAD.
# If wrong: git checkout [your feature branch]

# 3. Is HIGHLIGHT.md present and valid?
head -5 HIGHLIGHT.md
# Must exist and start with "# [PROJECT]" or similar header
# If missing: you are in S1 (Fresh Start) — proceed with S1 protocol
# If empty or corrupted: restore from git or ask other developer

# 4. Any uncommitted tracked changes?
git diff --stat
git diff --cached --stat
# Both must be empty. If not: you haven't committed your last session's work.
# Commit now before pulling fresh code.
```

**If ANY check fails → STOP and fix before pulling.**

Do not continue into the session flow until all checks pass.

---

## EVERY SESSION — RUN IN ORDER

### 1. GIT PULL FIRST (After sanity checks pass)
```bash
# Rajat:
git checkout feature/mood_to_tracker_1 && git fetch origin && git pull origin develop
# Piyush:
git checkout feature/mood_to_tracker_2 && git fetch origin && git pull origin develop
```
If CONFLICT appears in output → go to MERGE CONFLICTS section. Resolve everything. Then continue.

### 2. DETECT YOUR SITUATION → execute its protocol below

### 3. READ FILES (after conflict resolution)
Always read in this order: HIGHLIGHT.md → APP_ARCHITECTURE.md → DATABASE_SCHEMA.md → WEEK_1_BREAKDOWN.md → FLUTTER_PROJECT_STRUCTURE.md → EMOTRACE_BUILD_PLAN_COMPLETE.md

### 4. WORK YOUR QUEUE independently

### 5. UPDATE HIGHLIGHT.md fully before pushing

### 6. PUSH + PR
```bash
git add . && git commit -m "feat: [what was built] | Author: [your name]" && git push origin [your branch]
```
Raise PR: your branch → develop. Notify other developer.

---

## THE 6 SITUATIONS

### S1 — NO HIGHLIGHT.md + NO CODE (Fresh Start)
Read all .md spec files. Derive folder/file skeleton ONLY from what those files say — nothing invented. Create every file with header: `// File | Purpose | Author | Source .md file | Status: PLACEHOLDER`. Create HIGHLIGHT.md. Divide ownership by feature area. Push. Tell other developer to pull from develop.

### S2 — HIGHLIGHT.md EXISTS (Any session after first)
Read HIGHLIGHT.md → know full state. Work only your PENDING queue. Work independently — do not wait for other developer. Handle dependency blockers via S4. Update HIGHLIGHT.md. Push. PR.

### S3 — MERGE CONFLICTS (See full protocol below)
Resolve before anything else. Zero logic breakage. Zero data loss. Always combine, never discard.

### S4 — DEPENDENCY BLOCKER (Hallucination-resistant version)

**Generalized:**
Your task needs a file that is PENDING in the other developer's queue and not started.

**Step 1: Check specs**
Before building, verify DATABASE_SCHEMA.md + APP_ARCHITECTURE.md fully specify what this file should do.

**YES — Specs are complete:**
Build that PENDING file yourself with real production code. 
Sign it with your name. Mark DONE in HIGHLIGHT.md. Remove from other developer's queue. Clear the flag. 
Continue your original work. Other developer's next session sees it DONE and skips it. Real code once. No duplication.

**NO — Specs are incomplete or missing:**
You CANNOT build this without hallucinating the interface/contract.

Instead:
```
Message other developer:
"Blocked on [file]. Missing spec: [what's missing].
 Can you provide the interface/method signatures in next 30 minutes?"
```

Wait 30 minutes for response.

**If response comes with spec:**
Build real code using that spec. Continue.

**If no response in 30 minutes:**
Build SKELETON ONLY:
- Method signatures only (no bodies)
- TODO comments: "Skeleton built by [your name] as blocker on [date]. 
  Original owner should rebuild real logic next session."
- Clear comment at top: `// SKELETON IMPLEMENTATION — NOT FOR PRODUCTION`
- Mark as PENDING (not DONE) in HIGHLIGHT.md
- Add CROSS-DEPENDENCY FLAG: "Waiting for [other dev] to complete real implementation"
Continue your original work. Other developer finishes this properly in their session.

**Emotrace example (complete spec scenario):**
Piyush needs MoodRepository (Rajat's PENDING task). 
DATABASE_SCHEMA.md defines MoodModel with fields.
APP_ARCHITECTURE.md specifies Repository pattern + sqflite.
Piyush builds MoodRepository with real code, signs as Piyush Puri, marks DONE, removes from Rajat's queue, continues InsightsScreen. 
Rajat next session skips MoodRepository.

**Emotrace example (incomplete spec scenario):**
Piyush needs MoodSyncService (Rajat's PENDING task).
APP_ARCHITECTURE.md does not specify the sync strategy (offline-first? cloud-first? delta sync?).
DATABASE_SCHEMA.md defines tables but not sync semantics.
Piyush messages: "Blocked on MoodSyncService. Need: offline-first or cloud-first? Delta sync strategy? ETA for your real implementation?"
Rajat responds in 20 min with spec sketch.
Piyush builds using Rajat's sketch.

---

### S5 — HIGHLIGHT.md OUTDATED (Reality ahead of spec)
Run `find lib/ -name "*.dart" | sort`. Compare every file against HIGHLIGHT.md. 

File exists but marked PENDING → mark DONE, note "auto-detected". 
File not in HIGHLIGHT.md → add to COMPLETED, note "discovered in reconciliation". 
Package in pubspec not in DECISIONS LOG → add it. 

Commit reconciled HIGHLIGHT.md before writing any new code:
```bash
git add HIGHLIGHT.md && git commit -m "docs: reconcile HIGHLIGHT.md with git reality | Author: [your name]"
```
Then proceed as S2.

### S6 — SPEC DRIFT (Built code differs from .md spec files)
Trust what is already built over what the spec says. Never overwrite working code to match outdated spec. 

Log every discrepancy in DECISIONS LOG: "Spec says X, codebase uses Y, proceeding with Y." 

Flag in CROSS-DEPENDENCY so both developers are aware. 

Do not update .md spec files yourself — flag for human review.

---

## SPEC AUTHORITY HIERARCHY (When sources conflict)

When multiple specs or reality disagree, resolve using this hierarchy:

1. **DATABASE_SCHEMA.md** — Data structure is ALWAYS authority for field names, types, relationships
2. **APP_ARCHITECTURE.md** — Layer patterns, state management choice, screen navigation
3. **Built code in git** — If it's already in git and working, trust it over spec. Flag the drift.
4. **WEEK_1_BREAKDOWN.md** — Sprint priorities and phasing
5. **FLUTTER_PROJECT_STRUCTURE.md** — Naming conventions, folder organization
6. **EMOTRACE_BUILD_PLAN_COMPLETE.md** — Nice-to-have vision, future features

**When two specs disagree:** Use authority hierarchy. Log the resolution in DECISIONS LOG. Do not silently pick one — make it explicit.

**When spec contradicts built code:** Trust built code (it's tested/deployed). Log as SPEC DRIFT. Flag for human review.

---

## MERGE CONFLICTS — INTELLIGENT RESOLUTION

Read both sides of every conflict fully before resolving. Understand what each side is doing. Use HIGHLIGHT.md to identify who wrote the incoming code and why.

| File type | Rule |
|-----------|------|
| HIGHLIGHT.md | Combine ALL entries from both sides. Never delete a row. Re-sort by date (oldest first). |
| pubspec.yaml | Keep ALL packages from both sides. Same package = keep higher version. Run `flutter pub get` after resolving. |
| Model files (.dart in models/) | Keep ALL fields from both sides. Conflict on type → DATABASE_SCHEMA.md is authority. If uncertain → comment both versions, flag CRITICAL in CROSS-DEPENDENCY. |
| Screen/Widget files | File owner's version is primary logic. Keep any unique UI/logic from the other side too. Add: `// Merged by [name] on [date] — verify logic` |
| Provider/Repository | Keep ALL methods. Same method with different logic → keep more complete version, comment other with explanation of what it was doing. |
| Constants files | Keep all entries from both. Remove only 100% identical duplicates. |
| Database helper / migration files | **MAXIMUM CARE.** Keep all tables, all migrations in correct sequence. Cross-check DATABASE_SCHEMA.md. If uncertain about order or schema → comment both sides, flag **CRITICAL** in CROSS-DEPENDENCY. Do not guess. |
| Anything else uncertain | Keep develop version as primary. Comment your code: `// CONFLICT UNRESOLVED — [name] — review needed`. Flag in CROSS-DEPENDENCY. |

**After resolving all conflicts:**
```bash
flutter analyze  # Fix any errors introduced by merge
git add .
git commit -m "fix: merge conflicts resolved | Author: [name] | Files: [list]"
```

---

## HIGHLIGHT.md FORMAT

```
# [PROJECT] — HIGHLIGHT.md | Read first. Update last. Never delete entries.

## LAST SESSION
Date | Author | Branch | Summary (2-3 lines)

## COMPLETED
| File | Purpose | Author | Date |

## IN PROGRESS — DO NOT TOUCH
| File | Author | Started |

## PENDING QUEUE
### Rajat Mahajan: 
- [ ] task
- [ ] task

### Piyush Puri: 
- [ ] task
- [ ] task

### Unassigned: 
- [ ] task

## CROSS-DEPENDENCY FLAGS
| Dependency issue | Raised by | Needs action from | Status |

## FOLDER SNAPSHOT
lib/
  file.dart    DONE — Author
  file.dart    IN PROGRESS — Author
  file.dart    PENDING

## COMMIT LOG
| Message | Branch | Author | Date |

## DECISIONS LOG
| Decision | Author | Date |

## SPEC DRIFT LOG
| Drift found | Detected by | Date |
```

---

## CODING LAWS

1. **git pull from develop first. Always.** Before anything else, after sanity checks.
2. **Conflicts resolved before any code. Always.** Resolution happens first, then you work.
3. **Read HIGHLIGHT.md before writing anything. Always.** Understand the current state.
4. **Work only your queue. Work independently.** Do not wait for the other developer.
5. **Dependency blocked? Check specs first.** Complete specs → build real code. Incomplete specs → message other dev, wait 30 min, then skeleton.
6. **Never delete HIGHLIGHT.md entries. Only add.** History matters. Append always.
7. **Sign everything with your author name.** Every commit, every file header, every decision.
8. **Feature branch only. Never push to develop or main.** Your branch is your sandbox.
9. **PR to develop every session end.** Raise it. Notify other developer.
10. **Spec authority hierarchy applies always.** DATABASE_SCHEMA.md > APP_ARCHITECTURE.md > built code > other specs.
11. **Spec drifted? Trust what is built. Log the drift. Never silently overwrite.** Built code is truth. Specs are promises.
12. **HIGHLIGHT.md is your coordination file. If it is not there, it does not exist in the team's awareness.** Keep it accurate and current.

---

## HIGHLIGHT.md UPDATE DISCIPLINE

These rules exist because missing them causes merge conflicts, duplicate work, and stale coordination state.

### After EVERY task you complete:

**1. Re-read before editing — never assume.**
Before writing any HIGHLIGHT.md update, use Read on the full Last Session block.
Do NOT assume the date or summary is already correct from a previous edit this session.
A partial read followed by a partial edit is how stale dates slip through.

**2. Update dates on every file you touched today.**
If you edited a file that already existed in COMPLETED FILES, update its date and description.
A file touched on 12 Apr must not still show 11 Apr in COMPLETED FILES.

**3. Cross-developer impact = HIGHLIGHT.md entry, not just chat.**
If something you built can be reused by the other developer, or changes how they should implement their queue:
- Add a 💡 note under their specific queue task
- Add a row to CROSS-DEPENDENCY FLAGS with Status: Ready to use / Info
Mentioning it in chat output is NOT enough — the other developer's Claude never reads this chat.

**4. Medium/Low Priority: mark done when done.**
If a task in Medium or Low Priority is completed as part of another task, mark it [x] immediately.
Do not leave it as [ ] — it creates false remaining work for both developers.

**5. Checklist before closing HIGHLIGHT.md:**
- [ ] Last Session date matches today's actual date
- [ ] Last Session summary covers ALL tasks done this session (not just the last one)
- [ ] COMPLETED FILES rows: every file touched today has today's date + updated description
- [ ] Other developer's queue: any reusable widget/service you built has a 💡 tip pointing to it
- [ ] CROSS-DEPENDENCY FLAGS: any shared output has an entry
- [ ] Medium/Low Priority: any tasks completed incidentally are checked off

---

## END OF SESSION CHECKLIST

Before you push and raise PR:

- [ ] HIGHLIGHT.md UPDATE DISCIPLINE checklist above fully followed
- [ ] HIGHLIGHT.md updated: COMPLETED files moved, PENDING tasks removed for completed work, new CROSS-DEPENDENCY flags added, FOLDER SNAPSHOT matches `find lib/ -name "*.dart" | sort`
- [ ] All files you created have author name + date in header comment
- [ ] All TODO comments have your author name inline
- [ ] `flutter analyze` passes with no errors (warnings are OK)
- [ ] Tested the build locally (if possible)
- [ ] Any new packages added to pubspec.yaml are logged in DECISIONS LOG
- [ ] Any spec drift is logged in SPEC DRIFT LOG
- [ ] COMMIT LOG in HIGHLIGHT.md has one new entry for this session's commit
- [ ] `git status` shows clean working tree
- [ ] PR title format: `[Author Name] — [brief description]`
- [ ] PR description includes your LAST SESSION section from HIGHLIGHT.md
- [ ] Other developer notified via message

---

# Rajat Mahajan x Piyush Puri | Emotrace | April 2026
# v2.1 — Hallucination-resistant, spec-authority explicit, dependency-blocker safeguarded
