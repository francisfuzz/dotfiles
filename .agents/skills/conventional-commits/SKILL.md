---
name: conventional-commits
description: Generate properly formatted Conventional Commits messages with Claude Code footer. Use when creating git commits, writing commit messages, or the user mentions "commit", "git commit", or wants to save changes.
allowed-tools: Bash, Read, Grep
---

# Conventional Commits

## Format

```
<type>[optional scope][optional !]: <description>

[optional body]

[required footer]
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

- Imperative mood: "add" not "added"
- Summary under 50 characters
- Breaking changes: `!` after type/scope or `BREAKING CHANGE:` footer
- Body explains **what** and **why**, not **how**
- Reference issue numbers in body if applicable

## Required Footer

Always include:
```
🤖 Generated with [Claude Code](https://claude.com/claude-code)
```

## Workflow

1. Run `git diff --staged` (or `git diff`) to understand changes
2. Choose type, optional scope, write concise description
3. Use heredoc for multi-line commits:

```bash
git commit -m "$(cat <<'EOF'
type(scope): description

Body explaining what and why.

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

## Do Not

- Forget the Claude Code footer
- Use past tense ("added", "fixed")
- Write vague descriptions ("update stuff", "fix bug")
- Skip body when breaking changes need explanation
