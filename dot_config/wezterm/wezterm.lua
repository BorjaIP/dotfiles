local wezterm = require 'wezterm'
local config = wezterm.config_builder()

-- Window geometry
config.initial_cols = 180
config.initial_rows = 48

-- Allow left Option key to compose special characters (ñ, etc.)
config.send_composed_key_when_left_alt_is_pressed = true

-- ================================================================
--  LEADER KEY: Cmd+A (replaces Alt+A as tmux prefix alias)
--  After pressing Cmd+A, you have 1 second to press the next key
-- ================================================================
config.leader = { key = "a", mods = "CMD", timeout_milliseconds = 1000 }

config.keys = {

  -- ── WEZTERM ────────────────────────────────────────────
  -- Cmd+Shift+W → close WezTerm window
  { key = "w", mods = "CMD|SHIFT", action = wezterm.action.CloseCurrentTab { confirm = true } },

  -- Cmd+/ → show shortcuts cheatsheet
  { key = "/", mods = "CMD", action = wezterm.action.EmitEvent 'show-cheatsheet' },

  -- ── LEADER (Cmd+A) → tmux commands ────────────────────
  -- These mirror your Alt+A prefix bindings exactly
  { key = "c", mods = "LEADER",       action = wezterm.action.SendString("\x1bac") }, -- new window
  { key = "x", mods = "LEADER",       action = wezterm.action.SendString("\x1bax") }, -- kill pane
  { key = "|", mods = "LEADER",       action = wezterm.action.SendString("\x1ba|") }, -- vertical split
  { key = "-", mods = "LEADER",       action = wezterm.action.SendString("\x1ba-") }, -- horizontal split
  { key = "h", mods = "LEADER",       action = wezterm.action.SendString("\x1bah") }, -- pane left
  { key = "j", mods = "LEADER",       action = wezterm.action.SendString("\x1baj") }, -- pane down
  { key = "k", mods = "LEADER",       action = wezterm.action.SendString("\x1bak") }, -- pane up
  { key = "l", mods = "LEADER",       action = wezterm.action.SendString("\x1bal") }, -- pane right
  { key = "h", mods = "LEADER|SHIFT", action = wezterm.action.SendString("\x1bap") },
  { key = "l", mods = "LEADER|SHIFT", action = wezterm.action.SendString("\x1ban") },
  { key = "z", mods = "LEADER",       action = wezterm.action.SendString("\x1baz") }, -- zoom pane
  { key = ",", mods = "LEADER",       action = wezterm.action.SendString("\x1ba,") }, -- rename window
  { key = "r", mods = "LEADER",       action = wezterm.action.SendString("\x1bar") }, -- reload config
  { key = "x", mods = "LEADER",       action = wezterm.action.SendString("\x1bax") }, -- kill pane
  { key = "y", mods = "LEADER",       action = wezterm.action.SendString("\x1bay") }, -- sync panes
  { key = "1", mods = "LEADER",       action = wezterm.action.SendString("\x1ba1") },
  { key = "2", mods = "LEADER",       action = wezterm.action.SendString("\x1ba2") },
  { key = "3", mods = "LEADER",       action = wezterm.action.SendString("\x1ba3") },
  { key = "4", mods = "LEADER",       action = wezterm.action.SendString("\x1ba4") },
  { key = "5", mods = "LEADER",       action = wezterm.action.SendString("\x1ba5") },
  { key = "6", mods = "LEADER",       action = wezterm.action.SendString("\x1ba6") },
  { key = "7", mods = "LEADER",       action = wezterm.action.SendString("\x1ba7") },
  { key = "8", mods = "LEADER",       action = wezterm.action.SendString("\x1ba8") },
  { key = "9", mods = "LEADER",       action = wezterm.action.SendString("\x1ba9") },

  -- ── TMUX — WINDOWS ────────────────────────────────────
  -- Cmd+T → new tmux window  (prefix + c)
  { key = "t", mods = "CMD", action = wezterm.action.SendString("\x1bac") },

  -- Cmd+W → close current pane  (prefix + x)
  { key = "w", mods = "CMD", action = wezterm.action.SendString("\x1bax") },

  -- Cmd+1..9 → switch to window N  (prefix + N)
  { key = "1", mods = "CMD", action = wezterm.action.SendString("\x1ba1") },
  { key = "2", mods = "CMD", action = wezterm.action.SendString("\x1ba2") },
  { key = "3", mods = "CMD", action = wezterm.action.SendString("\x1ba3") },
  { key = "4", mods = "CMD", action = wezterm.action.SendString("\x1ba4") },
  { key = "5", mods = "CMD", action = wezterm.action.SendString("\x1ba5") },
  { key = "6", mods = "CMD", action = wezterm.action.SendString("\x1ba6") },
  { key = "7", mods = "CMD", action = wezterm.action.SendString("\x1ba7") },
  { key = "8", mods = "CMD", action = wezterm.action.SendString("\x1ba8") },
  { key = "9", mods = "CMD", action = wezterm.action.SendString("\x1ba9") },

  -- Cmd+[ / Cmd+] → previous/next window  (Alt+H / Alt+L)
  { key = "h", mods = "CMD", action = wezterm.action.SendString("\x1bap") },
  { key = "l", mods = "CMD", action = wezterm.action.SendString("\x1ban") },

  -- ── TMUX — SPLITS ─────────────────────────────────────
  -- Cmd+D → vertical split  (prefix + |)
  { key = "d", mods = "CMD", action = wezterm.action.SendString("\x1ba|") },

  -- Cmd+Shift+D → horizontal split  (prefix + -)
  { key = "d", mods = "CMD|SHIFT", action = wezterm.action.SendString("\x1ba-") },

  -- ── TMUX — PANE NAVIGATION ────────────────────────────
  -- Cmd+Shift+H/J/K/L → move between panes  (prefix + h/j/k/l)
  { key = "h", mods = "CMD|SHIFT", action = wezterm.action.SendString("\x1bah") },
  { key = "j", mods = "CMD|SHIFT", action = wezterm.action.SendString("\x1baj") },
  { key = "k", mods = "CMD|SHIFT", action = wezterm.action.SendString("\x1bak") },
  { key = "l", mods = "CMD|SHIFT", action = wezterm.action.SendString("\x1bal") },

  -- ── TMUX — OTHER ──────────────────────────────────────
  -- Cmd+Z → toggle pane zoom  (prefix + z)
  { key = "z", mods = "CMD", action = wezterm.action.SendString("\x1baz") },

  -- Cmd+, → rename current window  (prefix + ,)
  { key = ",", mods = "CMD", action = wezterm.action.SendString("\x1ba,") },

  -- Cmd+R → reload tmux config  (prefix + r)
  { key = "r", mods = "CMD", action = wezterm.action.SendString("\x1bar") },

  -- ── TEXT SELECTION (Mac style) ────────────────────────
  -- Cmd+Shift+Arrow → select text
  { key = "LeftArrow",  mods = "CMD|SHIFT", action = wezterm.action.SelectTextAtMouseCursor 'Line' },

  -- Activate copy mode and move with shift+arrows
  { key = "LeftArrow",  mods = "SHIFT", action = wezterm.action.CopyMode 'MoveBackwardWord' },
  { key = "RightArrow", mods = "SHIFT", action = wezterm.action.CopyMode 'MoveForwardWord' },

  -- ── TEXT SELECTION (Mac style → tmux copy mode) ───────
  -- Cmd+Shift+LeftArrow → enter copy mode and select to beginning of line
  { key = "LeftArrow",  mods = "CMD|SHIFT",
    action = wezterm.action.SendString("\x1ba[\x1b0") },  -- prefix + [ enters copy mode, then Home

  -- Shift+Home → copy mode, go to beginning
  { key = "Home", mods = "SHIFT",
    action = wezterm.action.SendString("\x1ba[\x1b0") },

  -- Shift+End → copy mode, go to end
  { key = "End", mods = "SHIFT",
    action = wezterm.action.SendString("\x1ba[G") },

  -- ── TMUX COPY MODE ────────────────────────────────────
  -- Cmd+Shift+C → enter tmux copy mode (vim)  (prefix + [)
  { key = "c", mods = "CMD|SHIFT", action = wezterm.action.SendString("\x1ba[") },
}

-- Copy to clipboard automatically when selecting text with mouse
config.selection_word_boundary = " \t\n{}[]()\"'`,;:@"
config.mouse_bindings = {
  -- Copy on mouse selection release (no need to Cmd+C)
  {
    event = { Up = { streak = 1, button = "Left" } },
    mods = "NONE",
    action = wezterm.action.CompleteSelectionOrOpenLinkAtMouseCursor "Clipboard",
  },
}

-- ================================================================
--  CHEATSHEET
-- ================================================================
local cheatsheet = [[
┌──────────────────────────────────────────────────────┐
│               WEZTERM + TMUX SHORTCUTS               │
├──────────────────┬───────────────────────────────────┤
│ WEZTERM          │                                   │
├──────────────────┼───────────────────────────────────┤
│ Cmd+Shift+W      │ Close WezTerm window              │
│ Cmd+Shift+C      │ Enter tmux copy mode (vim)        │
│                  │   v → start selection             │
│                  │   y → copy to Mac clipboard + exit│
│                  │   q → exit without copying        │
│ Cmd+/            │ Show this cheatsheet              │
├──────────────────┼───────────────────────────────────┤
│ TMUX — WINDOWS   │                                   │
├──────────────────┼───────────────────────────────────┤
│ Cmd+T            │ New window                        │
│ Cmd+W            │ Close current pane                │
│ Cmd+H            │ Previous window                   │
│ Cmd+L            │ Next window                       │
│ Cmd+[            │ Previous window (alt)             │
│ Cmd+]            │ Next window (alt)                 │
│ Cmd+1..9         │ Switch to window N                │
│ Cmd+,            │ Rename current window             │
├──────────────────┼───────────────────────────────────┤
│ TMUX — SPLITS    │                                   │
├──────────────────┼───────────────────────────────────┤
│ Cmd+D            │ Vertical split                    │
│ Cmd+Shift+D      │ Horizontal split                  │
├──────────────────┼───────────────────────────────────┤
│ TMUX — PANES     │                                   │
├──────────────────┼───────────────────────────────────┤
│ Cmd+Shift+H      │ Move to left pane                 │
│ Cmd+Shift+J      │ Move to bottom pane               │
│ Cmd+Shift+K      │ Move to top pane                  │
│ Cmd+Shift+L      │ Move to right pane                │
│ Cmd+Z            │ Toggle pane zoom                  │
├──────────────────┼───────────────────────────────────┤
│ TMUX — LEADER    │ (Cmd+A, then...)                  │
├──────────────────┼───────────────────────────────────┤
│ LEADER + c       │ New window                        │
│ LEADER + x       │ Kill pane                         │
│ LEADER + |       │ Vertical split                    │
│ LEADER + -       │ Horizontal split                  │
│ LEADER + h/j/k/l │ Navigate panes                    │
│ LEADER + H/L     │ Previous / next window            │
│ LEADER + z       │ Toggle pane zoom                  │
│ LEADER + ,       │ Rename window                     │
│ LEADER + r       │ Reload tmux config                │
│ LEADER + y       │ Sync panes                        │
│ LEADER + 1..9    │ Switch to window N                │
├──────────────────┼───────────────────────────────────┤
│ TERMINAL — LINE EDITING                              │
├──────────────────┼───────────────────────────────────┤
│ Ctrl+U           │ Delete to beginning of line       │
│ Ctrl+K           │ Delete to end of line             │
│ Ctrl+W           │ Delete previous word              │
│ Alt+Backspace    │ Delete previous word (alt)        │
│ Ctrl+A           │ Move cursor to beginning of line  │
│ Ctrl+E           │ Move cursor to end of line        │
└──────────────────┴───────────────────────────────────┘
]]

-- Function to show cheatsheet in a floating WezTerm window
wezterm.on('show-cheatsheet', function(window, pane)
  local overrides = window:get_config_overrides() or {}
  window:perform_action(
    wezterm.action.SpawnCommandInNewWindow {
      args = { 'bash', '-c',
        string.format(
          [[echo '%s' && echo "" && echo "  Press q or Ctrl+C to close" && read -n1]],
          cheatsheet:gsub("'", "'\\''")
        )
      },
      set_environment_variables = {},
    },
    pane
  )
end)

return config
