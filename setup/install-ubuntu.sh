#!/bin/bash
# Setup script for Ubuntu / Regolith
# Usage: bash setup/install-ubuntu.sh

set -e

echo "=== Dotfiles Setup for Ubuntu/Regolith ==="

# --- System packages ---
echo "[1/8] Installing system packages..."
sudo apt update
sudo apt install -y \
  zsh git curl wget \
  bat fd-find fzf ripgrep tmux ncdu grc jq httpie \
  build-essential cmake pkg-config \
  libfontconfig1-dev libxcb-xfixes0-dev libxkbcommon-dev \
  docker.io docker-compose-v2 gh

# --- Rust & Cargo tools ---
echo "[2/8] Installing Rust and Cargo tools..."
if ! command -v cargo &>/dev/null; then
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  source "$HOME/.cargo/env"
fi
cargo install alacritty eza git-delta zoxide rtk

# --- Oh My Zsh ---
echo "[3/8] Installing Oh My Zsh..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# --- Zsh plugins ---
echo "[4/8] Installing Zsh plugins..."
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ] && \
  git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ] && \
  git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
[ ! -d "$ZSH_CUSTOM/plugins/fzf-tab" ] && \
  git clone https://github.com/Aloxaf/fzf-tab "$ZSH_CUSTOM/plugins/fzf-tab"
[ ! -d "$ZSH_CUSTOM/plugins/zsh-autopair" ] && \
  git clone https://github.com/hlissner/zsh-autopair "$ZSH_CUSTOM/plugins/zsh-autopair"

# --- Starship ---
echo "[5/8] Installing Starship prompt..."
if ! command -v starship &>/dev/null; then
  curl -sS https://starship.rs/install.sh | sh -s -- -y
fi

# --- Symlinks ---
echo "[6/8] Creating symlinks..."
DOTFILES="$(cd "$(dirname "$0")/.." && pwd)"

ln -sf "$DOTFILES/zsh/.zshrc" "$HOME/.zshrc"
ln -sf "$DOTFILES/git/.gitconfig" "$HOME/.gitconfig"
ln -sf "$DOTFILES/tmux/.tmux.conf" "$HOME/.tmux.conf"

mkdir -p "$HOME/.config/starship"
ln -sf "$DOTFILES/starship/starship.toml" "$HOME/.config/starship.toml"

mkdir -p "$HOME/.config/alacritty"
ln -sf "$DOTFILES/alacritty/alacritty.toml" "$HOME/.config/alacritty/alacritty.toml"

# Git credential helper (Linux-specific path)
git config --file "$HOME/.gitconfig.local" credential.https://github.com.helper ""
git config --file "$HOME/.gitconfig.local" --add credential.https://github.com.helper "!/usr/bin/gh auth git-credential"

# --- Regolith (if installed) ---
if command -v i3 &>/dev/null && [ -d /etc/regolith ]; then
  echo "[7/8] Configuring Regolith..."
  mkdir -p "$HOME/.config/regolith3/i3xrocks/conf.d"
  for f in "$DOTFILES/regolith/i3xrocks/"*; do
    ln -sf "$f" "$HOME/.config/regolith3/i3xrocks/conf.d/$(basename "$f")"
  done
  [ -f "$DOTFILES/regolith/Xresources" ] && \
    ln -sf "$DOTFILES/regolith/Xresources" "$HOME/.config/regolith3/Xresources"

  # i3xrocks indicators
  sudo apt install -y \
    i3xrocks-cpu-usage i3xrocks-memory i3xrocks-disk-capacity \
    i3xrocks-temp i3xrocks-time i3xrocks-battery i3xrocks-net-traffic
else
  echo "[7/8] Regolith not detected, skipping..."
fi

# --- System tuning ---
echo "[8/8] Applying system tweaks..."
# Swappiness
if [ "$(cat /proc/sys/vm/swappiness)" != "10" ]; then
  sudo sysctl vm.swappiness=10
  echo "vm.swappiness=10" | sudo tee -a /etc/sysctl.conf
fi

# auto-cpufreq
if ! command -v auto-cpufreq &>/dev/null; then
  sudo snap install auto-cpufreq
  sudo auto-cpufreq --install 2>/dev/null || true
fi

# --- Set default shell ---
if [ "$SHELL" != "$(which zsh)" ]; then
  chsh -s "$(which zsh)"
fi

# --- Set default terminal ---
if command -v alacritty &>/dev/null; then
  sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator "$HOME/.cargo/bin/alacritty" 50
  sudo update-alternatives --set x-terminal-emulator "$HOME/.cargo/bin/alacritty"
fi

echo ""
echo "=== Done! Restart your terminal or run: source ~/.zshrc ==="
