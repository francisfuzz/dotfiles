---
name: start-work
description: Start new work on an issue with discovery, worktree/branch setup, TDD workflow, and draft PR creation. Use when beginning work on a GitHub issue.
---

# Start Work

Complete workflow from issue discovery to draft PR.

## Step 0: Discovery

Before creating branches, gather context:

1. **Fetch Issue Details** — Get title, description, labels, acceptance criteria, linked issues/PRs
2. **Codebase Analysis** — Find relevant files, existing tests, recent commits in affected areas
3. **Pattern Recognition** — Check repo history for similar issues, architectural patterns, conventions
4. **Scope Confirmation** — Summarize understanding, ask user to confirm, flag ambiguities

## Step 1: Setup

1. **Create Worktree or Branch** (ask user preference)
   - Naming: `francisfuzz/{issue-number}-short-description` (kebab-case, 2-4 words)
   - Worktree path: `../worktrees/{branch-name}/`
2. **Verify** clean working directory, confirm branch/path

## Step 2: TDD Implementation

1. **Write Failing Tests** — Create/update tests from requirements, confirm they fail, lint, commit: `test: add tests for [feature]`
2. **Implement** — Minimal code to pass tests, run tests frequently, lint, commit: `feat: implement [feature]`
3. **Refactor** — Clean up, ensure tests still pass, lint, commit: `refactor: [improvement]`
4. **Checkpoint** — Atomic semantic commits at each meaningful step; always lint before committing

Use conventional commit types: `test:`, `feat:`, `fix:`, `refactor:`, `docs:`, `chore:`

## Step 3: Completion

1. Run full test suite + final lint pass
2. Fix any remaining issues, commit: `chore: fix linting issues`
3. Push branch to origin

## Step 4: Draft Pull Request

1. **Title**: Issue title or clear summary
2. **Body**: `Closes #{issue-number}`, brief summary, testing notes, breaking changes
3. **Create as draft**, share PR URL
4. **Handoff**: Confirm PR linked to issue, ask if user wants to continue, mark ready, or revise
