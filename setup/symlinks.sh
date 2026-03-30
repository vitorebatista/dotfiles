#!/bin/bash
# Only create symlinks (for when tools are already installed)
# Usage: bash setup/symlinks.sh

set -e

DOTFILES="$(cd "$(dirname "$0")/.." && pwd)"

echo "Creating symlinks from $DOTFILES..."

# Shell
ln -sf "$DOTFILES/zsh/.zshrc" "$HOME/.zshrc"

# Git
ln -sf "$DOTFILES/git/.gitconfig" "$HOME/.gitconfig"

# Tmux
ln -sf "$DOTFILES/tmux/.tmux.conf" "$HOME/.tmux.conf"

# Starship
mkdir -p "$HOME/.config"
ln -sf "$DOTFILES/starship/starship.toml" "$HOME/.config/starship.toml"

# Alacritty
mkdir -p "$HOME/.config/alacritty"
ln -sf "$DOTFILES/alacritty/alacritty.toml" "$HOME/.config/alacritty/alacritty.toml"

# VS Code
mkdir -p "$HOME/.config/Code/User"
ln -sf "$DOTFILES/vscode/settings.json" "$HOME/.config/Code/User/settings.json"

# Claude Code
mkdir -p "$HOME/.claude"
ln -sf "$DOTFILES/claude/settings.json" "$HOME/.claude/settings.json"

# Regolith (Linux only)
if [ -d /etc/regolith ]; then
  mkdir -p "$HOME/.config/regolith3/i3xrocks/conf.d"
  for f in "$DOTFILES/regolith/i3xrocks/"*; do
    [ -f "$f" ] && ln -sf "$f" "$HOME/.config/regolith3/i3xrocks/conf.d/$(basename "$f")"
  done
  [ -f "$DOTFILES/regolith/Xresources" ] && \
    ln -sf "$DOTFILES/regolith/Xresources" "$HOME/.config/regolith3/Xresources"
fi

echo "Done!"
