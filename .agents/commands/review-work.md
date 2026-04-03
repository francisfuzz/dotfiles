---
description: "Post-implementation review orchestrator. Launches 5 parallel review agents covering goal verification, QA, code quality, security, and context mining."
---

# Review Work — 5-Agent Parallel Review Orchestrator

Review request: $ARGUMENTS

Launch 5 specialized sub-agents in parallel to review completed implementation work from every angle. All 5 must pass for the review to pass. If even ONE fails, the review fails.

The 5 agents cover complementary concerns — together they form a comprehensive review that no single reviewer could match:

| # | Agent | Type | Role | Focus Level |
|---|-------|------|------|-------------|
| 1 | Goal Verifier | Oracle | Did we build what was asked? | MAIN |
| 2 | QA Executor | General-Purpose | Does it actually work? | MAIN |
| 3 | Code Reviewer | Oracle | Is the code well-written? | MAIN |
| 4 | Security Auditor | Oracle | Is it secure? | SUB |
| 5 | Context Miner | General-Purpose | Did we miss any context? | MAIN |

---

## Phase 0: Gather Review Context

Before launching agents, collect these inputs. Extract from conversation history first — the user's original request, constraints discussed, and decisions made are usually already in the thread. Only ask if truly missing.

**Required inputs:**

- **GOAL**: The original objective. What was the user trying to achieve? Pull from the initial request in this conversation.
- **CONSTRAINTS**: Rules, requirements, or limitations. Tech stack restrictions, performance targets, API contracts, design patterns to follow, backward compatibility needs.
- **BACKGROUND**: Why this work was needed. Business context, user stories, related systems, prior decisions that informed the approach.
- **CHANGED_FILES**: Auto-collect via `git diff --name-only HEAD~1` or against the appropriate base (branch point, specific commit).
- **DIFF**: Auto-collect via `git diff HEAD~1` or against the appropriate base.
- **FILE_CONTENTS**: Read the full content of each changed file (not just the diff). Oracle agents cannot read files — they need full context in the prompt.
- **RUN_COMMAND**: How to start/run the application. Check `package.json` scripts, `Makefile`, `docker-compose.yml`, or ask the user.

**Auto-collection sequence:**

```bash
# 1. Get changed files
git diff --name-only HEAD~1  # or: git diff --name-only main...HEAD

# 2. Get diff
git diff HEAD~1  # or: git diff main...HEAD

# 3. Detect run command
# Check package.json -> "scripts.dev" or "scripts.start"
# Check Makefile -> default target
# Check docker-compose.yml -> services
```

For GOAL, CONSTRAINTS, BACKGROUND — review the full conversation history. The user's original message almost always contains the goal. If anything critical is ambiguous, ask ONE focused question.

---

## Phase 1: Launch 5 Agents

Launch ALL 5 in a single turn. Every agent runs in background. No sequential launches. No waiting between them.

**Oracle agents receive everything in the prompt** (they cannot read files or run commands). Include DIFF + FILE_CONTENTS + all context directly in the prompt text.

**General-purpose agents are autonomous** — they can read files, run commands, and use tools. Give them goals and pointers, not raw content dumps.

---

### Agent 1: Goal & Constraint Verification (Oracle)

This agent answers: "Did we build exactly what was asked, within the rules we were given?"

Launch as Oracle agent with this prompt:

```
REVIEW TYPE: GOAL & CONSTRAINT VERIFICATION

ORIGINAL GOAL:
{GOAL — paste the user's original request and any clarifications}

CONSTRAINTS:
{CONSTRAINTS — every rule, requirement, or limitation discussed}

BACKGROUND:
{BACKGROUND — why this work was needed, broader context}

CHANGED FILES:
{CHANGED_FILES — list of modified file paths}

FILE CONTENTS:
{FILE_CONTENTS — full content of every changed file, clearly delimited per file}

DIFF:
{DIFF — the actual git diff}

Review whether this implementation correctly and completely achieves the stated goal within the given constraints.

REVIEW CHECKLIST:

1. **Goal Completeness**: Break the goal into every sub-requirement (explicit AND implied). For each, mark ACHIEVED / MISSED / PARTIAL.

2. **Constraint Compliance**: List every constraint. For each, verify compliance with specific code evidence. A constraint violated = automatic FAIL.

3. **Requirement Gaps**: Requirements the user clearly wanted but didn't spell out.

4. **Over-Engineering**: Anything added that wasn't requested — unnecessary abstractions, extra features, premature optimizations. Flag as scope creep.

5. **Edge Cases**: Given the goal, what inputs or scenarios would break this? Trace through at least 5 edge cases.

6. **Behavioral Correctness**: Walk through the code logic for 3+ representative scenarios.

OUTPUT FORMAT:
<verdict>PASS or FAIL</verdict>
<confidence>HIGH / MEDIUM / LOW</confidence>
<summary>1-3 sentence overall assessment</summary>
<goal_breakdown>
  For each sub-requirement:
  - [ACHIEVED/MISSED/PARTIAL] Requirement description
  - Evidence: specific code reference or gap
</goal_breakdown>
<constraint_compliance>
  For each constraint:
  - [ACHIEVED/MISSED] Constraint description — evidence
</constraint_compliance>
<blocking_issues>Issues that MUST be fixed. Empty if PASS.</blocking_issues>
```

---

### Agent 2: QA via App Execution (General-Purpose)

This agent answers: "Does it actually work when you run it?"

Launch as a general-purpose agent with this prompt:

```
REVIEW TYPE: QA — HANDS-ON APP EXECUTION

ORIGINAL GOAL:
{GOAL}

CONSTRAINTS:
{CONSTRAINTS}

CHANGED FILES:
{CHANGED_FILES}

RUN COMMAND:
{RUN_COMMAND — how to start the application, or "unknown" if not determined}

You are a QA engineer. Your job is to RUN the application and verify it works through hands-on testing. You do not review code — you test behavior.

MANDATORY PROCESS:

### Step 1: Scenario Brainstorm
Before touching the app, write down EVERY test scenario. Think about:
- Happy paths: primary use cases
- Boundary conditions: empty inputs, max-length, zero values, special characters
- Error paths: invalid inputs, missing files, permission denied
- Regression scenarios: existing features touching same code paths
- State transitions: things out of order, rapid repeated actions

Aim for 15-30 scenarios minimum. Group by priority: P0 (must pass), P1 (should pass), P2 (nice to pass).

### Step 2: Scenario Augmentation
Review your list. For each scenario ask:
- "What could go wrong that I haven't considered?"
- "What would a malicious or careless user do?"
Add at least 5 more scenarios.

### Step 3: Execute Systematically
Work through scenarios in priority order (P0 first). For each test:
1. Execute the test steps
2. Record actual result
3. Compare with expected result
4. Mark PASS or FAIL
5. If FAIL: capture evidence (terminal output, error message)

### Step 4: Compile Results

OUTPUT FORMAT:
<verdict>PASS or FAIL</verdict>
<confidence>HIGH / MEDIUM / LOW</confidence>
<summary>1-3 sentence overall assessment</summary>
<scenario_coverage>
  Total scenarios: N
  P0: X tested, Y passed
  P1: X tested, Y passed
  P2: X tested, Y passed
</scenario_coverage>
<blocking_issues>P0 or P1 failures only. Empty if PASS.</blocking_issues>
```

---

### Agent 3: Code Quality Review (Oracle)

This agent answers: "Is the code well-written, maintainable, and consistent with the codebase?"

Launch as Oracle agent with this prompt:

```
REVIEW TYPE: CODE QUALITY REVIEW

CHANGED FILES:
{CHANGED_FILES}

FILE CONTENTS:
{FILE_CONTENTS — full content of changed files AND neighboring files that show existing patterns}

DIFF:
{DIFF}

BACKGROUND:
{BACKGROUND}

You are a senior staff engineer conducting a code review. Your standard: "Would I approve this PR without comments?"

REVIEW DIMENSIONS:

1. **Correctness**: Logic errors, off-by-one, null/undefined handling, race conditions, resource leaks
2. **Pattern Consistency**: Does new code follow codebase's established patterns?
3. **Naming & Readability**: Clear names? Self-documenting code?
4. **Error Handling**: Properly caught, logged, propagated? No empty catch blocks?
5. **Type Safety**: Any `as any`, `@ts-ignore`? Proper generics?
6. **Performance**: N+1 queries? Unnecessary re-renders? Memory leaks?
7. **Abstraction Level**: Right level? No copy-paste duplication? No premature over-abstraction?
8. **Testing**: New behaviors covered? Tests meaningful?
9. **API Design**: Public interfaces clean and consistent?
10. **Tech Debt**: Does this introduce new debt?

Severity categories:
- **CRITICAL**: Will cause bugs, data loss, or crashes in production
- **MAJOR**: Should be fixed before merge
- **MINOR**: Worth making but not blocking
- **NITPICK**: Style preference, optional

OUTPUT FORMAT:
<verdict>PASS or FAIL</verdict>
<confidence>HIGH / MEDIUM / LOW</confidence>
<summary>1-3 sentence overall assessment</summary>
<findings>
  - [CRITICAL/MAJOR/MINOR/NITPICK] Category: Description
  - File: path (line range)
  - Current: what the code does now
  - Suggestion: how to improve
</findings>
<blocking_issues>CRITICAL and MAJOR items only. Empty if PASS.</blocking_issues>
```

---

### Agent 4: Security Review (Oracle)

This agent answers: "Are there security vulnerabilities in these changes?"

Launch as Oracle agent with this prompt:

```
REVIEW TYPE: SECURITY REVIEW (supplementary)

CHANGED FILES:
{CHANGED_FILES}

FILE CONTENTS:
{FILE_CONTENTS — full content of changed files}

DIFF:
{DIFF}

You are a security engineer. Review this diff exclusively for security vulnerabilities and anti-patterns. Ignore code style, naming, architecture — unless it directly creates a security risk.

SECURITY CHECKLIST:

1. **Input Validation**: User inputs sanitized? SQL injection, XSS, command injection, SSRF vectors?
2. **Auth & AuthZ**: Authentication checks where needed? Authorization verified for each action?
3. **Secrets & Credentials**: Hardcoded secrets, API keys, tokens in code or config?
4. **Data Exposure**: Sensitive data in logs? PII in error messages?
5. **Dependencies**: New dependencies added? Known CVEs?
6. **Cryptography**: Proper algorithms? No custom crypto?
7. **File & Path**: Path traversal? Unsafe file operations?
8. **Network**: CORS configured correctly? Rate limiting? TLS enforced?
9. **Error Leakage**: Stack traces exposed to users?
10. **Supply Chain**: Lockfile updated consistently?

OUTPUT FORMAT:
<verdict>PASS or FAIL</verdict>
<severity>CRITICAL / HIGH / MEDIUM / LOW / NONE</severity>
<summary>1-3 sentence overall assessment</summary>
<findings>
  - [CRITICAL/HIGH/MEDIUM/LOW] Category: Description
  - File: path (line range)
  - Risk: What could an attacker do?
  - Remediation: Specific fix
</findings>
<blocking_issues>CRITICAL and HIGH items only. Empty if PASS.</blocking_issues>
```

---

### Agent 5: Context Mining (General-Purpose)

This agent answers: "Did we miss any context that should have informed this implementation?"

Launch as a general-purpose agent with this prompt:

```
REVIEW TYPE: CONTEXT MINING — MISSED REQUIREMENTS & BACKGROUND

ORIGINAL GOAL:
{GOAL}

CONSTRAINTS:
{CONSTRAINTS}

CHANGED FILES:
{CHANGED_FILES}

BACKGROUND:
{BACKGROUND}

You are an investigator. Your mission: search every accessible information source to find context that should have informed this implementation but might have been missed.

SOURCES TO SEARCH:

1. **Git History** (ALWAYS search):
   - `git log --oneline -20 -- {each changed file}` — recent changes
   - `git blame {critical sections}` — who wrote what and when
   - `git log --all --grep="{keywords from goal}"` — related commits
   - Look for reverted commits, TODO/FIXME/HACK comments

2. **GitHub** (if `gh` CLI available):
   - `gh issue list --search "{keywords}"` — related open/closed issues
   - `gh pr list --search "{keywords}" --state all` — related PRs
   - Look at review comments on past PRs touching these files

3. **Codebase Cross-References** (ALWAYS search):
   - Files that import or reference the changed modules
   - Tests that might need updating due to behavior changes
   - Documentation referencing changed behavior
   - Config files that might need corresponding updates
   - Related features in the same domain

WHAT TO LOOK FOR:
- Requirements mentioned in issues/PRs that the implementation misses
- Past decisions explaining WHY code was written a certain way
- Related systems affected by these changes
- Warnings from previous developers (PR comments, TODOs, commit messages)
- Design decisions documented outside the codebase

OUTPUT FORMAT:
<verdict>PASS or FAIL</verdict>
<confidence>HIGH / MEDIUM / LOW</confidence>
<summary>1-3 sentence overall assessment</summary>
<sources_searched>
  - [SEARCHED/SKIPPED] Source name — what was searched
</sources_searched>
<discovered_context>
  For each discovery:
  - Source: Where found
  - Finding: What was found
  - Relevance: How it relates to the current work
  - Impact: [BLOCKING / IMPORTANT / FYI]
</discovered_context>
<missed_requirements>Requirements the implementation should address but doesn't.</missed_requirements>
<blocking_issues>BLOCKING items only. Empty if PASS.</blocking_issues>
```

---

## Phase 2: Wait & Collect

After launching all 5 agents in one turn, **end your response**. Wait for system notifications as each agent completes.

Collect each verdict:

| Agent | Verdict | Notes |
|-------|---------|-------|
| 1. Goal Verification | pending | — |
| 2. QA Execution | pending | — |
| 3. Code Quality | pending | — |
| 4. Security | pending | — |
| 5. Context Mining | pending | — |

Do NOT deliver the final report until ALL 5 have completed.

---

## Phase 3: Deliver Verdict

ALL 5 agents returned PASS → **REVIEW PASSED**
ANY agent returned FAIL → **REVIEW FAILED — criteria not met**

Compile the final report:

```markdown
# Review Work — Final Report

## Overall Verdict: PASSED / FAILED

| # | Review Area | Agent Type | Verdict | Confidence |
|---|------------|------------|---------|------------|
| 1 | Goal & Constraint Verification | Oracle | PASS/FAIL | HIGH/MED/LOW |
| 2 | QA Execution | General-Purpose | PASS/FAIL | HIGH/MED/LOW |
| 3 | Code Quality | Oracle | PASS/FAIL | HIGH/MED/LOW |
| 4 | Security (supplementary) | Oracle | PASS/FAIL | Severity |
| 5 | Context Mining | General-Purpose | PASS/FAIL | HIGH/MED/LOW |

## Blocking Issues
[Aggregated from all agents — deduplicated, prioritized]

## Key Findings
[Top 5-10 most important findings across all agents, grouped by theme]

## Recommendations
[If FAILED: exactly what to fix, in priority order]
[If PASSED: non-blocking suggestions worth considering]
```

If FAILED — be specific. The user should know exactly what to fix and in what order. No vague "consider improving X" — state the problem, the file, and the fix.

If PASSED — keep it short. Highlight any non-blocking suggestions, but don't turn a passing review into a lecture.
