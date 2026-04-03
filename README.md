# dotfiles

[@francisfuzz](https://francisfuzz.com/)'s dotfiles

## Directory Structure

This repository uses a consolidated configuration approach with `.agents/` as the single source of truth, accessible to both Claude Code and GitHub Copilot CLI via symlinks.

### `.agents/` – Canonical Configuration

- **agents/** – Subagent definitions for delegation (explore, librarian, metis, momus, oracle)
- **skills/** – Reusable skills invoked via `/skill-name`:
  - `git-commit` – Conventional Commits-formatted commit messages
  - `git-ops` – Atomic commits, interactive rebase, history search
  - `interview` – Discovery interviews with Socratic questioning
  - `pr-review-assist` – Structured PR review
  - `review-work` – Post-implementation review with parallel agents
  - `transcript-to-artifact` – Meeting transcripts → structured artifacts

### `archive/` – Archived Configuration

Previously active configuration that has been retired:
- **commands/** – Legacy Claude command templates
- **prompts/** – Legacy prompt templates

### Symlinks

| Symlink | Target | Purpose |
|---------|--------|---------|
| `CLAUDE.md` | `AGENTS.md` | Both tools read the same agent config |
| `.claude/agents` | `.agents/agents` | Claude Code subagent discovery |
| `.claude/commands` | `archive/commands` | Legacy command compatibility |
| `.claude/skills` | `.agents/skills` | Claude Code skill discovery |
| `.github/prompts` | `archive/prompts` | Legacy prompt compatibility |
| `.github/skills` | `.agents/skills` | Copilot CLI skill discovery |

## License

[GNU General Public License v3.0](./LICENSE)

## Credits

- Interview Skill Inspiration: [`@developersdigest`](https://github.com/developersdigest) ["Claude Code 'Interview' Mode in 6 Minutes"](https://www.youtube.com/watch?v=vgHBEju4kGE)
- Agent & Command Patterns: [`francisfuzz/learning-opencode`](https://github.com/francisfuzz/learning-opencode)
