# Path
# /opt/homebrew/bin ahead of /usr/local/bin: a stray hand-downloaded binary in
# /usr/local/bin otherwise shadows the Homebrew one (this bit with aerospace,
# where the older CLI could not speak the running app's socket protocol).
export PATH=$HOME/.cargo/bin:$HOME/bin:$HOME/.local/bin:/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/go/bin:/usr/local/bin:$PATH

# Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""

plugins=(
  git
  docker
  docker-compose
  npm
  fzf
  fzf-tab
  zsh-autosuggestions
  zsh-syntax-highlighting
  zsh-autopair
)

source $ZSH/oh-my-zsh.sh


# Modern CLI replacements
command -v bat &>/dev/null && alias cat="bat --paging=never"
command -v batcat &>/dev/null && alias cat="batcat --paging=never"
alias ls="eza --icons --group-directories-first"
alias ll="eza -la --icons --group-directories-first"
alias tree="eza --tree --icons"

# Navigation
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."

# Git
alias g="git"
alias gs="git status"
alias gd="git diff"
alias gl="git log --oneline -20"
alias gundo="git reset --soft HEAD~1"
alias gpf="git push --force-with-lease"

# Docker
alias dc="docker compose"
alias dps="docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'"
alias dclean="docker system prune -af --volumes"

# Claude
claude-d() { claude --dangerously-skip-permissions "$@"; }

# Safety
# BSD rm has -I but not --preserve-root, so guard the GNU-only flag
if [ "$(uname)" = "Darwin" ]; then
  alias rm="rm -I"
else
  alias rm="rm -I --preserve-root=all"
fi
alias df="df -h"
alias du="du -h"

# Mise (runtime version manager)
# Shims work in non-interactive shells (scripts, editor tools); activate hook handles interactive shells.
# Appended, not prepended: a shim for a tool mise doesn't manage (e.g. codex) hangs
# forever instead of falling through, shadowing the real binary in ~/.local/bin.
export PATH="$PATH:$HOME/.local/share/mise/shims"
eval "$(mise activate zsh)"

# Zoxide (smart cd)
eval "$(zoxide init zsh)"

# Starship prompt
eval "$(starship init zsh)"

# Local overrides (not version controlled)
[ -f ~/.zsh.local ] && source ~/.zsh.local

export PATH="/opt/homebrew/opt/libpq/bin:$PATH"

# --- Secrets ------------------------------------------------------------------
# This file is tracked in a public dotfiles repo, so credentials live outside it.
[ -r "$HOME/.config/secrets.zsh" ] && source "$HOME/.config/secrets.zsh"


# Homebrew
command -v brew &>/dev/null && eval "$(brew shellenv)"

# Homebrew: never prompt for confirmation
export HOMEBREW_NO_ASK=1


# Manually sync Claude memory to GitHub (also runs hourly via launchd)
alias memory-update="$HOME/claude-memory-backup/auto-sync.sh"
