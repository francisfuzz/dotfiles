#!/bin/bash
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Apply gitconfig
if [ -f "$DOTFILES_DIR/gitconfig" ]; then
  mkdir -p ~/.config/git
  cp "$DOTFILES_DIR/gitconfig" ~/.gitconfig
  echo "✓ gitconfig installed"
fi
