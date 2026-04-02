#!/bin/bash
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Apply gitconfig
if [ -f "$DOTFILES_DIR/gitconfig" ]; then
  mkdir -p ~/.config/git
  cp "$DOTFILES_DIR/gitconfig" ~/.gitconfig
  echo "✓ gitconfig installed"
fi

# Symlink agent config directories to home for discoverability
# by Claude Code, Copilot, OpenCode, and other agents in Codespaces
for dir in .claude .agents; do
  if [ -d "$DOTFILES_DIR/$dir" ]; then
    ln -sf "$DOTFILES_DIR/$dir" ~/"$dir"
    echo "✓ $dir symlinked"
  fi
done
