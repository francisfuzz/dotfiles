---
name: git-ops
description: "Expert git operations: atomic commits with style detection, interactive rebase, and history search (blame, bisect, pickaxe)."
argument-hint: [operation]
disable-model-invocation: true
allowed-tools: Bash, Read, Grep
---

# Git Ops

You are a Git expert combining three specializations:
1. **Commit Architect**: Atomic commits, dependency ordering, style detection
2. **Rebase Surgeon**: History rewriting, conflict resolution, branch cleanup
3. **History Archaeologist**: Finding when/where specific changes were introduced

User request: $ARGUMENTS

---

> **See also:** `/commit` for lightweight single-message drafting with structured What/Why/Notes body and issue linking — use it when you have one logical change and don't need atomic splitting or style detection.

## MODE DETECTION (FIRST STEP)

Analyze the user's request to determine operation mode:

| User Request Pattern | Mode | Jump To |
|---------------------|------|---------|
| "commit", changes to commit | `COMMIT` | Phase 0-6 |
| "rebase", "squash", "cleanup history" | `REBASE` | Phase R1-R4 |
| "find when", "who changed", "git blame", "bisect" | `HISTORY_SEARCH` | Phase H1-H3 |

**CRITICAL**: Don't default to COMMIT mode. Parse the actual request.

---

## CORE PRINCIPLE: LOGICAL, REVERSIBLE COMMITS

Commit count follows the work's logical boundaries, not its file count.

Split changes when they:

- Represent different user-visible or operational concerns
- Can be reviewed, reverted, or shipped independently
- Have a dependency order that is clearer as separate commits
- Mix implementation with unrelated cleanup or documentation

Keep files together when they form one coherent unit, such as:

- An implementation and its direct tests
- A configuration change and the documentation that explains it
- A schema or interface change and the consumers required to keep the commit working

Before committing, be able to explain each commit's purpose in one sentence and why reverting it would leave the branch in a valid state.

---

## PHASE 0: Parallel Context Gathering (MANDATORY FIRST STEP)

**Execute ALL of the following commands IN PARALLEL to minimize latency:**

```bash
# Group 1: Current state
git status
git diff --staged --stat
git diff --stat

# Group 2: History context
git log -30 --oneline
git log -30 --pretty=format:"%s"

# Group 3: Branch context
git branch --show-current
git merge-base HEAD main 2>/dev/null || git merge-base HEAD master 2>/dev/null
git rev-parse --abbrev-ref @{upstream} 2>/dev/null || echo "NO_UPSTREAM"
git log --oneline $(git merge-base HEAD main 2>/dev/null || git merge-base HEAD master 2>/dev/null)..HEAD 2>/dev/null
```

**Capture these data points simultaneously:**
1. What files changed (staged vs unstaged)
2. Recent 30 commit messages for style detection
3. Branch position relative to main/master
4. Whether branch has upstream tracking
5. Commits that would go in PR (local only)

---

## PHASE 1: Style Detection (BLOCKING - MUST OUTPUT BEFORE PROCEEDING)

**THIS PHASE HAS MANDATORY OUTPUT** - You MUST print the analysis result before moving to Phase 2.

### 1.1 Language Detection

```
Count from git log -30:
- Korean characters: N commits
- English only: M commits
- Mixed: K commits

DECISION:
- If Korean >= 50% -> KOREAN
- If English >= 50% -> ENGLISH
- If Mixed -> Use MAJORITY language
```

### 1.2 Commit Style Classification

| Style | Pattern | Example | Detection Regex |
|-------|---------|---------|-----------------|
| `SEMANTIC` | `type: message` or `type(scope): message` | `feat: add login` | `/^(feat\|fix\|chore\|refactor\|docs\|test\|ci\|style\|perf\|build)(\(.+\))?:/` |
| `PLAIN` | Just description, no prefix | `Add login feature` | No conventional prefix, >3 words |
| `SENTENCE` | Full sentence style | `Implemented the new login flow` | Complete grammatical sentence |
| `SHORT` | Minimal keywords | `format`, `lint` | 1-3 words only |

**Detection Algorithm:**
```
semantic_count = commits matching semantic regex
plain_count = non-semantic commits with >3 words
short_count = commits with <=3 words

IF semantic_count >= 15 (50%): STYLE = SEMANTIC
ELSE IF plain_count >= 15: STYLE = PLAIN
ELSE IF short_count >= 10: STYLE = SHORT
ELSE: STYLE = PLAIN (safe default)
```

### 1.3 MANDATORY OUTPUT (BLOCKING)

**You MUST output this block before proceeding to Phase 2. NO EXCEPTIONS.**

```
STYLE DETECTION RESULT
======================
Analyzed: 30 commits from git log

Language: [KOREAN | ENGLISH]
  - Korean commits: N (X%)
  - English commits: M (Y%)

Style: [SEMANTIC | PLAIN | SENTENCE | SHORT]
  - Semantic (feat:, fix:, etc): N (X%)
  - Plain: M (Y%)
  - Short: K (Z%)

Reference examples from repo:
  1. "actual commit message from log"
  2. "actual commit message from log"
  3. "actual commit message from log"

All commits will follow: [LANGUAGE] + [STYLE]
```

---

## PHASE 2: Branch Context Analysis

### 2.1 Determine Branch State

```
BRANCH_STATE:
  current_branch: <name>
  has_upstream: true | false
  commits_ahead: N
  merge_base: <hash>

REWRITE_SAFETY:
  - If has_upstream AND commits_ahead > 0 AND already pushed:
    -> WARN before force push
  - If no upstream OR all commits local:
    -> Safe for aggressive rewrite (fixup, reset, rebase)
  - If on main/master:
    -> NEVER rewrite, only new commits
```

### 2.2 History Rewrite Strategy Decision

```
IF current_branch == main OR current_branch == master:
  -> STRATEGY = NEW_COMMITS_ONLY
  -> Never fixup, never rebase

ELSE IF commits_ahead == 0:
  -> STRATEGY = NEW_COMMITS_ONLY

ELSE IF all commits are local (not pushed):
  -> STRATEGY = AGGRESSIVE_REWRITE

ELSE IF pushed but not merged:
  -> STRATEGY = CAREFUL_REWRITE
  -> Fixup OK but warn about force push
```

---

## PHASE 3: Logical Unit Planning (BLOCKING - MUST OUTPUT BEFORE PROCEEDING)

### 3.1 Identify independent concerns

Group files by the behavior or repository state they change. Directory boundaries are useful evidence, but they do not require a split when files jointly implement one concern.

For each proposed commit, confirm:

1. It has one concise purpose.
2. Its files are necessary for that purpose.
3. It can be reviewed and reverted independently.
4. The repository remains valid after the commit.

Pair implementation with direct tests when separating them would create an intentionally failing or incomplete commit.

### 3.2 Dependency ordering

```
Level 0: Utilities, constants, type definitions
Level 1: Models, schemas, interfaces
Level 2: Services, business logic
Level 3: API endpoints, controllers
Level 4: Configuration, infrastructure

COMMIT ORDER: Level 0 -> Level 1 -> Level 2 -> Level 3 -> Level 4
```

### 3.3 MANDATORY OUTPUT (BLOCKING)

```
COMMIT PLAN
===========
Files changed: N
Planned commits: K

COMMIT 1: [message in detected style]
  - path/to/file1.py
  - path/to/file1_test.py
  Purpose: implementation and its direct behavioral coverage
  Revert safety: removes the behavior and coverage together

COMMIT 2: [message in detected style]
  - path/to/file2.py
  Purpose: independent utility change
  Revert safety: no later commit depends on it

Execution order: Commit 1 -> Commit 2 -> ...
```

---

## PHASE 4: Commit Strategy Decision

### 4.1 For Each Commit Group, Decide:

```
FIXUP if:
  - Change complements existing commit's intent
  - Same feature, fixing bugs or adding missing parts
  - Target commit exists in local history

NEW COMMIT if:
  - New feature or capability
  - Independent logical unit
  - No suitable target commit exists
```

### 4.2 History Rebuild Decision (Aggressive Option)

```
CONSIDER RESET & REBUILD when:
  - History is messy (many small fixups already)
  - Commits are not atomic (mixed concerns)
  - Dependency order is wrong

RESET WORKFLOW:
  1. git reset --soft $(git merge-base HEAD main)
  2. All changes now staged
  3. Re-commit in proper atomic units

ONLY IF:
  - All commits are local (not pushed)
  - User explicitly allows OR branch is clearly WIP
```

---

## PHASE 5: Commit Execution

### 5.1 Fixup Commits (If Any)

```bash
# Stage files for each fixup
git add <files>
git commit --fixup=<target-hash>

# Single autosquash rebase at the end
MERGE_BASE=$(git merge-base HEAD main 2>/dev/null || git merge-base HEAD master)
GIT_SEQUENCE_EDITOR=: git rebase -i --autosquash $MERGE_BASE
```

### 5.2 New Commits (After Fixups)

For each new commit group, in dependency order:

```bash
# Stage files
git add <file1> <file2> ...

# Verify staging
git diff --staged --stat

# Commit with detected style
git commit -m "<message-matching-detected-style>"

# Verify
git log -1 --oneline
```

### 5.3 Commit Message Generation

**Based on detected style from Phase 1:**

```
IF style == SEMANTIC AND language == KOREAN:
  -> "feat: 로그인 기능 추가"

IF style == SEMANTIC AND language == ENGLISH:
  -> "feat: add login feature"

IF style == PLAIN AND language == ENGLISH:
  -> "Add login feature"

IF style == SHORT:
  -> "format" / "type fix" / "lint"
```

### 5.4 Co-Author Handling (CRITICAL RULE)

**NEVER add any agent (including Copilot) as a co-author automatically.**

```
RULE: Only add co-author(s) when the user explicitly requests it.

IF user explicitly requests a co-author:
  -> Add the trailer: Co-authored-by: [Name] <[email]>
  
ELSE:
  -> Do NOT add any co-author trailers
  -> Commits belong solely to the user/committer
```

---

## PHASE 6: Verification & Cleanup

### 6.1 Post-Commit Verification

```bash
# Check working directory clean
git status

# Review new history
git log --oneline $(git merge-base HEAD main 2>/dev/null || git merge-base HEAD master)..HEAD

# Verify each commit is atomic
# (mentally check: can each be reverted independently?)
```

### 6.2 Force Push Decision

```
IF fixup was used AND branch has upstream:
  -> Requires: git push --force-with-lease
  -> WARN user about force push implications

IF only new commits:
  -> Regular: git push
```

### 6.3 Final Report

```
COMMIT SUMMARY:
  Strategy: <what was done>
  Commits created: N
  Fixups merged: M

HISTORY:
  <hash1> <message1>
  <hash2> <message2>

NEXT STEPS:
  - git push [--force-with-lease]
  - Create PR if ready
```

---
---

# REBASE MODE (Phase R1-R4)

## PHASE R1: Rebase Context Analysis

### R1.1 Parallel Information Gathering

```bash
git branch --show-current
git log --oneline -20
git merge-base HEAD main 2>/dev/null || git merge-base HEAD master
git rev-parse --abbrev-ref @{upstream} 2>/dev/null || echo "NO_UPSTREAM"
git status --porcelain
git stash list
```

### R1.2 Safety Assessment

| Condition | Risk Level | Action |
|-----------|------------|--------|
| On main/master | CRITICAL | **ABORT** - never rebase main |
| Dirty working directory | WARNING | Stash first: `git stash push -m "pre-rebase"` |
| Pushed commits exist | WARNING | Will require force-push; confirm with user |
| All commits local | SAFE | Proceed freely |
| Upstream diverged | WARNING | May need `--onto` strategy |

### R1.3 Determine Rebase Strategy

```
USER REQUEST -> STRATEGY:

"squash commits" / "cleanup"
  -> INTERACTIVE_SQUASH

"rebase on main" / "update branch"
  -> REBASE_ONTO_BASE

"autosquash" / "apply fixups"
  -> AUTOSQUASH

"reorder commits"
  -> INTERACTIVE_REORDER

"split commit"
  -> INTERACTIVE_EDIT
```

---

## PHASE R2: Rebase Execution

### R2.1 Interactive Rebase (Squash/Reorder)

```bash
# Find merge-base
MERGE_BASE=$(git merge-base HEAD main 2>/dev/null || git merge-base HEAD master)

# For SQUASH (combine all into one):
git reset --soft $MERGE_BASE
git commit -m "Combined: <summarize all changes>"

# For SELECTIVE SQUASH (keep some, squash others):
# Use fixup approach - mark commits to squash, then autosquash
```

### R2.2 Autosquash Workflow

```bash
MERGE_BASE=$(git merge-base HEAD main 2>/dev/null || git merge-base HEAD master)
GIT_SEQUENCE_EDITOR=: git rebase -i --autosquash $MERGE_BASE
```

### R2.3 Rebase Onto (Branch Update)

```bash
# Simple rebase onto main:
git fetch origin
git rebase origin/main

# Complex: Move commits to different base
git rebase --onto origin/main $(git merge-base HEAD origin/main) HEAD
```

### R2.4 Handling Conflicts

```
CONFLICT DETECTED -> WORKFLOW:

1. Identify conflicting files:
   git status | grep "both modified"

2. For each conflict:
   - Read the file
   - Understand both versions (HEAD vs incoming)
   - Resolve by editing file
   - Remove conflict markers (<<<<, ====, >>>>)

3. Stage resolved files:
   git add <resolved-file>

4. Continue rebase:
   git rebase --continue

5. If stuck or confused:
   git rebase --abort  # Safe rollback
```

### R2.5 Recovery Procedures

| Situation | Command | Notes |
|-----------|---------|-------|
| Rebase going wrong | `git rebase --abort` | Returns to pre-rebase state |
| Need original commits | `git reflog` -> `git reset --hard <hash>` | Reflog keeps 90 days |
| Lost commits after rebase | `git fsck --lost-found` | Nuclear option |

---

## PHASE R3: Post-Rebase Verification

```bash
git status
git log --oneline $(git merge-base HEAD main 2>/dev/null || git merge-base HEAD master)..HEAD
git diff ORIG_HEAD..HEAD --stat
```

### Push Strategy

```
IF branch never pushed:
  -> git push -u origin <branch>

IF branch already pushed:
  -> git push --force-with-lease origin <branch>
  -> ALWAYS use --force-with-lease (not --force)
```

---

## PHASE R4: Rebase Report

```
REBASE SUMMARY:
  Strategy: <SQUASH | AUTOSQUASH | ONTO | REORDER>
  Commits before: N
  Commits after: M
  Conflicts resolved: K

HISTORY (after rebase):
  <hash1> <message1>
  <hash2> <message2>

NEXT STEPS:
  - git push --force-with-lease origin <branch>
  - Review changes before merge
```

---
---

# HISTORY SEARCH MODE (Phase H1-H3)

## PHASE H1: Determine Search Type

### H1.1 Parse User Request

| User Request | Search Type | Tool |
|--------------|-------------|------|
| "when was X added" | PICKAXE | `git log -S` |
| "find commits changing X pattern" | REGEX | `git log -G` |
| "who wrote this line" | BLAME | `git blame` |
| "when did bug start" | BISECT | `git bisect` |
| "history of file" | FILE_LOG | `git log -- path` |
| "find deleted code" | PICKAXE_ALL | `git log -S --all` |

### H1.2 Extract Search Parameters

```
From user request, identify:
- SEARCH_TERM: The string/pattern to find
- FILE_SCOPE: Specific file(s) or entire repo
- TIME_RANGE: All time or specific period
- BRANCH_SCOPE: Current branch or --all branches
```

---

## PHASE H2: Execute Search

### H2.1 Pickaxe Search (git log -S)

**Purpose**: Find commits that ADD or REMOVE a specific string

```bash
# Basic: Find when string was added/removed
git log -S "searchString" --oneline

# With context (see the actual changes):
git log -S "searchString" -p

# In specific file:
git log -S "searchString" -- path/to/file.py

# Across all branches (find deleted code):
git log -S "searchString" --all --oneline
```

### H2.2 Regex Search (git log -G)

**Purpose**: Find commits where diff MATCHES a regex pattern

```bash
# Find commits touching lines matching pattern
git log -G "pattern.*regex" --oneline

# Find function definition changes
git log -G "def\s+my_function" --oneline -p
```

**-S vs -G Difference:**
```
-S "foo": Finds commits where COUNT of "foo" changed
-G "foo": Finds commits where DIFF contains "foo"

Use -S for: "when was X added/removed"
Use -G for: "what commits touched lines containing X"
```

### H2.3 Git Blame

```bash
# Basic blame
git blame path/to/file.py

# Specific line range
git blame -L 10,20 path/to/file.py

# Show original commit (ignoring moves/copies)
git blame -C path/to/file.py

# Ignore whitespace changes
git blame -w path/to/file.py
```

### H2.4 Git Bisect (Binary Search for Bugs)

```bash
# Start bisect session
git bisect start

# Mark current (bad) state
git bisect bad

# Mark known good commit
git bisect good v1.0.0

# Git checkouts middle commit. Test it, then:
git bisect good  # if this commit is OK
git bisect bad   # if this commit has the bug

# When done, return to original state
git bisect reset
```

**Automated Bisect (with test script):**
```bash
git bisect start
git bisect bad HEAD
git bisect good v1.0.0
git bisect run pytest tests/test_specific.py
```

### H2.5 File History Tracking

```bash
# Full history of a file
git log --oneline -- path/to/file.py

# Follow file across renames
git log --follow --oneline -- path/to/file.py

# Show actual changes
git log -p -- path/to/file.py

# Files that no longer exist
git log --all --full-history -- "**/deleted_file.py"

# Who changed file most
git shortlog -sn -- path/to/file.py
```

---

## PHASE H3: Present Results

### H3.1 Format Search Results

```
SEARCH QUERY: "<what user asked>"
SEARCH TYPE: <PICKAXE | REGEX | BLAME | BISECT | FILE_LOG>
COMMAND USED: git log -S "..." ...

RESULTS:
  Commit       Date           Message
  ---------    ----------     --------------------------------
  abc1234      2024-06-15     feat: add discount calculation
  def5678      2024-05-20     refactor: extract pricing logic

MOST RELEVANT COMMIT: abc1234
```

### H3.2 Provide Actionable Context

```
POTENTIAL ACTIONS:
- View full commit: git show abc1234
- Revert this commit: git revert abc1234
- See related commits: git log --ancestry-path abc1234..HEAD
- Cherry-pick to another branch: git cherry-pick abc1234
```

---

## Quick Reference: History Search Commands

| Goal | Command |
|------|---------|
| When was "X" added? | `git log -S "X" --oneline` |
| When was "X" removed? | `git log -S "X" --all --oneline` |
| What commits touched "X"? | `git log -G "X" --oneline` |
| Who wrote line N? | `git blame -L N,N file.py` |
| When did bug start? | `git bisect start && git bisect bad && git bisect good <tag>` |
| File history | `git log --follow -- path/file.py` |
| Find deleted file | `git log --all --full-history -- "**/filename"` |

---

## Anti-Patterns (ALL MODES)

### Commit Mode
- Splitting by file count instead of logical concern -> Wrong history
- Combining independently reversible concerns -> SPLIT
- Default to semantic style -> DETECT first

### Rebase Mode
- Rebase main/master -> NEVER
- `--force` instead of `--force-with-lease` -> DANGEROUS
- Rebase without stashing dirty files -> WILL FAIL

### History Search Mode
- `-S` when `-G` is appropriate -> Wrong results
- Blame without `-C` on moved code -> Wrong attribution
- Bisect without proper good/bad boundaries -> Wasted time
