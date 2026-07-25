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

### AeroSpace (macOS only)
- Tiling window manager config (i3-like), running the [vitorebatista/AeroSpace](https://github.com/vitorebatista/AeroSpace) fork
- Window rules match by `app-name-regex-substring` (Slack → S, VS Code → C, Chrome → 9, Brave → 1, WhatsApp → W, Spotify/Music → M; Finder/QuickTime float)
- JankyBorders on startup; SketchyBar updates are fully event-driven (no exec callbacks in the config)

### SketchyBar (macOS only)
Lua (SbarLua) status bar based on [bin101's config](https://github.com/bin101/dotfiles), floating-bar style (rounded, translucent, 8px margins).

- **Event-driven AeroSpace integration** — a C provider subscribes to the AeroSpace socket (needs the fork's socket-protocol handshake, fork.8+); workspace/focus/mode/window events stream straight into the bar
- **Workspace profiles** — profiles are named groups of workspaces (`Personal`, `Work`). The bar shows only the active profile's workspaces; focusing a workspace switches to the profile that owns it; an unassigned workspace is adopted by the active profile when it gets its first window. Managed from the 󰕰 dropdown (create/rename/delete); state in `~/.local/state/aerospace/workspace_profiles.json`
- **Per-workspace pills** with app icons (empty workspaces hidden unless focused), binding-mode indicator, front app
- **Right side:** clock (click → Calendar), next-meeting countdown via icalBuddy (`Xmin left · title`, filtered to the work calendar), network up/down with details popup, CPU % + memory % (colored by load, click → Stats), Secure Input padlock warning
- Battery and Low Power Mode widgets exist but are commented out in `items/widgets/init.lua`
- Fonts: Hack Nerd Font (SF Pro variant available by flipping `settings.lua` + `helpers/default_font.lua`)
- Deps: `brew install lua luarocks ical-buddy FelixKratz/formulae/sketchybar --cask font-sketchybar-app-font`, `luarocks install luasocket dkjson`, [SbarLua](https://github.com/FelixKratz/SbarLua); build `helpers/` with make; grant sketchybar Calendars access (for icalBuddy)

### fastfetch
- Apple-logo system info preset (`apple.jsonc`)

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
