#!/bin/bash

cd $HOME || return

# ------------------------------------------------------------------------------
#                            Helper functions
# ------------------------------------------------------------------------------

error() {
    printf "$(tput bold)$(tput setaf 1) -> $1$(tput sgr0)\n" >&2
}

msg() {
    printf "$(tput bold)$(tput setaf 2) $1$(tput sgr0)\n"
}

info() {
    printf "$(tput bold)$(tput setaf 4) -> $1$(tput sgr0)\n"
}

die() {
    error "$1"
    exit 1
}

# ------------------------------------------------------------------------------
#                               Functions
# ------------------------------------------------------------------------------

install_tools() {
    # Add some color to pacman
    grep "^Color" /etc/pacman.conf >/dev/null || sed -i "s/^#Color$/Color/" /etc/pacman.conf
    grep "ILoveCandy" /etc/pacman.conf >/dev/null || sed -i "/#VerbosePkgLists/a ILoveCandy" /etc/pacman.conf

    # Base16 theme
    [ -d "$HOME/.config/base16-shell" ] && info "Base16 is already installed" || ( msg "Installing base16" && git clone https://github.com/chriskempson/base16-shell.git $HOME/.config/base16-shell )

}

arch_pacman() {
    root=''
    [ $UID = 0 ] || root='sudo'

    packages=( \
    	yay
        neofetch
        fzf
        vlc
        go
        alacritty
        neovim
    )

    to_install=()
    for pack in "${packages[@]}"; do
        pacman -Qq $pack > /dev/null 2>&1 || to_install+=("$pack")
    done

    if [ "${#to_install}" -gt 0 ]; then
        msg "Installing packages"
        $root pacman --noconfirm --needed -S ${to_install[@]}
    else
        info "All official packages are installed"
    fi

}

arch_aur() {
    # Anything bellow needs to run unprivileged, mostly because of makepkg
    # [ $UID = 0 ] && return

    aur_packages=( \
        zsh-autosuggestions-git
        zsh-syntax-highlighting-git
        zsh-history-substring-search-git
        nerd-fonts-inconsolata
    )

    to_install=()
    for pack in "${aur_packages[@]}"; do
        yay -Qq $pack > /dev/null 2>&1 || to_install+=("$pack")
    done

    if [ "${#to_install}" -gt 0 ]; then
        msg "Installing AUR packages"
        yay --noconfirm --needed -S ${to_install[@]}
    else
        info "All AUR packages are installed"
    fi
}

# Install resources/tools and other config files
# install_tools

# Install packages
# arch_pacman
arch_aur

# Update the system
#update
