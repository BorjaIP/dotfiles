--[[
                 ________  ___       ___  _______   ________  ________  _____ _______  _______
                |\   __  \|\  \     |\  \|\  ___ \ |\   ____\|\   __  \|\   _ \  _   \|\  ___ \
                \ \  \|\  \ \  \    \ \  \ \   __/|\ \  \___|\ \  \|\  \ \  \\\__\ \  \ \   __/|
                 \ \   __  \ \  \  __\ \  \ \  \_|/_\ \_____  \ \  \\\  \ \  \\|__| \  \ \  \_|/__
                  \ \  \ \  \ \  \|\__\_\  \ \  \_|\ \|____|\  \ \  \\\  \ \  \    \ \  \ \  \_|\ \
                   \ \__\ \__\ \____________\ \_______\____\_\  \ \_______\ \__\    \ \__\ \_______\
                    \|__|\|__|\|____________|\|_______|\_________\|_______|\|__|     \|__|\|_______|
                                                      \|_________|
]]--


-- =========================================
--          Variable Definitions
-- =========================================
-- Required libraries
local awesome, client, mouse, screen, tag = awesome, client, mouse, screen, tag
local ipairs, string, os, table, tostring, tonumber, type = ipairs, string, os, table, tostring, tonumber, type

-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = require("beautiful.xresources").apply_dpi
local hotkeys_popup = require("awful.hotkeys_popup").widget

require("awful.autofocus")
require("awful.hotkeys_popup.keys")

-- Menu
--local menubar         = require("menubar")
local freedesktop = require("freedesktop")

-- =========================================
--               Notifications
-- =========================================
require("module.rules")

-- =========================================
--               Notifications
-- =========================================
require("module.notifications")

-- =========================================
--                  Buttons
-- =========================================
root.buttons(require("keys.buttons").globalbuttons)

-- =========================================
--                  Keys
-- =========================================
root.keys(require("keys.global"))

-- =========================================
--                  Themes
-- =========================================
local themes            = { "custom" }
local chosen_theme      = themes[1]
beautiful.init(string.format("%s/.config/awesome/themes/%s/theme.lua", os.getenv("HOME"), chosen_theme))

-- Create a wibox for each screen and add it
awful.screen.connect_for_each_screen(function(s) beautiful.at_screen_connect(s) end)

-- Autostart windowless processes
-- This function will run once every time Awesome is started
local function run_once(cmd_arr)
    for _, cmd in ipairs(cmd_arr) do
        awful.spawn.with_shell(string.format("pgrep -u $USER -fx '%s' > /dev/null || (%s)", cmd, cmd))
    end
end

awful.util.terminal = terminal

-- =========================================
--                  Layout
-- =========================================
awful.layout.layouts = {
    awful.layout.suit.tile,
    awful.layout.suit.floating,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top
    --awful.layout.suit.spiral,
    --awful.layout.suit.spiral.dwindle
}

-- =========================================
--                  Menu
-- =========================================
-- Create a launcher widget and a main menu
local myawesomemenu = {
    { "hotkeys", function() return false, hotkeys_popup.show_help end },
    -- { "manual", terminal .. " -e man awesome", menubar.utils.lookup_icon("system-help") },
    { "edit config", string.format("%s -e %s %s", terminal, editor, awesome.conffile) },
    { "restart", awesome.restart },
    { "quit", function() awesome.quit() end }
}
awful.util.mymainmenu = freedesktop.menu.build({
    icon_size = beautiful.menu_height or dpi(16),
    before = {
        { "Awesome", myawesomemenu, beautiful.awesome_icon },
        -- other triads can be put here
    },
    after = {
        { "Open terminal", terminal },
        -- other triads can be put here
    }
})

-- hide menu when mouse leaves it
-- awful.util.mymainmenu.wibox:connect_signal("mouse::leave", function() awful.util.mymainmenu:hide() end)

--menubar.utils.terminal = terminal -- Set the Menubar terminal for applications that require it

-- =========================================
--                  Screen
-- =========================================
-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", function(s)
    -- Wallpaper
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        -- If wallpaper is a function, call it with the screen
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s, true)
    end
end)

-- No borders when rearranging only 1 non-floating or maximized client
screen.connect_signal("arrange", function (s)
    local only_one = #s.tiled_clients == 1
    for _, c in pairs(s.clients) do
        if only_one and not c.floating or c.maximized then
            c.border_width = 0
        else
            c.border_width = beautiful.border_width
        end
    end
end)


-- =========================================
--                  Signals
-- =========================================
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup and
      not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

-- Enable sloppy focus, so that focus follows mouse.
--client.connect_signal("mouse::enter", function(c)
--    c:emit_signal("request::activate", "mouse_enter", {raise = true})
--end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)

-- =========================================
--                  Titlebar
-- =========================================
-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
    -- Custom
    if beautiful.titlebar_fun then
        beautiful.titlebar_fun(c)
        return
    end

    -- Default
    -- buttons for the titlebar
    local buttons = gears.table.join(
        awful.button({ }, 1, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.move(c)
        end),
        -- awful.button({ }, 2, function() c:kill() end),
        awful.button({ }, 3, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.resize(c)
        end)
    )

    awful.titlebar(c, {size = 25}) : setup {
        { -- Left
            awful.titlebar.widget.iconwidget(c),
            buttons = buttons,
            layout  = wibox.layout.fixed.horizontal
        },
        { -- Middle
            { -- Title
                align  = "center",
                widget = awful.titlebar.widget.titlewidget(c)
            },
            buttons = buttons,
            layout  = wibox.layout.flex.horizontal
        },
        { -- Right
            awful.titlebar.widget.floatingbutton (c),
            --awful.titlebar.widget.stickybutton   (c),
            --awful.titlebar.widget.ontopbutton    (c),
            awful.titlebar.widget.maximizedbutton(c),
            awful.titlebar.widget.closebutton    (c),
            layout = wibox.layout.fixed.horizontal()
        },
        layout = wibox.layout.align.horizontal
    }
end)

-- =========================================
--              Applications
-- =========================================
-- Autostart applications
awful.spawn.with_shell("~/.config/awesome/autostart.sh")

