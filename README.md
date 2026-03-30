# dotfiles

Personal development environment configuration for **Ubuntu/Regolith** and **macOS**.

## What's included

### Shell (Zsh + Oh My Zsh)
- Starship prompt with custom config
- Plugins: git, docker, fzf, fzf-tab, z, zsh-autosuggestions, zsh-syntax-highlighting, zsh-autopair
- Modern CLI aliases: `bat`, `eza`, `zoxide`, `fd`, `ripgrep`
- Local overrides via `~/.zsh.local`

### Git
- Rebase on pull, auto-setup remote, prune on fetch
- Delta as pager (side-by-side diffs with syntax highlighting)
- 20+ useful aliases
- zdiff3 conflict style, rerere enabled
- Local overrides via `~/.gitconfig.local`

### Terminal
- **Alacritty** with Dracula theme
- **Tmux** with sane defaults (Ctrl-A prefix, mouse, splits with `|` and `-`)

### Editors
- **VS Code** settings and extensions list with install script
- **Claude Code** plugin configuration
- **.editorconfig** for cross-editor consistency

### Regolith (Linux only)
- i3xrocks bar: CPU%, Memory%, Disk%, Temperature, Battery, Time
- Xresources overrides
- auto-cpufreq for CPU governor management
- Swap tuning (8GB, swappiness=10)

### Tools installed
| Tool | Purpose |
|------|---------|
| bat | cat with syntax highlighting |
| eza | ls with icons and git status |
| fd | find alternative |
| fzf | fuzzy finder |
| ripgrep | fast grep |
| zoxide | smart cd |
| git-delta | beautiful diffs |
| tmux | terminal multiplexer |
| ncdu | disk usage analyzer |
| alacritty | GPU-accelerated terminal |

## Quick start

### Ubuntu / Regolith
```bash
git clone https://github.com/vitorebatista/dotfiles ~/dotfiles
bash ~/dotfiles/setup/install-ubuntu.sh
```

### macOS
```bash
git clone https://github.com/vitorebatista/dotfiles ~/dotfiles
bash ~/dotfiles/setup/install-macos.sh
```

### Symlinks only (tools already installed)
```bash
bash ~/dotfiles/setup/symlinks.sh
```

## Day-to-day usage

### Sync local changes back to repo
```bash
dotfiles-sync
```
Copies current configs into the repo and shows what changed.

### Update dotfiles from repo on another machine
```bash
dotfiles-update
```
Pulls latest changes, re-applies symlinks, and updates zsh plugins.

## Structure

```
dotfiles/
├── zsh/                  # Zsh configuration
│   └── .zshrc
├── git/                  # Git configuration
│   └── .gitconfig
├── starship/             # Starship prompt theme
│   └── starship.toml
├── alacritty/            # Alacritty terminal config
│   └── alacritty.toml
├── tmux/                 # Tmux config
│   └── .tmux.conf
├── vscode/               # VS Code
│   ├── settings.json
│   ├── extensions.txt
│   └── install-extensions.sh
├── claude/               # Claude Code
│   └── settings.json
├── regolith/             # Regolith desktop (Linux)
│   ├── Xresources
│   └── i3xrocks/         # Bar indicators
├── setup/                # Installation scripts
│   ├── install-ubuntu.sh # Full setup for Ubuntu/Regolith
│   ├── install-macos.sh  # Full setup for macOS
│   └── symlinks.sh       # Symlinks only
├── bin/                  # Custom scripts (added to PATH)
│   ├── dotfiles-sync     # Sync configs back to repo
│   └── dotfiles-update   # Pull and re-apply
├── .editorconfig         # Cross-editor formatting rules
└── CLAUDE.md             # AI agent context
```

## Local overrides

Machine-specific configs that shouldn't be version controlled:
- `~/.zsh.local` — extra shell config
- `~/.gitconfig.local` — git credentials, work email, etc.
