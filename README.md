# ☄️ Dotfiles 🖥

Each line of configuration is simple, stripping away the unnecessary to leave only what matters. Minimalistic and essential, these dotfiles are without using too many plugins/frameworks in all the tools and try to make it simple. It's not about adding more; it's about needing less.

## Manage

I use [chezmoi](https://www.chezmoi.io/) for managing my dotfiles. Follow these [instructions](https://jerrynsh.com/how-to-manage-dotfiles-with-chezmoi/) for add or changing any configuration.

I followed the instructions from [XDG_Base_Directory](https://wiki.archlinux.org/index.php/XDG_Base_Directory) for clean my dotfiles and manage config directories.

## Contents
<!-- https://github.com/inttter/md-badges -->

[![Zsh](https://img.shields.io/badge/Zsh-F15A24?style=for-the-badge&logo=zsh&logoColor=fff)](#) [![Neovim](https://img.shields.io/badge/Neovim-57A143?style=for-the-badge&logo=neovim&logoColor=fff)](#) [![Vim](https://img.shields.io/badge/Vim-%2311AB00.svg?style=for-the-badge&logo=vim&logoColor=white)](#) [![tmux](https://img.shields.io/badge/tmux-1BB91F?style=for-the-badge&logo=tmux&logoColor=fff)](#) [![Visual Studio Code](https://custom-icon-badges.demolab.com/badge/Visual%20Studio%20Code-0078d7.svg?style=for-the-badge&logo=vsc&logoColor=white)](#)

This config repo is designed for any Linux Distribution, I personally use Arch Linux. 

- [ZSH](https://wiki.archlinux.org/index.php/Zsh) as Shell.
- [Neovim](https://wiki.archlinux.org/index.php/Neovim) as Editor.
- [Tmux](https://wiki.archlinux.org/index.php/Tmux) as Terminal Multiplexer.

## Installation

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply BorjaIP
```

## Credits

- ZSH inspiration [Pure](https://github.com/sindresorhus/pure)
- Base16 theme [Chris Kempson](https://github.com/chriskempson/base16)
- Script color [Wincent](https://github.com/wincent/wincent)
- Tmux and other configuration [Nicknisi](https://github.com/nicknisi/dotfiles)
