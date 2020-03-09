#!/usr/bin/env bash

command_exists() {
    type "$1" > /dev/null 2>&1
}

echo "=============================================="
echo "              Installing dotfiles "
echo "=============================================="

# Only perform macOS-specific install
if [ "$(uname)" == "Darwin" ]; then
    echo -e "\\n\\nRunning on OSX"

    # Install programs with brew
    source install/brew.sh

    # Setup OS X settings
    source install/osx.sh

    # Install fonts
    cp $HOME./dotfiles/fonts/*.otf $HOME/Library/Fonts
fi

# Create symbolic links
source install/link.sh

# Options for git configuration
source install/git.sh

# ZSH configuration
source install/zsh.sh

# Plugins and extra configuration
source install/extra.sh

echo -e "\\n\\nDone. Reload your terminal.\\n\\n"
