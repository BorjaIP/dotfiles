#!/usr/bin/env bash

command_exists() {
    type "$1" > /dev/null 2>&1
}

echo "=============================================="
echo "              Installing dotfiles"
echo "=============================================="

source install/link.sh

source install/git.sh

# Only perform macOS-specific install
if [ "$(uname)" == "Darwin" ]; then
    echo -e "\\n\\nRunning on OSX"

    source install/brew.sh

    source install/osx.sh
fi

echo "=============================================="
echo "           Creating vim directories"
echo "=============================================="

if ! command_exists zsh; then
    echo "zsh not found. Please install and then re-run installation scripts"
    exit 1
elif ! [[ $SHELL =~ .*zsh.* ]]; then
    echo "Configuring zsh as default shell"
    chsh -s "$(command -v zsh)"
fi

echo "Done. Reload your terminal."
