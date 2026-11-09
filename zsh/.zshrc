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

# Git worktrees (worktrunk) + AI agent YOLO mode
# On exit, everything new since the session started is removed: its worktree,
# any other worktree the agent made in a ~/Work repo, their Claude temp
# folders, and new Docker containers, images, volumes and networks.
_agent-w() {
  local name="$1"
  shift

  local start=$PWD worktrees_before=$(_agent-w-worktrees) docker_before=$(_agent-w-docker)

  local create=(--create)
  git show-ref --verify --quiet "refs/heads/$name" && create=()

  wt switch "${create[@]}" "$name" || return 1
  # Resolve the path now: the agent may switch branches inside the worktree,
  # so removing by branch name afterwards would miss it.
  local dir=$(git worktree list --porcelain |
    awk -v b="branch refs/heads/$name" '/^worktree /{p=substr($0,10)} $0==b{print p}')
  [[ -n $dir ]] || { print -u2 "No worktree found for $name"; return 1; }

  (cd "$dir" && "$@")
  _agent-w-cleanup "$dir" "$worktrees_before" "$docker_before"
  # wt's shell function cd'd this shell into the worktree; go back
  cd "$start"
}

# Worktrees of the repos in ~/Work, except the on-call bot's (.worktrees/).
_agent-w-worktrees() {
  local repo
  for repo in ~/Work/*/.git(/N:h); do
    git -C "$repo" worktree list --porcelain | sed -n 's/^worktree //p'
  done | grep -v '/\.worktrees/' | sort
}

_agent-w-docker() {
  (( $+commands[docker] )) || return 0
  {
    docker container ls -aq --no-trunc | sed 's/^/container /'
    docker image ls -aq --no-trunc | sed 's/^/image /'
    docker volume ls -q | sed 's/^/volume /'
    docker network ls -q --no-trunc | sed 's/^/network /'
  } 2>/dev/null | sort -u
}

# Is a process (another session, a dev server) working inside $1?
_agent-w-busy() {
  lsof -d cwd -Fn 2>/dev/null | sed -n 's/^n//p' |
    awk -v d="$1" '$0 == d || index($0, d "/") == 1 { found = 1 } END { exit !found }'
}

_agent-w-cleanup() {
  local dir="$1" worktrees_before="$2" docker_before="$3" w main kind id
  local -a worktrees=("$dir" ${(f)"$(comm -13 <(print -r -- "$worktrees_before") <(_agent-w-worktrees))"})
  local -a removed=()

  for w in ${(u)worktrees}; do
    [[ -d $w ]] || continue
    if [[ $w != $dir ]] && _agent-w-busy "$w"; then
      print -u2 "Kept $w: a process is still working in it"
      continue
    fi
    # ponytail: no --force, so a dirty worktree is kept and wt says why
    # From the main clone, with the binary: wt's shell function would cd there
    main=$(git -C "$w" rev-parse --path-format=absolute --git-common-dir)
    command wt -C "${main:h}" remove --foreground "$w" || continue
    removed+=("$w")
    # Claude keeps these in /tmp even when TMPDIR is set (macOS)
    command rm -rf -- "/tmp/claude-$UID/${w//[^A-Za-z0-9]/-}"
  done

  local -a docker_new=(${(f)"$(comm -13 <(print -r -- "$docker_before") <(_agent-w-docker))"})
  local compose_dir ours
  for kind in container image volume network; do
    for id in ${${(M)docker_new:#$kind *}#$kind }; do
      # A running container may be another session's: stop only one that
      # docker compose started from a worktree removed above.
      if [[ $kind == container &&
            $(docker inspect -f '{{.State.Running}}' "$id" 2>/dev/null) == true ]]; then
        compose_dir=$(docker inspect -f '{{index .Config.Labels "com.docker.compose.project.working_dir"}}' "$id")
        ours=0
        for w in $removed; do [[ $compose_dir == $w || $compose_dir == $w/* ]] && ours=1; done
        (( ours )) || { print -u2 "Kept running container ${id:0:12}"; continue; }
      fi
      if [[ $kind == container ]]; then
        docker container rm -f "$id" >/dev/null 2>&1
      else
        docker "$kind" rm "$id" >/dev/null 2>&1
      fi || print -u2 "Kept docker $kind ${${id#sha256:}:0:12}: in use"
    done
  done
}

# The agent is told it already has a worktree, so it doesn't make another one.
_agent_w_rule="This session runs in a git worktree made for it, removed when the session ends. \
Work in it: for a new branch run \`git switch -c <branch>\` here. \
Don't create other git worktrees (wt switch --create, git worktree add) unless the user asks."

codex-w() {
  (( $# == 1 )) || { print -u2 "Usage: codex-w <branch>"; return 2; }
  # -c takes TOML, so the rule goes in quotes (it has no double quotes)
  _agent-w "$1" codex --dangerously-bypass-approvals-and-sandbox \
    -c "developer_instructions=\"$_agent_w_rule\""
}

claude-w() {
  (( $# == 1 )) || { print -u2 "Usage: claude-w <branch>"; return 2; }
  _agent-w "$1" claude --dangerously-skip-permissions --append-system-prompt "$_agent_w_rule"
}

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
alias argus="herdr --remote argus.exe.xyz"

if command -v wt >/dev/null 2>&1; then eval "$(command wt config shell init zsh)"; fi
