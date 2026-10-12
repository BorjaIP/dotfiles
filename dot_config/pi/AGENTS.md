# Pi conventions

## Commit format

`[SCOPE] Short description`

| Scope | Use |
|---|---|
| `PI` | Pi config / extensions / themes |
| `ZSH` | Zsh env / zshenv |
| `TMUX` | Tmux config / cheatsheets |
| `NVIM` | Neovim / editor config |
| `Claude` | Claude / agent instructions |

Examples:
- `[PI] Custom status bar with context gauge and cache stats`
- `[ZSH] Fix env var path`
- `[TMUX] Update cheatsheet`

Keep the description short, descriptive, no trailing dot.

## Code & comments

All code and comments in English only.

## Zustand (mental model)

- This repo tracks **dotfiles via chezmoi**.
- Pi config lives in `~/.config/pi/` (→ `dot_config/pi/` in chezmoi).
- Session store is at `~/.local/state/pi/`.