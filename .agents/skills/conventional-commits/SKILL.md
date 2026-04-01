---
name: conventional-commits
description: Generate properly formatted Conventional Commits messages. Use when creating git commits, writing commit messages, or the user mentions "commit", "git commit", or wants to save changes.
argument-hint: [issue-url | issue-id]
allowed-tools: Bash, Read, Grep
---

# Conventional Commits

## Context

- Current status: !`git status`
- Current diff: !`git diff HEAD`
- Current branch: !`git branch --show-current`

## Critical Rules

- **Always ensure you're on a feature branch** — never commit directly to main
- **Always sign-off commits** with git config user.name and user.email
- **Always run tests and lint** before creating a commit
- **NEVER git commit or git push without explicit user approval** — always ask first
- **Only add co-authors when the user explicitly specifies them**

## Format

```
<type>[optional scope][optional !]: <description>

[optional body with What, Why, Notes]

[optional Relates to <issue>]
Signed-off-by: <user.name> <user.email>
```

## Types

- **feat**: New feature
- **fix**: Bug fix
- **docs**: Documentation only
- **build**: Build system or dependencies
- **test**: Adding or updating tests
- **refactor**: Neither fix nor feature
- **perf**: Performance improvement
- **chore**: Maintenance tasks

## Rules

- Imperative mood: "add" not "added", "fix" not "fixed"
- Summary under 50 characters
- Breaking changes: use `!` after type/scope or `BREAKING CHANGE:` footer
- Reference issue numbers if applicable

## Body Structure

Use three headings when the commit warrants a body:

### What
Prose explanation of what changed. No bullet points.

### Why
Prose explanation of the motivation and who is affected. No bullet points.

### Notes
- Non-obvious implications, risks, and trade-offs
- Things reviewers should watch for that aren't apparent from the diff
- Avoid stating obvious facts or repeating What/Why

## Workflow

1. Run `git diff --staged` (or `git diff`) to understand changes
2. Run tests and linting to confirm nothing is broken
3. Choose type, optional scope, and write a concise description
4. If `$ARGUMENTS` is provided, add `Relates to $ARGUMENTS` after the commit title
5. Use heredoc for multi-line commits:

```bash
git commit --signoff -m "$(cat <<'EOF'
type(scope): description

## What

Explanation of what changed.

## Why

Explanation of motivation and who is affected.

## Notes

- Non-obvious detail for reviewers

Relates to <issue-url>
EOF
)"
```

## DO NOT

- Add co-authors unless the user explicitly requests it
- Use past tense descriptions ("added", "fixed")
- Write vague descriptions ("update stuff", "fix bug")
- Skip body when breaking changes need explanation
- Commit directly to main branch
- Commit or push without user approval
