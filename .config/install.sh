#!/usr/bin/bash

error () {
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

arch_pacman() {
    root=''
    [ $UID = 0 ] || root='sudo'

    msg "Installing packages"
    packages=( \
        neofetch
        lxapparance
        fzf
        vlc
        go
        alacritty
        neovim
        flameshot
    )

     # on a fresh install update prior to querying
    $root pacman -Syu

    to_install=()
    for pack in $packages; do
        pacman -Qq $pack > /dev/null 2>&1 || to_install+=("$pack")
    done

    if [ "${#to_install}" -gt 0 ]; then
        $root pacman -Sy $to_install
    else
        info "All official packages are installed"
    fi

}

install_aur(){
    # install yay for AUR packages
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si
    cd ..
    rm -rf yay
}

arch_aur(){
    # anything bellow needs to run unprivileged, mostly because of makepkg
    [ $UID = 0 ] && return

    msg "Installing yay"
    install_aur

    msg "Installing AUR packages"
    aur_packages=( \
        nerd-font-inconsolata
        vs-codium-bin
    )

    to_install=()
    for pack in $packages; do
        yay -Qq $pack > /dev/null 2>&1 || to_install+=("$pack")
    done

    if [ "${#to_install}" -gt 0 ]; then
        $root yay -Sy $to_install
    else
        info "All AUR packages are installed"
    fi
}

clone() {

    git clone --bare https://github.com/BorjaIP/dotfiles.git $HOME/.dotfiles

    function config {
        /usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME $@
    }

    mkdir -p .config-backup
    config checkout

    if [ $? = 0 ]; then
    msg "Checked out config"
    else
        info "Backing up pre-existing dot files"
        config checkout 2>&1 | egrep "\s+\." | awk {'print $1'} | xargs -I{} mv {} .config-backup/{}
    fi;

    config checkout
    config config status.showUntrackedFiles no
}


clone

arch_pacman
arch_aur

