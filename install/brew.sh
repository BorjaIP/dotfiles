#!/usr/bin/env bash

# Install Homebrew
if test ! "$( command -v brew )"; then
    echo -e "\\n\\nInstalling homebrew"
    echo "=============================================="
    ruby -e "$( curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install )"
else
    echo -e "\\n\\nHomebrew is already installed"
fi


echo -e "\\n\\nInstalling homebrew packages..."
echo "=============================================="
brew bundle --file=$HOME/.dotfiles/Brewfile

