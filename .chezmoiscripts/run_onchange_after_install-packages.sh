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
#                         OS Detection Functions
# ------------------------------------------------------------------------------

detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if [ -f /etc/arch-release ]; then
            echo "arch"
        else
            echo "linux-unknown"
        fi
    else
        echo "unknown"
    fi
}

verify_supported_os() {
    local os=$(detect_os)
    case $os in
        "macos")
            info "Detected macOS - supported"
            return 0
            ;;
        "arch")
            info "Detected Arch Linux - supported"
            return 0
            ;;
        "unknown")
            die "Unsupported operating system. Only macOS and Arch Linux are supported."
            ;;
    esac
}

# ------------------------------------------------------------------------------
#                             macOS Functions
# ------------------------------------------------------------------------------

macos_brew_packages() {
    # local brewfile_path="$HOME/.config/brew/Brewfile"
    local brewfile_path="$HOME/.local/share/chezmoi/dot_config/brew/Brewfile"
    brew update
    
    if [ -f "$brewfile_path" ]; then
        msg "Installing packages from Brewfile"
        brew bundle install --file="$brewfile_path"
        info "Brewfile installation completed"
    else
        error "Brewfile not found at $brewfile_path"
        die "Cannot proceed without Brewfile. Please ensure chezmoi has copied all files."
    fi
}

# ------------------------------------------------------------------------------
#                           Arch Linux Functions
# ------------------------------------------------------------------------------

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

# ------------------------------------------------------------------------------
#                              Main Logic
# ------------------------------------------------------------------------------

# Verify OS support first
verify_supported_os

# Install OS-specific packages
case $(detect_os) in
    "macos")
        msg "Setting up macOS environment"
        macos_brew_packages
        ;;
    "arch")
        msg "Setting up Arch Linux environment"
        arch_pacman
        arch_aur
        ;;
esac

msg "Package installation completed successfully!" 