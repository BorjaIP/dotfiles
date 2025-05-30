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
    # Base16 theme
    [ -d "$HOME/.config/base16-shell" ] && info "Base16 is already installed" || ( msg "Installing base16" && git clone https://github.com/chriskempson/base16-shell.git $HOME/.config/base16-shell )
}

arch_pacman() {
    # Add some color to pacman
    grep "^Color" /etc/pacman.conf >/dev/null || sed -i "s/^#Color$/Color/" /etc/pacman.conf
    grep "ILoveCandy" /etc/pacman.conf >/dev/null || sed -i "/#VerbosePkgLists/a ILoveCandy" /etc/pacman.conf

    root=''
    [ $UID = 0 ] || root='sudo'

    packages=( \
        base-devel
        neofetch
        git
        fzf
        go
        vi
        vim
        zsh
        bat
        tealdeer
        neovim
        docker
        docker-compose
        python
        python-pip
        ttf-inconsolata-nerd
    )

    to_install=()
    for pack in "${packages[@]}"; do
        pacman -Qq "$pack" > /dev/null 2>&1 || to_install+=("$pack")
    done

    if [ "${#to_install}" -gt 0 ]; then
        msg "Installing packages"
        $root pacman --noconfirm --needed --noprogressbar -S "${to_install[@]}"
    else
        info "All official packages are installed"
    fi

}


arch_aur() {
    # Anything bellow needs to run unprivileged, mostly because of makepkg
    # [ $UID = 0 ] && return

    # Installing AUR package manager
    if ! command -v paru &> /dev/null
    then
        cd /tmp || exit
        git clone https://aur.archlinux.org/paru.git
        cd paru || exit
        makepkg -si --noconfirm
        cd .. && rm -rf /tmp/paru
    fi

    aur_packages=( \
        zsh-autosuggestions-git
        zsh-syntax-highlighting-git
        zsh-history-substring-search-git
        kubectl
        tmux
    )

    to_install=()
    for pack in "${aur_packages[@]}"; do
        paru -Qq "$pack" > /dev/null 2>&1 || to_install+=("$pack")
    done

    if [ "${#to_install}" -gt 0 ]; then
        msg "Installing AUR packages"
        paru --noconfirm --needed --noprogressbar -S "${to_install[@]}"
    else
        info "All AUR packages are installed"
    fi
}

# Install resources/tools and other config files
install_tools

# Install packages
arch_pacman
arch_aur
