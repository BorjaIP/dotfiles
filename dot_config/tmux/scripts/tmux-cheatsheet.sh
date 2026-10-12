#!/usr/bin/env bash
# tmux-cheatsheet.sh
# Interactive keybinding viewer styled with base16 colors

set -euo pipefail

# ── ANSI colors matching ~/.config/tmux/theme.conf ──
C_TABLE='\033[38;5;110m'   # base0D #7CAFC2 (blue)
C_KEY='\033[38;5;139m'     # base0E #BA8BAF (magenta)
C_CMD='\033[38;5;188m'     # base05 #D8D8D8 (fg)
C_DIM='\033[38;5;240m'     # base03 #585858 (dim)
C_REPEAT='\033[38;5;215m'  # base0A #F7CA88 (yellow)
C_RESET='\033[0m'

# ── Parse tmux list-keys into aligned colored rows ──
keys=$(tmux list-keys | awk -v ct="$C_TABLE" -v ck="$C_KEY" -v cc="$C_CMD" \
  -v cd="$C_DIM" -v cr="$C_REPEAT" -v rs="$C_RESET" '
{
    repeat = 0
    table  = "prefix"
    key    = ""
    cmd_start = 0

    for (i = 2; i <= NF; i++) {
        if ($i == "-T") { i++; table = $i; continue }
        if ($i == "-r") { repeat = 1; continue }
        if ($i == "-n") { table = "root"; continue }
        if (key == "")  { key = $i; cmd_start = i + 1; break }
    }

    # rebuild command
    cmd = ""
    for (i = cmd_start; i <= NF; i++) cmd = cmd (i == cmd_start ? "" : " ") $i
    if (cmd == "") cmd = cd "—" rs
    if (length(cmd) > 55) cmd = substr(cmd, 1, 52) cd "..." rs

    rep = repeat ? cr "↻" rs " " : "  "

    printf "%s%-14s%s  %s%-18s%s  %s%s%s\n",
        ct, "[" table "]", rs,
        ck, key, rs,
        rep, cc, cmd
}
' | sort)

total=$(echo "$keys" | wc -l)

# ── Launch fzf inside tmux popup ──
echo "$keys" | fzf \
  --ansi \
  --prompt='  Tmux Keys > ' \
  --header="  $total bindings  │  ESC or q to close" \
  --color='fg:#D8D8D8,fg+:#F8F8F8,bg:-1,bg+:#282828,hl:#A1B56C,hl+:#A1B56C,pointer:#BA8BAF,marker:#A1B56C,info:#86C1B9,prompt:#7CAFC2,header:#AB4642,border:#585858,label:#585858' \
  --layout=reverse \
  --border=rounded \
  --border-label='  Tmux Shortcuts  ' \
  --no-preview \
  --info=inline-right \
  --height=100% \
  || true
