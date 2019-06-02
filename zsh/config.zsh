################################################################
#                                                              #
#                            CONFIG                            #
#                                                              #
################################################################

setopt NO_BG_NICE
setopt NO_HUP
setopt NO_LIST_BEEP
setopt LOCAL_OPTIONS
setopt LOCAL_TRAPS
setopt PROMPT_SUBST

HISTFILE=~/.zsh_history
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

setopt COMPLETE_ALIASES

fpath=($ZSH/functions $fpath)
autoload -U $ZSH/functions/*(:t)
