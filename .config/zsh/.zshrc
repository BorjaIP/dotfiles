#
# 
#                      ███████╗███████╗██╗  ██╗
#                      ╚══███╔╝██╔════╝██║  ██║
#                        ███╔╝ ███████╗███████║
#                       ███╔╝  ╚════██║██╔══██║
#                      ███████╗███████║██║  ██║
#                      ╚══════╝╚══════╝╚═╝  ╚═╝


################################################################
#                                                              #
#                            EXPORTS                           #
#                                                              #
################################################################


# Adding path directory for custom scripts
#export PATH=$DOTFILES/bin:$PATH

# Add colors for tmux and term
if [ -z "$TMUX" ]; then
    export TERM=xterm-256color
else

    export TERM=screen-256color
fi

# Add color to man pages
export MANROFFOPT='-c'
export LESS_TERMCAP_mb=$(tput bold; tput setaf 2)
export LESS_TERMCAP_md=$(tput bold; tput setaf 6)
export LESS_TERMCAP_me=$(tput sgr0)
export LESS_TERMCAP_so=$(tput bold; tput setaf 3; tput setab 4)
export LESS_TERMCAP_se=$(tput rmso; tput sgr0)
export LESS_TERMCAP_us=$(tput smul; tput bold; tput setaf 7)
export LESS_TERMCAP_ue=$(tput rmul; tput sgr0)
export LESS_TERMCAP_mr=$(tput rev)
export LESS_TERMCAP_mh=$(tput dim)


################################################################
#                                                              #
#                          PLUGINS                             #
#                                                              #
################################################################

# Use syntax highlighting
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Use history substring search
source /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh

# Add ZSH configuration
for config ($ZDOTDIR/**) source $config
#[ -f "$ZDOTDIR/aliases" ] && source "$ZDOTDIR/aliases"
#[ -f "$ZDOTDIR/colors" ] && source "$ZDOTDIR/colors"
#[ -f "$ZDOTDIR/config" ] && source "$ZDOTDIR/config"
#[ -f "$ZDOTDIR/prompt" ] && source "$ZDOTDIR/prompt"

# Initialize autocomplete
autoload -U compinit add-zsh-hook && compinit
compinit -d $XDG_CACHE_HOME/zsh/zcompdump-$ZSH_VERSION

# Matches case insensitive for lowercase
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# Pasting with tabs doesn't perform completion
zstyle ':completion:*' insert-tab pending	

# Default to file completion
zstyle ':completion:*' completer _expand _complete _files _correct _approximate

# Highlight on tab
zstyle ':completion:*' menu select


################################################################
#                                                              #
#                        FZF/BASE16                            #
#                                                              #
################################################################

# Base16 shell setup
BASE16_SHELL="$HOME/.config/base16-shell/"
[ -n "$PS1" ] && \
    [ -s "$BASE16_SHELL/profile_helper.sh" ] && \
    eval "$("$BASE16_SHELL/profile_helper.sh")"


# Configure fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
# Use ripgrep for recursively searches directories for a regex pattern 
export FZF_DEFAULT_COMMAND='rg --files --no-ignore --hidden --follow -g "!{.git,node_modules}/*" 2> /dev/null'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

