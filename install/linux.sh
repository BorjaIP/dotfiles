
# Install packages
echo -e "\\n\\nInstall packages"
echo "=============================================="
sudo apt-get update
sudo apt-get install curl wget git zsh original-awk software-properties-common nodejs npm
chsh -s /usr/bin/zsh root

# Install Python & Pip
sudo apt install python-pip
sudo apt install python3-pip

# Install Neovim
sudo add-apt-repository ppa:neovim-ppa/stable
sudo apt-get install neovim

# Install zplug
ZPLUG_HOME=~/.zplug
curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh

# After the install, install neovim python libraries
echo -e "\\n\\nRunning Neovim Python install"
echo "=============================================="
pip2 install --user neovim
pip3 install --user neovim

# Change the default shell to zsh
zsh_path="$( command -v zsh )"
if ! grep "$zsh_path" /etc/shells; then
    echo "adding $zsh_path to /etc/shells"
    echo "$zsh_path" | sudo tee -a /etc/shells
fi

if [[ "$SHELL" != "$zsh_path" ]]; then
    chsh -s "$zsh_path"
    echo "default shell changed to $zsh_path"
fi