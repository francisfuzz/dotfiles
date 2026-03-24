# dotfiles

[@francisfuzz](https://francisfuzz.com/)'s dotfiles

## Directory Structure

This repository uses a consolidated configuration approach:

### `.agents/` – Canonical Configuration
The single source of truth for all agent/skill configurations:
- **skills/** – Skills for automation (start-work, conventional-commits, pr-review-assist, handoff-primitive)

### `archive/` – Archived Configuration
Previously active configuration that has been retired:
- **commands/** – Claude commands (engineering-brief, interview, etc.)
- **prompts/** – Prompt templates (start-work, etc.)

### `.claude/` & `.github/`
Backward-compatible symbolic links:
- `.claude/commands` → `../archive/commands`
- `.claude/skills` → `../.agents/skills`
- `.github/prompts` → `../archive/prompts`
- `.github/skills` → `../.agents/skills`

This allows tools expecting the original paths to work seamlessly while maintaining a single location for configuration updates.

## License

[GNU General Public License v3.0](./LICENSE)

## Credits

- Interview Command Inspiration: [`@developersdigest`](https://github.com/developersdigest) ["Claude Code 'Interview' Mode in 6 Minutes"](https://www.youtube.com/watch?v=vgHBEju4kGE)
