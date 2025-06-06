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
        "linux-unknown")
            die "Unsupported Linux distribution. Only Arch Linux is supported at this moment."
            ;;
        "unknown")
            die "Unsupported operating system. Only macOS and Arch Linux are supported."
            ;;
    esac
}

# ------------------------------------------------------------------------------
#                           Common Functions
# ------------------------------------------------------------------------------

install_tools() {
    # Base16 theme
    [ -d "$HOME/.config/base16-shell" ] && info "Base16 is already installed" || ( msg "Installing base16" && git clone https://github.com/chriskempson/base16-shell.git $HOME/.config/base16-shell )
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

# ------------------------------------------------------------------------------
#                             macOS Functions
# ------------------------------------------------------------------------------

macos_check_homebrew() {
    if ! command -v brew &> /dev/null; then
        msg "Installing Homebrew"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # Add Homebrew to PATH for Apple Silicon Macs
        if [[ $(uname -m) == "arm64" ]]; then
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
            eval "$(/opt/homebrew/bin/brew shellenv)"
        else
            echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zprofile
            eval "$(/usr/local/bin/brew shellenv)"
        fi
    else
        info "Homebrew is already installed"
    fi
}

macos_brew_packages() {
    macos_check_homebrew

    local brewfile_path="$HOME/.config/brew/Brewfile"
    
    if [ -f "$brewfile_path" ]; then
        msg "Installing packages from Brewfile"
        brew bundle install --file="$brewfile_path"
    else
        error "Brewfile not found at $brewfile_path"
        info "Installing basic packages manually"
      fi
}

# ------------------------------------------------------------------------------
#                              Main Logic
# ------------------------------------------------------------------------------

# Verify OS support first
verify_supported_os

# Install common tools
install_tools

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

msg "Installation completed successfully!"
