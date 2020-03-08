# Base16 Styling Guidelines:
# base00 - Default Background
# base01 - Lighter Background (Used for status bars)
# base02 - Selection Background
# base03 - Comments, Invisibles, Line Highlighting
# base04 - Dark Foreground (Used for status bars)
# base05 - Default Foreground, Caret, Delimiters, Operators
# base06 - Light Foreground (Not often used)
# base07 - Light Background (Not often used)
# base08 - Variables, XML Tags, Markup Link Text, Markup Lists, Diff Deleted
# base09 - Integers, Boolean, Constants, XML Attributes, Markup Link Url
# base0A - Classes, Markup Bold, Search Text Background
# base0B - Strings, Inherited Class, Markup Code, Diff Inserted
# base0C - Support, Regular Expressions, Escape Characters, Markup Quotes
# base0D - Functions, Methods, Attribute IDs, Headings
# base0E - Keywords, Storage, Selector, Markup Italic, Diff Changed

base00=default  # #000000
base01=colour18 # #282828
base02=colour19 # #383838
base03=colour8  # #585858
base04=colour20 # #B8B8B8
base05=colour7  # #D8D8D8
base06=colour21 # #E8E8E8
base07=colour15 # #F8F8F8
base08=colour01 # #AB4642
base09=colour16 # #DC9656
base0A=colour3  # #F7CA88
base0B=colour2  # #A1B56C
base0C=colour6  # #86C1B9
base0D=colour4  # #7CAFC2
base0E=colour5  # #BA8BAF
base0F=colour17 # #A16946

set -g status-left-length 32
set -g status-right-length 150
set -g status-interval 5

# Default statusbar colors
set-option -g status-style bg=$base01
set-option -g status-style fg=$base03
set-option -g status default

# Active window title colors
set-window-option -g window-status-style bg=$base01
set-window-option -g window-status-style fg=$base06
set -g window-status-format " #I #W"

# Background window title colors
set-window-option -g window-status-current-style bg=$base0C
set-window-option -g window-status-current-style fg=$base03

# Show only name in windows
set-window-option -g  window-status-current-format " #[bold]#W "

# Pane border colors
set-window-option -g pane-active-border-style fg=$base0C
set-window-option -g pane-border-style fg=$base03

# Message text
set-option -g message-style bg=$base00
set-option -g message-style fg=$base0C

# Pane number display
set-option -g display-panes-active-colour $base0C
set-option -g display-panes-colour $base01

# Clock
set-window-option -g clock-mode-colour $base0C

tm_session_name="#[default,bg=$base0C,fg=$base01] ❐ #S "
set -g status-left "$tm_session_name"

tm_tunes="#[bg=$base0D,fg=$base01] ♫ #(osascript -l JavaScript ~/.dotfiles/scripts/tunes.js)"
tm_battery="#[bg=$base08,fg=$base01] ⚡︎#(battery)"
tm_date="#[default,bg=$base0A,fg=$base01] %a %d-%h"
tm_hour="#[default,bg=$base02,fg=$base05] %I:%M%p"
tm_host="#[bg=$base0E,fg=$base01] #[bold]#h"
set -g status-right "$tm_tunes $tm_battery $tm_date $tm_hour $tm_host "
