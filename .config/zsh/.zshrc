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
#                            CONFIG                            #
#                                                              #
################################################################

# Add colors for tmux and term
export TERM=xterm-256color

setopt NO_BG_NICE
setopt NO_HUP
setopt NO_LIST_BEEP
setopt LOCAL_OPTIONS
setopt LOCAL_TRAPS
setopt PROMPT_SUBST

# History file configuration
HISTFILE="$HISTFILE"
HISTSIZE=10000
SAVEHIST=10000

# History
setopt HIST_VERIFY
setopt EXTENDED_HISTORY
setopt HIST_REDUCE_BLANKS
setopt SHARE_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt INC_APPEND_HISTORY
setopt APPEND_HISTORY

# Aliases
setopt COMPLETE_ALIASES

# Add ZSH configuration
for config ($ZDOTDIR/**) source $config

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

# Base16 shell setup
BASE16_SHELL="$HOME/.config/base16-shell/"
[ -n "$PS1" ] && \
    [ -s "$BASE16_SHELL/profile_helper.sh" ] && \
    eval "$("$BASE16_SHELL/profile_helper.sh")"

# Configure fzf
source /usr/share/fzf/key-bindings.zsh
source /usr/share/fzf/completion.zsh

################################################################
#                                                              #
#                          PLUGINS                             #
#                                                              #
################################################################

# Autosuggestion
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

# Use syntax highlighting
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Use history substring search
source /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh

