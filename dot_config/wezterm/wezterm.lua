local wezterm = require 'wezterm'
local config = wezterm.config_builder()

-- Window geometry
config.initial_cols = 180
config.initial_rows = 48

-- Allow left Option key to compose special characters (ñ, etc.)
config.send_composed_key_when_left_alt_is_pressed = true

return config
