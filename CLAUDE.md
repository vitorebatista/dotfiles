# Claude Code context

This is a dotfiles repository for personal development environment setup.

## Structure

- `zsh/` — Zsh shell config (Oh My Zsh + plugins)
- `git/` — Git config with delta, aliases, rebase workflow
- `starship/` — Starship prompt theme
- `alacritty/` — GPU-accelerated terminal (Dracula theme)
- `tmux/` — Terminal multiplexer config
- `vscode/` — VS Code settings and extensions
- `claude/` — Claude Code plugin settings
- `regolith/` — Regolith/i3 desktop config (Linux only)
- `setup/` — Install scripts for Ubuntu and macOS
- `bin/` — Custom scripts added to PATH

## Conventions

- Configs are symlinked from this repo to their expected locations
- Machine-specific overrides go in `*.local` files (not version controlled)
- Setup scripts are idempotent (safe to run multiple times)
- Ubuntu script includes system tuning (swap, CPU governor)

## When editing configs

- Test changes locally before committing
- Keep configs portable between Ubuntu and macOS where possible
- Use `.local` override pattern for machine-specific values
- Do not commit secrets, tokens, or absolute paths
