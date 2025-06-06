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
#                           Common Functions
# ------------------------------------------------------------------------------

install_tools() {
    msg "Installing common tools"
    # Base16 theme
    [ -d "$HOME/.config/base16-shell" ] && info "Base16 is already installed" || ( msg "Installing base16" && git clone https://github.com/chriskempson/base16-shell.git $HOME/.config/base16-shell )
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

# ------------------------------------------------------------------------------
#                           Arch Linux Functions
# ------------------------------------------------------------------------------

arch_check_paru() {
    # Installing AUR package manager
    if ! command -v paru &> /dev/null; then
        msg "Installing paru (AUR helper)"
        cd /tmp || exit
        git clone https://aur.archlinux.org/paru.git
        cd paru || exit
        makepkg -si --noconfirm
        cd - || exit
        rm -rf /tmp/paru
    else
        info "Paru is already installed"
    fi
}    

# ------------------------------------------------------------------------------
#                              Main Logic
# ------------------------------------------------------------------------------

# Verify OS support first
verify_supported_os

# Install common tools
install_tools

# Basic OS-specific setup (before file copying)
case $(detect_os) in
    "macos")
        msg "Basic macOS setup"
        macos_check_homebrew
        info "Homebrew setup completed. Package installation will happen after file copying."
        ;;
    "arch")
        msg "Basic Arch Linux setup"
        arch_check_paru
        info "Arch package installation will happen after file copying."
        ;;
esac

msg "Basic setup completed successfully!" 