#!/bin/sh

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
        flameshot
	lxappearance
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
