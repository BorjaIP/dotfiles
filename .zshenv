
# Adding path directory for custom scripts
PATH="$HOME/.local/bin${PATH:+:${PATH}}"

# Config paths
export XDG_CONFIG_HOME="$HOME"/.config
export XDG_DATA_HOME="$HOME"/.local/share
export XDG_CACHE_HOME="$HOME"/.cache
export ZDOTDIR="$HOME"/.config/zsh
export HISTFILE="$XDG_DATA_HOME"/zsh/history
export GTK2_RC_FILES="$XDG_CONFIG_HOME"/gtk-2.0/gtkrc
export MYVIMRC="$XDG_CONFIG_HOME"/nvim/init.vim
export NODE_REPL_HISTORY="$XDG_DATA_HOME"/node_repl_history
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME"/npm/npmrc

# Default programs
export EDITOR="nvim"
export GIT_EDITOR="nvim"
export GUI_EDITOR="vscodium"
export TERMINAL="alacritty"
export BROWSER="firefox"

# Others
export FZF_CTRL_R_COMMAND="-sort --exact"

# Add color to man pages
export MANROFFOPT='-c'
export LESS_TERMCAP_mb=$(tput bold; tput setaf 2)
export LESS_TERMCAP_md=$(tput bold; tput setaf 2)
export LESS_TERMCAP_so=$(tput bold; tput setaf 3)
export LESS_TERMCAP_se=$(tput rmso; tput sgr0)
export LESS_TERMCAP_us=$(tput smul; tput bold; tput setaf 1)
export LESS_TERMCAP_ue=$(tput sgr0)
export LESS_TERMCAP_me=$(tput sgr0)
