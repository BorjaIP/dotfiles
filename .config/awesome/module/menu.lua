local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local menubar = require("menubar")
local freedesktop = require("freedesktop")
local dpi = require("beautiful.xresources").apply_dpi
local hotkeys_popup = require("awful.hotkeys_popup").widget

require("awful.hotkeys_popup.keys")

-- Apps
local terminal = "alacritty"
awful.util.terminal = terminal

-- =========================================
--                  Menu
-- =========================================
-- Create a launcher widget and a main menu
local menu = {
    { "hotkeys", function() return false, hotkeys_popup.show_help end },
    -- { "manual", terminal .. " -e man awesome", menubar.utils.lookup_icon("system-help") },
    { "edit config", string.format("%s -e %s %s", terminal, editor, awesome.conffile) },
    { "restart", awesome.restart },
    { "quit", function() awesome.quit() end }
}

awful.util.mymainmenu = freedesktop.menu.build({
    icon_size = beautiful.menu_height or dpi(16),
    before = {
        { "Awesome", menu, beautiful.awesome_icon },
        -- other triads can be put here
    },
    after = {
        { "Open terminal", terminal },
        -- other triads can be put here
    }
})

-- Hide menu when mouse leaves it
awful.util.mymainmenu.wibox:connect_signal("mouse::leave", function() awful.util.menu:hide() end)

-- Set the Menubar terminal for applications that require it
menubar.utils.terminal = terminal

