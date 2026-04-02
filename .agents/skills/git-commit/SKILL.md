---
name: git-commit
description: Generate Conventional Commits-formatted git commit messages from staged changes. Use when the user asks to commit, writes a commit message, or runs git commit.
argument-hint: [issue-url | issue-id]
allowed-tools: Bash, Read, Grep
---

# Git Commit

## Context

- Current status: !`git status`
- Staged diff: !`git diff --staged`
- Current branch: !`git branch --show-current`

## Rules

Safety rules come first, then formatting rules.

### Safety

- **Always ensure you're on a feature branch** — never commit directly to main
- **Always sign-off commits** with git config user.name and user.email
- **Always run tests and lint** before creating a commit — if no test/lint command is known, ask the user
- **NEVER git commit or git push without explicit user approval** — always ask first
- **Only add co-authors when the user explicitly specifies them**

### Formatting

- Imperative mood: "add" not "added", "fix" not "fixed"
- Summary under 50 characters
- Breaking changes: use `!` after type/scope or `BREAKING CHANGE:` footer
- Reference issue numbers if applicable

## Format

```
<type>[optional scope][optional !]: <description>

[optional body with What, Why, Notes]

[optional Relates to <issue>]
(--signoff flag adds Signed-off-by automatically)
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
4. If `$ARGUMENTS` is provided, add `Relates to $ARGUMENTS` after the body — if a bare number, format as `#<number>`; if a URL, use as-is
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

For worked examples, see `references/examples.md`.

## DO NOT

- Add co-authors unless the user explicitly requests it
- Use past tense descriptions ("added", "fixed")
- Write vague descriptions ("update stuff", "fix bug")
- Skip body when breaking changes need explanation
- Commit directly to main branch
- Commit or push without user approval

## Related Skills

- **pr-review-assist** — use after committing to review the PR
