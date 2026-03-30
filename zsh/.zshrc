# Path
export PATH=$HOME/.cargo/bin:$HOME/bin:$HOME/.local/bin:/usr/local/go/bin:/usr/local/bin:$PATH

# Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""

plugins=(
  git
  docker
  docker-compose
  npm
  asdf
  fzf
  fzf-tab
  z
  zsh-autosuggestions
  zsh-syntax-highlighting
  zsh-autopair
)

source $ZSH/oh-my-zsh.sh


# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Modern CLI replacements
alias cat="batcat"
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
alias rm="rm -I --preserve-root=all"
alias df="df -h"
alias du="du -h"

# Zoxide (smart cd)
eval "$(zoxide init zsh)"

# Starship prompt
eval "$(starship init zsh)"

# Local overrides (not version controlled)
[ -f ~/.zsh.local ] && source ~/.zsh.local
