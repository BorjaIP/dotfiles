################################################################
#                                                              #
#                           ALIASES                            #
#                                                              #
################################################################

# System custom
alias lock='/System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend'
alias reboot='sudo shutdown -r now'
alias b="sudo brew"
alias clean="brew cleanup && brew cask cleanup"
alias update="brew cu -facy"

# vim
alias vi="nvim"
alias vim="nvim"

# Shortcuts folders
alias dev="cd Dev"
alias uni="cd Documents/Universidad"

# Aplications
alias python='python2.7'
alias pdf='zathura'

# Detect which `ls` flavor is in use
if ls --color > /dev/null 2>&1; then # GNU `ls`
    colorflag="--color"
else # macOS `ls`
    colorflag="-G"
fi

# Commands files
alias ..='cd ..'
alias ls="ls ${colorflag}"
alias l="ls -lah ${colorflag}"
alias la="ls -AF ${colorflag}"
alias ll="ls -lFh ${colorflag}"
alias rf="rm -rf"

# IP Adress
alias ips="ifconfig -a | perl -nle'/(\d+\.\d+\.\d+\.\d+)/ && print $1'"

# reload zsh config
alias reload!='RELOAD=1 source ~/.zshrc'

# Tmux aliases
alias ta='tmux attach'
alias tls='tmux ls'
alias tat='tmux attach -t'
alias tns='tmux new-session -s'

# File size
alias fs="stat -f \"%z bytes\""
