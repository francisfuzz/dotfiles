---
name: pr-review-assist
description: Prepare structured PR reviews using a three-phase framework (Context, Analysis, Validation). Use when reviewing pull requests, when user shares a PR URL, or mentions "review PR", "code review", or "check this PR".
allowed-tools: Bash(gh: *) Read
---

# PR Review Assist

Treat every PR as the beginning of a conversation, not a bug hunt.

## Prerequisites

- `gh` CLI authenticated
- PR URL or repo/number (e.g., `owner/repo#123`)

## For PR Authors

Self-review first, leave explanatory comments on non-obvious changes, split large PRs, move to draft when addressing feedback.

## Phase 1: Context Before Code

Establish strategic foundation *before* looking at diffs.

```bash
gh pr view <number> --json title,body,author,files,additions,deletions,baseRefName,headRefName,labels
```

- **Business**: Who initiated this and why now? What problem does it solve? Impact on users/systems?
- **Technical**: Blast radius if this fails? Dependencies or sequencing needs? Cross-team coordination?

## Phase 2: Systematic Analysis

**Scope**: Is the PR appropriately sized? Are changes cohesive? Do file changes align with stated intent?

**Quality check across**:
- Intent — does code match PR description?
- Correctness — edge cases, null handling, logic errors?
- Security — input validation, auth, data exposure?
- Performance — N+1 queries, loops, memory?
- Accessibility — keyboard, alt text, ARIA?
- Testing — coverage gaps?
- Patterns — follows repo conventions?

See [review-checklist.md](references/review-checklist.md) for detailed verification steps.

## Phase 3: Validation

**Mindset**: Trust your team. Preferences (💅) don't block; only true blockers (🟡) that would break prod or harm users.

**Actions**: Approve (ships safely) · Request Changes 🟡 (blockers only) · Comment 🙋 (need answers first)

**After**: Respond to replies, react with emoji, link back in follow-ups.

## Output

```markdown
## PR Review: <title>

**PR**: <url> | **Author**: @<author> | **Files**: <count>

### Context
[Why now, impact, blast radius]

### Analysis
[Approach assessment, observations with file:line refs]

### Recommendation
[Approve/Request Changes/Comment] — [rationale]
```
