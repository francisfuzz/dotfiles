# Copilot Instructions for Dotfiles Repository

This repository contains personal dotfiles and reusable AI agent skills/commands for GitHub Copilot CLI and Claude workflows. Future Copilot sessions should understand this architecture and conventions.

## Repository Purpose

A **dotfiles configuration repository** with a focus on storing reusable AI agent automation skills and maintaining backward compatibility with various tool expectations. The primary content is in `.agents/skills/` — a canonical, single-source-of-truth location for active skill definitions.

## High-Level Architecture

### Single Source of Truth: `.agents/`
All active skill configurations are defined once in `.agents/skills/`. This prevents duplication and makes maintenance straightforward.

```
.agents/skills/          ← Canonical location (git-tracked)
├── git-ops/                # Expert git operations: commits, rebase, history search
├── interview/              # Conduct discovery interviews with Socratic questioning
├── review-work/            # Post-implementation review with parallel agents
├── transcript-to-artifact/ # Transform transcripts into structured artifacts
└── ...                     # Other active skills
```

### Backward Compatibility: Symlinks
Tools expect configurations in `.claude/` and `.github/`. Symlinks maintain compatibility:
- `.claude/skills` → `../.agents/skills`
- `.github/skills` → `../.agents/skills`
- `.github/prompts` → `../archive/prompts`
- `.claude/commands` → `../archive/commands`

When tools resolve these paths, they transparently access the canonical source.

### Archived Content: `archive/`
Previously active configurations have been moved to `archive/` for reference:
- `archive/commands/` — Retired Claude commands
- `archive/prompts/` — Retired prompt templates
- `archive/skills/` — Archived skill definitions (git-commit, pr-review-assist, etc.)

### Local Runtime Data: `.claude/` (not tracked)
Files like `cache/`, `history.jsonl`, `settings.json`, and plugin data are git-ignored. These are session-specific and should not be committed.

## Skill Structure

Each skill directory follows this pattern:
```
skill-name/
├── SKILL.md          # Metadata and instructions (REQUIRED)
├── references/       # Supporting docs (optional)
├── examples/         # Example outputs (optional)
└── other files/      # Task-specific assets
```

The `SKILL.md` file contains:
- YAML metadata (name, description)
- Clear instructions for the AI agent
- Context about when/how to use the skill

## Key Development Conventions

### Git & Version Control
- Use the `git-ops` skill for commits, rebases, and history search
- Detect commit style from the repo's existing `git log` before writing messages
- Default to multiple atomic commits — split by directory, concern, and component type
- Pair implementation files with their tests in the same commit
- Include the trailer: `Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>`
- Preserve git history through careful file moves using `git mv`
- Always use `--force-with-lease` (never `--force`) when force-pushing
- Always test changes before committing

### Symlink Handling
This repository uses symlinks for backward compatibility. Git correctly handles symlinks on macOS and Linux:
- To verify symlinks resolve: `ls -la .claude/ .github/`
- To verify git tracks them: `git ls-files -s .claude/ .github/`
- When modifying skills, always edit files in `.agents/skills/` — symlinks automatically reflect changes

### Single-Edit Principle
When updating a skill:
1. Edit the file **once** in `.agents/skills/[skill-name]/`
2. Symlinks in `.claude/` and `.github/` automatically reflect the change
3. Commit the change at the `.agents/` location
4. No need to make edits in multiple locations

### Testing & Validation
Before committing configuration changes:
- Verify symlinks resolve correctly with: `ls -la .claude/ .github/`
- If adding a new skill, verify it's properly structured:
  - Directory exists: `.agents/skills/[skill-name]/`
  - Required file exists: `.agents/skills/[skill-name]/SKILL.md`
  - SKILL.md has YAML metadata and clear instructions
- Test the skill in Copilot CLI if possible: `/skills list`

## File Organization Rules

### What Goes Where

- **`.agents/skills/[name]/SKILL.md`** — Active skill definitions (canonical source)
- **`.agents/skills/[name]/references/`** — Supporting docs for a skill
- **`archive/`** — Retired configurations (for reference only, don't edit)
- **`gitconfig`** — Git configuration applied via `install.sh`
- **`install.sh`** — Installation script for Codespaces and local setup
- **`.claude/`, `.github/`** — Symlinks only (don't add files here directly)

### GitIgnore Pattern
Local runtime data (cache, history, plugins, settings) in `.claude/` is git-ignored and should never be committed. These are session-specific artifacts.

## Installation and Setup

### Running install.sh
The `install.sh` script sets up this dotfiles repository in a new environment (local machine or GitHub Codespace):

```bash
bash install.sh
```

**What it does:**
1. Installs git configuration from `gitconfig`
2. Creates a symlink: `~/.agents` → `[dotfiles]/.agents` (for Copilot CLI and agent discovery)

**Codespaces Integration:**
Set this repository as your [Codespaces dotfiles](https://docs.github.com/en/codespaces/setting-your-user-preferences/personalizing-github-codespaces-for-your-account#dotfiles) in your GitHub settings. When you create a new codespace, GitHub will automatically:
- Clone this repository
- Run `install.sh`
- Link your skills and configuration

This makes all skills in `.agents/` immediately discoverable by Copilot CLI within the codespace.

## Workflows with This Repository

### Adding a New Skill
1. Create directory: `.agents/skills/[your-skill-name]/`
2. Create `.agents/skills/[your-skill-name]/SKILL.md` with:
   - YAML metadata (name, description)
   - Detailed instructions
   - Any context about usage
3. Add supporting files as needed (references/, examples/)
4. Commit to the `.agents/skills/` location
5. The skill is automatically available via symlinks

### Modifying an Existing Skill
1. Edit `.agents/skills/[skill-name]/SKILL.md` or supporting files
2. Commit changes
3. Symlinks in `.claude/` and `.github/` automatically reflect updates

### Using Skills in Copilot/Claude
Skills are loaded and invoked via:
```
/skills list              # See all available skills
/skills info [name]       # Get details on a specific skill
/skills add [name]        # Add skill to context
/skills remove [name]     # Remove skill from context
/skills reload            # Reload all skills
```

## Important Patterns for Agent Work

1. **Check existing skills first** — Before creating new automation, browse `.agents/skills/` to see if similar patterns already exist
2. **Maintain the canonical structure** — Always edit in `.agents/skills/`, never add directly to `.claude/` or `.github/`
3. **Use conventional commits** — Follow the Conventional Commits format for commit messages
4. **Preserve history** — Use `git mv` for file reorganization, not copy/delete
5. **Document intent** — SKILL.md files should be clear enough for future agents to understand purpose and usage

## References

- **AGENTS.md** — Full documentation of project structure and workflows
- **README.md** — Directory structure overview and credits
- **Skill Examples** — See `.agents/skills/*/SKILL.md` for real examples
- **Archived Commands** — See `archive/commands/README.md` for historical context
