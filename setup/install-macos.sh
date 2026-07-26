#!/bin/bash
# Setup script for macOS
# Usage: bash setup/install-macos.sh

set -e

echo "=== Dotfiles Setup for macOS ==="

# --- Homebrew ---
echo "[1/8] Installing Homebrew..."
if ! command -v brew &>/dev/null; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# --- Brew packages ---
echo "[2/8] Installing packages..."
brew install \
  zsh git curl wget \
  bat eza fd fzf ripgrep tmux ncdu grc jq httpie \
  starship zoxide git-delta gh lazygit btop rtk \
  node python rust

# --- Brew casks ---
echo "[3/8] Installing apps..."
# font-hack-nerd-font: every glyph in the sketchybar + fastfetch configs
# stats: what the sketchybar cpu/memory/disk widgets open on click
for cask in alacritty visual-studio-code docker raycast 1password flameshot \
  font-hack-nerd-font stats; do
  brew install --cask "$cask" 2>/dev/null || true
done

# --- Window management / status bar (macOS) ---
DOTFILES_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

echo "[4/8] Installing window management + status bar (macOS)..."
# AeroSpace itself is the vitorebatista fork (its socket-protocol handshake is what
# the sketchybar event provider needs) — install the latest release manually:
#   gh release download --repo vitorebatista/AeroSpace --pattern '*.zip'
# then move AeroSpace.app to /Applications, put bin/aerospace on PATH, and grant
# Accessibility permission (re-grant after every upgrade: builds are ad-hoc signed).
brew install lua luarocks ical-buddy fastfetch \
  FelixKratz/formulae/sketchybar FelixKratz/formulae/borders
brew install --cask font-sketchybar-app-font 2>/dev/null || true

# SbarLua: the Lua bindings the sketchybar config is written against
if [ ! -f "$HOME/.local/share/sketchybar_lua/sketchybar.so" ]; then
  TMP_SBARLUA="$(mktemp -d)"
  git clone --depth 1 https://github.com/FelixKratz/SbarLua.git "$TMP_SBARLUA/SbarLua"
  (cd "$TMP_SBARLUA/SbarLua" && make install)
  rm -rf "$TMP_SBARLUA"
fi

# Lua modules used by the AeroSpace socket client and profile state
luarocks install luasocket 2>/dev/null || true
luarocks install dkjson 2>/dev/null || true

# AeroSpace: the vitorebatista fork. Its socket-protocol handshake is what the
# sketchybar aerospace_events provider (and other third-party clients) need.
if [ ! -d /Applications/AeroSpace.app ]; then
  TMP_AERO="$(mktemp -d)"
  if gh release download --repo vitorebatista/AeroSpace --pattern '*.zip' --dir "$TMP_AERO" 2>/dev/null; then
    (cd "$TMP_AERO" && unzip -q ./*.zip)
    AERO_DIR="$(find "$TMP_AERO" -maxdepth 2 -type d -name 'AeroSpace-v*' | head -1)"
    if [ -n "$AERO_DIR" ]; then
      cp -R "$AERO_DIR/AeroSpace.app" /Applications/
      cp "$AERO_DIR/bin/aerospace" /opt/homebrew/bin/aerospace
      echo "  AeroSpace installed — grant Accessibility permission, then launch it."
      echo "  (Builds are ad-hoc signed: re-grant after every upgrade.)"
    fi
  else
    echo "  Skipped AeroSpace (needs 'gh auth login'). Install manually:"
    echo "    gh release download --repo vitorebatista/AeroSpace --pattern '*.zip'"
  fi
  rm -rf "$TMP_AERO"
fi

# aerospace-swipe: three-finger workspace switching.
# Upstream sets signal(SIGCHLD, SIG_IGN), which breaks pclose() in its CLI
# fallback path — every workspace command silently fails. Patch it out.
if [ ! -d "$HOME/Applications/AerospaceSwipe.app" ]; then
  TMP_SWIPE="$(mktemp -d)"
  git clone --depth 1 https://github.com/acsandmann/aerospace-swipe.git "$TMP_SWIPE/aerospace-swipe"
  sed -i '' '/signal(SIGCHLD, SIG_IGN);/d' "$TMP_SWIPE/aerospace-swipe/src/main.m"
  (cd "$TMP_SWIPE/aerospace-swipe" && make bundle)
  mkdir -p "$HOME/Applications"
  cp -R "$TMP_SWIPE/aerospace-swipe/AerospaceSwipe.app" "$HOME/Applications/"
  rm -rf "$TMP_SWIPE"
  # launch agent (adds PATH, which launchd does not inherit)
  mkdir -p "$HOME/Library/LaunchAgents"
  sed "s|@APP_PATH@|$HOME/Applications/AerospaceSwipe.app|g" \
    "$DOTFILES_ROOT/aerospace-swipe/com.acsandmann.swipe.plist" \
    > "$HOME/Library/LaunchAgents/com.acsandmann.swipe.plist"
  launchctl load "$HOME/Library/LaunchAgents/com.acsandmann.swipe.plist" 2>/dev/null || true
  echo "  AerospaceSwipe installed — grant Accessibility permission when prompted."
fi

# Run the bar at login independently of AeroSpace (aerospace.toml also starts it;
# sketchybar's single-instance lock makes the duplicate launch a no-op).
brew services start FelixKratz/formulae/sketchybar 2>/dev/null || true

# --- Oh My Zsh ---
echo "[5/8] Installing Oh My Zsh..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# --- Zsh plugins ---
echo "[6/8] Installing Zsh plugins..."
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ] && \
  git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ] && \
  git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
[ ! -d "$ZSH_CUSTOM/plugins/fzf-tab" ] && \
  git clone https://github.com/Aloxaf/fzf-tab "$ZSH_CUSTOM/plugins/fzf-tab"
[ ! -d "$ZSH_CUSTOM/plugins/zsh-autopair" ] && \
  git clone https://github.com/hlissner/zsh-autopair "$ZSH_CUSTOM/plugins/zsh-autopair"

# --- Symlinks ---
echo "[7/8] Creating symlinks..."
DOTFILES="$(cd "$(dirname "$0")/.." && pwd)"

ln -sf "$DOTFILES/zsh/.zshrc" "$HOME/.zshrc"
ln -sf "$DOTFILES/git/.gitconfig" "$HOME/.gitconfig"
ln -sf "$DOTFILES/tmux/.tmux.conf" "$HOME/.tmux.conf"

mkdir -p "$HOME/.config"
ln -sf "$DOTFILES/starship/starship.toml" "$HOME/.config/starship.toml"

mkdir -p "$HOME/.config/alacritty"
ln -sf "$DOTFILES/alacritty/alacritty.toml" "$HOME/.config/alacritty/alacritty.toml"

# Git credential helper (macOS-specific path)
ln -sf "$DOTFILES/aerospace/.aerospace.toml" "$HOME/.aerospace.toml"

rm -rf "$HOME/.config/sketchybar"
ln -sf "$DOTFILES/sketchybar/.config/sketchybar" "$HOME/.config/sketchybar"
(cd "$HOME/.config/sketchybar/helpers" && make) || true

# Flameshot rewrites this file itself, so seed a copy rather than symlinking the
# repo (and don't clobber local tweaks on re-runs).
mkdir -p "$HOME/.config/flameshot"
if [ ! -f "$HOME/.config/flameshot/flameshot.ini" ]; then
  sed "s|@HOME@|$HOME|g" "$DOTFILES/flameshot/flameshot.ini" \
    > "$HOME/.config/flameshot/flameshot.ini"
fi

mkdir -p "$HOME/.config/fastfetch"
ln -sf "$DOTFILES/fastfetch/.config/fastfetch/apple.jsonc" "$HOME/.config/fastfetch/apple.jsonc"
ln -sf "$HOME/.config/fastfetch/apple.jsonc" "$HOME/.config/fastfetch/config.jsonc"

git config --file "$HOME/.gitconfig.local" credential.https://github.com.helper ""
git config --file "$HOME/.gitconfig.local" --add credential.https://github.com.helper "!/opt/homebrew/bin/gh auth git-credential"

# --- macOS defaults ---
echo "[8/8] Applying macOS defaults..."

# Finder: show hidden files
defaults write com.apple.finder AppleShowAllFiles -bool true

# Finder: show path bar
defaults write com.apple.finder ShowPathbar -bool true

# Dock: auto-hide
defaults write com.apple.dock autohide -bool true

# Dock: icon size
defaults write com.apple.dock tilesize -int 38

# Key repeat speed
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15

# Disable press-and-hold for keys
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

# Disable window opening animations (AeroSpace goodie: visible in Chrome etc.)
defaults write -g NSAutomaticWindowAnimationsEnabled -bool false

# Screenshots location
mkdir -p "$HOME/Screenshots"
defaults write com.apple.screencapture location -string "$HOME/Screenshots"

# Restart affected apps
killall Finder Dock 2>/dev/null || true

# --- Set default shell ---
ZSH_PATH="$(which zsh)"
if [ "$SHELL" != "$ZSH_PATH" ]; then
  if ! grep -qxF "$ZSH_PATH" /etc/shells; then
    echo "$ZSH_PATH" | sudo tee -a /etc/shells >/dev/null
  fi
  chsh -s "$ZSH_PATH"
fi

echo ""
echo "=== Done! Restart your terminal or run: source ~/.zshrc ==="
