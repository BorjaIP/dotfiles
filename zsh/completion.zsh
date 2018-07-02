# Matches case insensitive for lowercase
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# Pasting with tabs doesn't perform completion
zstyle ':completion:*' insert-tab pending

# Default to file completion
zstyle ':completion:*' completer _expand _complete _files _correct _approximate

# Highlight on tab
zstyle ':completion:*' menu select
