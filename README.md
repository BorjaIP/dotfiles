# ☄️ Dotfiles 🖥

Every line of config is simple—just what’s needed, nothing more. These dotfiles are minimal and essential, avoiding heavy plugins or bloated frameworks across all tools. It’s not about adding more, it’s about needing less.

![terminal](https://github.com/user-attachments/assets/16a1f8c7-5fcc-41eb-be54-10279750adc4)

![vscode](https://github.com/user-attachments/assets/f8a44e04-230a-4c6d-afbc-6a7ceb3d8c8f)

## Features
<!-- https://github.com/inttter/md-badges -->

[![Zsh](https://img.shields.io/badge/Zsh-F15A24?style=for-the-badge&logo=zsh&logoColor=fff)](#) [![Neovim](https://img.shields.io/badge/Neovim-57A143?style=for-the-badge&logo=neovim&logoColor=fff)](#) [![Vim](https://img.shields.io/badge/Vim-%2311AB00.svg?style=for-the-badge&logo=vim&logoColor=white)](#) [![tmux](https://img.shields.io/badge/tmux-1BB91F?style=for-the-badge&logo=tmux&logoColor=fff)](#) [![Visual Studio Code](https://custom-icon-badges.demolab.com/badge/Visual%20Studio%20Code-0078d7.svg?style=for-the-badge&logo=vsc&logoColor=white)](#)

This config repo is designed for any Linux Distribution, I personally use Arch Linux. 

- [ZSH](https://wiki.archlinux.org/index.php/Zsh) as Shell.
- [Neovim](https://wiki.archlinux.org/index.php/Neovim) as Editor.
- [Tmux](https://wiki.archlinux.org/index.php/Tmux) as Terminal Multiplexer.

## Installation

>[!important]
> 
> Only compatible currently with `Arch Linux`

This command will install software and apply all the configurations in `~/.local/share/chezmoi`.

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply BorjaIP
```

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

- ZSH inspiration [Pure](https://github.com/sindresorhus/pure)
- Base16 theme [Chris Kempson](https://github.com/chriskempson/base16)
- Script color [Wincent](https://github.com/wincent/wincent)
- Tmux and other configuration [Nicknisi](https://github.com/nicknisi/dotfiles)
