#!/bin/bash
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Safe symlink: creates or updates a symlink, warns if a real file/dir is in the way
symlink() {
  local target="$1"
  local link_path="$2"
  if [ -L "$link_path" ]; then
    ln -sf "$target" "$link_path"
    echo "✓ $link_path updated"
  elif [ -e "$link_path" ]; then
    echo "⚠ $link_path exists and is not a symlink — skipping (remove it manually to install)"
  else
    ln -s "$target" "$link_path"
    echo "✓ $link_path symlinked"
  fi
}

# Apply gitconfig
if [ -f "$DOTFILES_DIR/gitconfig" ]; then
  mkdir -p ~/.config/git
  cp "$DOTFILES_DIR/gitconfig" ~/.gitconfig
  echo "✓ gitconfig installed"
fi

# ~/.agents — whole directory is safe to symlink (no user runtime data lives here)
symlink "$DOTFILES_DIR/.agents" "$HOME/.agents"

# ~/.claude — symlink individual subdirs only; the parent dir accumulates runtime
# data (history, sessions, settings) that must not be replaced on a daily-use machine
mkdir -p "$HOME/.claude"
symlink "$DOTFILES_DIR/AGENTS.md"         "$HOME/.claude/CLAUDE.md"
symlink "$DOTFILES_DIR/.agents/agents"   "$HOME/.claude/agents"
symlink "$DOTFILES_DIR/.agents/skills"   "$HOME/.claude/skills"
symlink "$DOTFILES_DIR/archive/commands" "$HOME/.claude/commands"
