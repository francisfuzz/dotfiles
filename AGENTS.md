# AGENTS.md

Configuration and guidance for AI coding agents working with this dotfiles repository.

## Project Overview

This repository contains personal dotfiles and agent/skill configurations for GitHub Copilot CLI and Claude AI workflows. The project consolidates configuration into a single canonical `.agents/` directory with backward-compatible symlinks.

### Key Components
- **`.agents/commands/`** – Claude command templates for specification and planning
- **`.agents/prompts/`** – Prompt templates for AI-guided workflows
- **`.agents/skills/`** – Reusable skills and automation capabilities
- **`.claude/` & `.github/`** – Symbolic links pointing to `.agents/` for tool compatibility

## Directory Structure Guide

### Canonical Configuration (`.agents/`)
All git-tracked configuration files live here:
```
.agents/
├── commands/              # Claude command references
│   ├── start-work.md      # Reference to start-work skill
│   └── README.md          # Commands documentation
├── prompts/              # Prompt templates
│   └── start-work.prompt.md
└── skills/               # Reusable skills
    ├── conventional-commits/
    ├── engineering-brief/
    ├── handoff-primitive/
    ├── interview/
    ├── pr-review-assist/
    ├── start-work/
    └── venture-feasibility/
```

### Symlink Mappings
Local tools expect configurations in `.claude/` and `.github/`:
- `.claude/commands` → `../.agents/commands` (symlink)
- `.claude/skills` → `../.agents/skills` (symlink)
- `.github/prompts` → `../.agents/prompts` (symlink)
- `.github/skills` → `../.agents/skills` (symlink)

### Local Runtime Data (`.claude/`)
Non-tracked local files in `.claude/`:
- `cache/` – Cached data from Copilot CLI
- `commands-env/` – Session-specific environment
- `debug/` – Debug logs
- `history.jsonl` – Session history
- `plugins/` – Installed plugins
- `projects/` – Project workspace data
- `settings.json` – Local Copilot settings
- `stats-cache.json` – Usage statistics
- Other runtime directories (telemetry, todos, etc.)

All local files are `.gitignore`'d and not tracked.

## Working with Skills

### Structure of a Skill
Each skill directory contains:
- `SKILL.md` – Skill definition with metadata and instructions
- Optional subdirectories for supporting files (references/, examples/, etc.)

### Common Skills
- **conventional-commits** – Generate properly formatted commit messages
- **engineering-brief** – Define constraints, risks, and success metrics before building
- **handoff-primitive** – Preserve state between sessions
- **interview** – Conduct comprehensive discovery interviews with Socratic questioning
- **pr-review-assist** – Review code changes intelligently
- **start-work** – Begin work on GitHub issues with discovery and TDD
- **venture-feasibility** – Reality-check business ideas with math before investing time

### Using Skills
Skills are available to Claude and Copilot CLI. Load them with:
```
/skills [list|info|add|remove|reload]
```

## Working with Commands

Commands have been primarily migrated to skills. See `.agents/commands/README.md` for documentation.

The `start-work.md` file serves as a reference to the start-work skill.

## Development Workflow

### Before Starting a Task
1. Understand the project structure and existing patterns
2. Check `.agents/skills/` for relevant automation capabilities
3. Review `.agents/commands/README.md` for specification templates
4. For new issues: Run `start-work` skill or prompt

### Git and Version Control
- Use `conventional-commits` skill to generate commit messages
- Preserve git history through file moves and refactors
- Test all changes before committing

### Code Style and Conventions
- Maintain consistency with existing templates and commands
- Follow the patterns in `.agents/` for new additions
- Update documentation when adding new skills or commands

## Git Configuration

### Symlink Handling
This repository uses symlinks for backward compatibility. Git correctly handles symlinks on macOS and Linux.

### File Tracking
- Git tracks files in `.agents/` (the canonical location)
- Git tracks symlinks in `.claude/` and `.github/`
- Local runtime data in `.claude/` is not tracked (see `.gitignore` or system defaults)

### Making Changes
When updating configuration:
1. Edit files in `.agents/` (the canonical source)
2. Symlinks in `.claude/` and `.github/` automatically reflect changes
3. Commit changes at the `.agents/` location

## Adding New Skills or Commands

### Adding a New Skill
1. Create a directory: `.agents/skills/your-skill-name/`
2. Add `SKILL.md` with:
   ```yaml
   ---
   name: your-skill-name
   description: Brief description of what the skill does
   ---
   
   # Detailed instructions here
   ```
3. Add supporting files or references as needed
4. Commit to `.agents/skills/`

### Adding a New Command
1. Create a markdown file: `.agents/commands/your-command.md`
2. Document the purpose and usage clearly
3. Include examples and templates
4. Commit to `.agents/commands/`

## Testing and Validation

### Before Committing
- Verify symlinks resolve correctly with: `ls -la .claude/ .github/`
- Check that skills load: `/skills list` in Copilot CLI
- Review changes with: `/diff`

### Git Integrity
- Verify file paths work through both old and new locations
- Test that `git log` correctly shows renames and history
- Ensure `git status` shows expected changes

## References and Resources

- **GitHub Copilot CLI Docs:** https://docs.github.com/copilot/concepts/agents/about-copilot-cli
- **AGENTS.md Format:** https://agents.md/
- **Claude Commands Guide:** See `.agents/commands/README.md`
- **Skills Reference:** See `.agents/skills/*/SKILL.md`

## Repository Patterns

### Single Source of Truth
All configuration is defined once in `.agents/` to avoid duplication and maintenance burden.

### Backward Compatibility
Symlinks in `.claude/` and `.github/` maintain compatibility with tools expecting those paths.

### Modular Organization
Each skill and command is self-contained and independently useful.

## Common Tasks

### Viewing All Available Skills
```bash
ls -la .agents/skills/
```

### Checking Symlink Status
```bash
ls -la .claude/ .github/
readlink .claude/commands
```

### Adding a Directory to Copilot CLI Context
```bash
/add-dir /path/to/directory
```

### Reviewing a Skill's Instructions
```bash
cat .agents/skills/start-work/SKILL.md
```

## Notes for Agent Contributors

- This repository is primarily for personal use but welcomes improvements
- When modifying skills or commands, ensure documentation is clear and complete
- Preserve git history through careful use of `git mv`
- Test symlink resolution across macOS, Linux, and Windows if possible
- Keep the single-source-of-truth principle: edit in `.agents/`, never duplicate

## Security Considerations

- Local data in `.claude/` may contain sensitive information (API keys, tokens)
- These files are git-ignored and never committed
- Be careful when sharing `.claude/` directory or environment snapshots
- Use fine-grained PATs with Copilot Requests permission for authentication
- Keep `.agents/` content appropriate for version control and sharing
