#!/bin/sh

# Variables
dotfiles_dir="$HOME/.dotfiles"
backup_dir="$HOME/.dotfiles-backup"

#### Helper functions ####

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

#### FUNCTIONS ####

clone() {

    # Check if $dotfiles_dir exists.
    [ -d "$dotfiles_dir" ] && info "Directory $dotfiles_dir exists" || ( msg "Clone directory" && git clone --bare https://github.com/BorjaIP/dotfiles.git $dotfiles_dir )    

    # Create config command to pull the repository
    function config {
        /usr/bin/git --git-dir=$dotfiles_dir --work-tree=$HOME $@
    }

    # Enable the sparseCheckout option 
    config config core.sparseCheckout true

    # Create the file for ignore README.md
    echo -e "/*\n!README.md" >> $dotfiles_dir/info/sparse-checkout
    
    # Omit pager results
    config config pager.branch false
    
    # Create folder backup
    [ -d "$backup_dir" ] && info "Directory $backup_dir exists" || mkdir -p "$backup_dir"
    
    if config checkout; then
        info "Checked out config"
    else
        msg "Backing up pre-existing dot files"
	# For diff use --> config --no-pager diff --name-only master 2>&1
	for f in $(config checkout 2>&1 | egrep "\s+\." | awk {'print $1'}); do
	      target="$backup_dir/$f"
	      d=$(dirname "$target")
	      [ -d "$d" ] || mkdir -p "$d" 
	      mv "$f" "$target"
	done
    fi

    config checkout || die "Failed to checkout files"
    #config submodule init
    #config submodule update --init --recursive 
    config config --local status.showUntrackedFiles no
    config config pager.branch true
}

resources() {
    # Base16 theme
    [ -d "$HOME/.config/base16-shell" ] && info "Base16 is already installed" || ( msg "Installing base16" && git clone https://github.com/chriskempson/base16-shell.git $HOME/.config/base16-shell )
}

arch_pacman() {
    root=''
    [ $UID = 0 ] || root='sudo'

    packages=( \
        neofetch
        fzf
        vlc
        go
        alacritty
        neovim
        flameshot
    )

    to_install=()
    for pack in $packages; do
        pacman -Qq $pack > /dev/null 2>&1 || to_install+=("$pack")
    done

    if [ "${#to_install}" -gt 0 ]; then
        msg "Installing packages"
        $root pacman --noconfirm --needed -S $to_install
    else
        info "All official packages are installed"
    fi

}

install_aur() {
    # Install yay for AUR packages
    git clone https://aur.archlinux.org/yay.git
    cd yay && makepkg -si --noconfirm && cd .. && rm -rf yay
}

arch_aur() {
    # Anything bellow needs to run unprivileged, mostly because of makepkg
    [ $UID = 0 ] && return
    
    if ! [ -x "$(command -v yay)" ]; then
        msg "Installing yay"
        install_aur
    else 
        info "Yay is installed"
    fi
    
    aur_packages=( \
        nerd-font-inconsolata
        vs-codium-bin
    )

    to_install=()
    for pack in $packages; do
        yay -Qq $pack > /dev/null 2>&1 || to_install+=("$pack")
    done

    if [ "${#to_install}" -gt 0 ]; then
        msg "Installing AUR packages"
        $root yay --noconfirm --needed -S $to_install
    else
        info "All AUR packages are installed"
    fi
}

update() {
    root=''
    [ $UID = 0 ] || root='sudo'
    
    # Update pacman
    $root pacman -Syu --noconfirm && $root pacman -Syyu --noconfirm && $root pacman -Syyuw --noconfirm
    
    # Update yay
    yay -Syu --noconfirm && yay -Syyu --noconfirm 
}

finalize() {
    msg "All done!"
    exit
}

# First clone the repository
clone

# Install resources and other config files
resources

# Install packages
arch_pacman
arch_aur

# Close 
finalize