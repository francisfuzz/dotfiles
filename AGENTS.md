# Dotfiles Agent Guide

This repository stores personal dotfiles and reusable AI-agent configuration for GitHub Copilot CLI and Claude Code.

## Repository architecture

Active configuration has one canonical source:

```text
.agents/
├── copilot-instructions.md  # Personal Copilot CLI operating principles
├── agents/                  # Specialist agent definitions
└── skills/                  # Reusable task workflows
```

Compatibility paths expose that configuration to tools without duplicating it:

- `CLAUDE.md` -> `AGENTS.md`
- `.claude/agents` -> `../.agents/agents`
- `.claude/skills` -> `../.agents/skills`
- `.github/skills` -> `../.agents/skills`
- `.claude/commands` -> `../archive/commands`
- `.github/prompts` -> `../archive/prompts`

`install.sh` also links:

- `~/.agents` -> this repository's `.agents`
- `~/.copilot/copilot-instructions.md` -> `.agents/copilot-instructions.md`
- `~/.copilot/agents` -> `.agents/agents`
- selected Claude Code paths without replacing `~/.claude`

Always edit the canonical file under `.agents/`; never duplicate an active skill or agent under a compatibility path.

## Active agents

| Agent | Responsibility |
|---|---|
| `explore` | Repository discovery and code search |
| `librarian` | External documentation and implementation research |
| `oracle` | Architecture, debugging, and strategic consultation |
| `forge` | Bounded implementation from an explicit Forge Spec |

Agents are optional specialists. Delegate only when specialization, independent parallel work, or context isolation materially improves the result.

## Active skills

| Skill | Responsibility |
|---|---|
| `commit` | Draft a focused Conventional Commit message |
| `git-ops` | Commit planning, rebases, and history investigation |
| `interview` | Turn ambiguous ideas into a concrete specification |
| `review` | Verification-first pull request review |
| `review-work` | Comprehensive post-implementation review |
| `transcript-to-artifact` | Convert transcripts into structured artifacts |

Each skill lives in `.agents/skills/<name>/SKILL.md`. Supporting documentation belongs in `references/`, reusable files in `assets/`, and executable helpers in `scripts/`.

## Archived configuration

Retired commands, prompts, skills, and agents belong under `archive/`. Preserve history with `git mv` when retiring active configuration.

Archived content is reference material and should not be edited as though it were active. Compatibility symlinks to archived commands or prompts exist only for legacy workflows.

## Making changes

1. Check `.agents/` for an existing agent or skill before adding another.
2. Keep persistent instructions broadly applicable; put conditional procedures in skills.
3. Give agents one narrow responsibility and the minimum tools required.
4. Avoid duplicating policy across instructions, skills, and agents.
5. Update `README.md` and `LICENSE.md` when active paths or derived files change.
6. Preserve unrelated local runtime data and untracked files.

## Validation

For configuration changes, run the smallest relevant checks:

```bash
bash -n install.sh
ls -la .claude .github
git ls-files -s CLAUDE.md .claude .github
```

When changing installation behavior, run `install.sh` with a temporary `HOME` and verify the resulting symlink targets. When adding or changing skills, use `/skills reload` and `/skills info <name>` in a new or reloaded Copilot CLI session when available.

## Git conventions

- Follow the repository's existing Conventional Commit style.
- Build commits around logical cohesion and independent reversibility.
- Pair implementation with its direct tests when separating them would leave a broken commit.
- Use `--force-with-lease`, never `--force`, when rewriting a published branch.
- Do not commit or push unless the user explicitly requests it.
- Include documentation updates in the same commit as the configuration change they describe.

## Security

Local `.claude/` runtime data and `.env` files may contain sensitive information. They are not part of the canonical configuration and must not be committed or shared.
