# dotfiles

[@francisfuzz](https://francisfuzz.com/)'s dotfiles

## Directory Structure

This repository uses a consolidated configuration approach:

### `.agents/` – Canonical Configuration
The single source of truth for all agent/skill configurations:
- **commands/** – Claude commands (engineering-brief, interview, etc.)
- **prompts/** – Prompt templates (start-work, etc.)
- **skills/** – Skills for automation (start-work, conventional-commits, pr-review-assist, handoff-primitive)

### `.claude/` & `.github/`
Backward-compatible symbolic links pointing to `.agents/`:
- `.claude/commands` → `../.agents/commands`
- `.claude/skills` → `../.agents/skills`
- `.github/prompts` → `../.agents/prompts`
- `.github/skills` → `../.agents/skills`

This allows tools expecting the original paths to work seamlessly while maintaining a single location for configuration updates.

## License

[GNU General Public License v3.0](./LICENSE)

## Credits

- Interview Command Inspiration: [`@developersdigest`](https://github.com/developersdigest) ["Claude Code 'Interview' Mode in 6 Minutes"](https://www.youtube.com/watch?v=vgHBEju4kGE)
