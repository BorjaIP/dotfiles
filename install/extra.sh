#!/usr/bin/env bash

# Setup fzf
if [ ! -d "/usr/local/opt/fzf" ]; then
    echo -e "\\n\\nRunning fzf install script"
    echo "=============================================="
    /usr/local/opt/fzf/install
else
    echo -e "\\n\\nFZF is already installed"
fi

# Install neovim on python libraries
if [[ -z $(pip3 show neovim) ]]; then
    echo -e "\\n\\nInstalling Neovim on Python"
    echo "=============================================="
    pip3 install --user neovim
else
    echo -e "\\n\\nNeovim is already installed"
fi

# Install Base16 Theme
if [ ! -d "$HOME/.config/base16-shell" ]; then
    echo -e "\\n\\nDownloading base16 theme"
    echo "=============================================="
    git clone https://github.com/chriskempson/base16-shell.git ~/.config/base16-shell
else
    echo -e "\\n\\nBase16 theme is already installed"
fi

# Install vim-plug for plugins on vim
if [ ! -d "$HOME/.local/share/nvim/site/autoload" ]; then
    echo -e "\\n\\nDownloading vim-plug"
    echo "=============================================="
    curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
else
    echo -e "\\n\\nVim-plug is already installed"
fi

# Install Tmux ressurect
if [ ! -d "$HOME/.dotfiles/tmux/tmux_resurrect" ]; then
    echo -e "\\n\\nDownloading tmux-resurrect"
    echo "=============================================="
    git clone https://github.com/tmux-plugins/tmux-resurrect ~/.dotfiles/tmux/tmux_resurrect/
else
    echo -e "\\n\\nTmux-ressurect is already installed"
fi

