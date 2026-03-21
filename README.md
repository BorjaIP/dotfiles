# ☄️ Dotfiles 🖥

Every line of config is simple—just what’s needed, nothing more. These dotfiles are minimal and essential, avoiding heavy plugins or bloated frameworks across all tools. It’s not about adding more, it’s about needing less.

![terminal](https://github.com/user-attachments/assets/16a1f8c7-5fcc-41eb-be54-10279750adc4)

![vscode](https://github.com/user-attachments/assets/f8a44e04-230a-4c6d-afbc-6a7ceb3d8c8f)

![base16-ocean](https://github.com/user-attachments/assets/3dfdbeb7-aba3-4ecd-bcde-ce4202d9b930)

## Features
<!-- https://github.com/inttter/md-badges -->

[![Zsh](https://img.shields.io/badge/Zsh-F15A24?style=for-the-badge&logo=zsh&logoColor=fff)](#) [![Neovim](https://img.shields.io/badge/Neovim-57A143?style=for-the-badge&logo=neovim&logoColor=fff)](#) [![Vim](https://img.shields.io/badge/Vim-%2311AB00.svg?style=for-the-badge&logo=vim&logoColor=white)](#) [![tmux](https://img.shields.io/badge/tmux-1BB91F?style=for-the-badge&logo=tmux&logoColor=fff)](#) [![Visual Studio Code](https://custom-icon-badges.demolab.com/badge/Visual%20Studio%20Code-0078d7.svg?style=for-the-badge&logo=vsc&logoColor=white)](#)

This config repo is designed for Arch Linux and macOS.

- [ZSH](https://wiki.archlinux.org/index.php/Zsh) as Shell.
- [Neovim](https://wiki.archlinux.org/index.php/Neovim) as Editor.
- [Tmux](https://wiki.archlinux.org/index.php/Tmux) as Terminal Multiplexer.

### My Developer Environment

| 🧠 Toolset      | 🔧 Config / Plugins / Tools                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
| -------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **📝 Neovim**   | - Plugin Manager: [Lazy.nvim](https://github.com/folke/lazy.nvim)  <br> - Colorscheme: [Base16](https://github.com/chriskempson/base16) <br> - LSP: [Built-in LSP](https://neovim.io/doc/user/lsp.html) <br> - LSP Manager: [Mason](https://github.com/williamboman/mason.nvim) <br> - Formatter: [conform.nvim](https://github.com/stevearc/conform.nvim) <br> - Statusline: [Lualine](https://github.com/nvim-lualine/lualine.nvim) <br> - Fuzzy Finder: [Telescope](https://github.com/nvim-telescope/telescope.nvim) <br> - Syntax Highlighting: [Treesitter](https://github.com/nvim-treesitter/nvim-treesitter) |
| **🐚 ZSH**      | - Prompt: [Pure](https://github.com/sindresorhus/pure) <br> - [fzf](https://github.com/junegunn/fzf)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
| **🖥 Terminal** | - [bat](https://github.com/sharkdp/bat) – better `cat` <br> - [eza](https://github.com/eza-community/eza) – better `ls` <br> - [tldr](https://github.com/tealdeer-rs/tealdeer) – simplified man pages <br> - [zoxide](https://github.com/ajeetdsouza/zoxide) – smarter `cd`                                                                                                                                                                                                                                                                                                                                                |

Example command:

```bash
fzf --preview 'bat --style=numbers --color=always {}'
```

## Installation

>[!important]
>
> Only compatible with `Arch Linux` and `macOS`

This command will install software and apply all the configurations in `~/.local/share/chezmoi`.

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin" init --apply BorjaIP
```

## XDG Base Directory

All configuration follows the [XDG Base Directory Specification](https://specifications.freedesktop.org/basedir/latest/), keeping `$HOME` clean.

| Directory | Path | Purpose |
| --------- | ---- | ------- |
| `XDG_CONFIG_HOME` | `~/.config` | Configuration files |
| `XDG_DATA_HOME` | `~/.local/share` | Persistent data |
| `XDG_STATE_HOME` | `~/.local/state` | Shell history, logs |
| `XDG_CACHE_HOME` | `~/.cache` | Non-essential cached data |

`~/.local/bin` is in `PATH` and is the standard location for user-installed binaries.

Environment variables are declared in `.zshenv` and organised by purpose:

| Zsh file | When it runs | What goes here |
| -------- | ------------ | -------------- |
| `.zshenv` | Always (every shell) | XDG vars, tool env vars (`KUBECONFIG`, `GOPATH`…) |
| `.zprofile` | Login shells only | `PATH`, Homebrew setup |
| `.zshrc` | Interactive shells | Aliases, plugins, prompt, `HISTFILE` |

## Manage

I use [chezmoi](https://www.chezmoi.io/) for managing my dotfiles. Follow these [instructions](https://jerrynsh.com/how-to-manage-dotfiles-with-chezmoi/) for add or changing any configuration.

I followed the instructions from [XDG_Base_Directory](https://wiki.archlinux.org/index.php/XDG_Base_Directory) for clean my dotfiles and manage config directories.

### Basic usage

```bash
# edit source file
chezmoi edit .config/zsh/.zshrc

# apply changes to your original file
chezmoi -v apply

# see diferences between tracker and local
chezmoi diff

# update new files
chezmoi git -- add .
chezmoi git -- commit -m "Update zsh config"
chezmoi git -- push
```

## Credits

- Base16 theme [Chris Kempson](https://github.com/chriskempson/base16)
- Script color [Wincent](https://github.com/wincent/wincent)
- Tmux and other configuration [Nicknisi](https://github.com/nicknisi/dotfiles)
