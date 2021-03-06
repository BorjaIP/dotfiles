--[[
                 __________ ___  ___  _______   _____ ______   _______
                |\___   ___\\  \|\  \|\  ___ \ |\   _ \  _   \|\  ___ \
                \|___ \  \_\ \  \\\  \ \   __/|\ \  \\\__\ \  \ \   __/|
                     \ \  \ \ \   __  \ \  \_|/_\ \  \\|__| \  \ \  \_|/__
                      \ \  \ \ \  \ \  \ \  \_|\ \ \  \    \ \  \ \  \_|\ \
                       \ \__\ \ \__\ \__\ \_______\ \__\    \ \__\ \_______\
                        \|__|  \|__|\|__|\|_______|\|__|     \|__|\|_______|

--]]

local gears = require("gears")
local lain = require("lain")
local awful = require("awful")
local wibox = require("wibox")
local dpi = require("beautiful.xresources").apply_dpi
local os = os


-- =========================================
--                  Widgets
-- =========================================
require("widget.widgets")

-- =========================================
--                  Tagslist
-- =========================================
local tags = require("themes.custom.tags")
local TagList = require('widget.taglist')

-- =========================================
--                  Tasklist
-- =========================================
local TaskList = require('widget.tasklist')

-- =========================================
--                  Icons
-- =========================================
-- Source : https://fontawesome.com/cheatsheet
local icons = require('themes.custom.icons')

-- =========================================
--                  Base 16
-- =========================================
-- Load custom colors based on Base16
-- http://chriskempson.com/projects/base16/
local base16_colors = require("themes.custom.base16-colors")
local base16_palette = {
    base16_colors.default_dark,
    base16_colors.ocean,
    base16_colors.dracula
}
local color = base16_palette[2]

-- =========================================
--              Theme options
-- =========================================
local theme = {}
theme.confdir = os.getenv("HOME") .. "/.config/awesome/themes/custom"
theme.wallpaper = "/media/data/Wallpapers/pink_universe.jpg"
theme.font = "Noto Sans Regular 10"
theme.awesome_icon = icons.awesome
theme.icon_theme = "Papirus Dark"

-- =========================================
--                Backgrounds
-- =========================================
theme.transparent = "00000000"
theme.bg_normal = color.base00
theme.bg_focus = color.base01
theme.bg_urgent = color.base02
theme.fg_normal = color.base03
theme.fg_focus = color.base07
theme.fg_urgent = color.base08
theme.fg_minimize = color.base03

-- =========================================
--                  Border
-- =========================================
theme.border_width = dpi(1)
theme.border_normal = color.base01
theme.border_focus = color.base08
theme.border_marked = color.base02
-- Rounded corners
-- theme.border_radius = dpi(6)

-- =========================================
--                  Taglist
-- =========================================
theme.taglist_bg_normal = theme.bg_normal
theme.taglist_bg_focus =
  'linear:0,0:0,' ..
  dpi(30) ..
    ':0,' ..
      theme.bg_focus ..
        ':0.90,' .. theme.bg_focus .. ':0.90,' .. color.base08 .. ':1,' .. color.base08

-- =========================================
--                  Tasklist
-- =========================================
theme.tasklist_font = theme.font
theme.tasklist_font = 'Roboto medium 11'
theme.tasklist_bg_normal = theme.bg_normal
theme.tasklist_bg_focus =
  'linear:0,0:0,' ..
  dpi(30) ..
    ':0,' ..
      theme.bg_focus ..
        ':0.90,' .. theme.bg_focus .. ':0.90,' .. color.base08 .. ':1,' .. color.base08
theme.tasklist_bg_urgent = theme.bg_urgent
theme.tasklist_fg_normal = theme.fg_normal
theme.tasklist_fg_focus = theme.fg_focus
theme.tasklist_fg_urgent = theme.fg_normal
theme.tasklist_plain_task_name = true

-- =========================================
--              Notifications
-- =========================================
theme.notification_font = theme.font
theme.notification_bg = theme.bg_focus
theme.notification_fg = theme.fg_focus
theme.notification_border_width = dpi(0)
theme.notification_margin = dpi(16)
theme.notification_icon_size = dpi(32)
theme.notification_border_color = theme.border_focus

-- =========================================
--                  Menu
-- =========================================
theme.menu_height = dpi(20)
theme.menu_width  = dpi(150)
theme.menu_bg_normal = color.base01
theme.menu_bg_focus = theme.bg_focus
theme.menu_fg_normal= theme.fg_normal
theme.menu_fg_focus= theme.fg_focus
theme.menu_border_width = dpi(0)
theme.menu_border_color = color.base08

-- =========================================
--                  Tooltips
-- =========================================
theme.tooltip_bg = color.base01
-- theme.tooltip_border_width = 0
-- theme.tooltip_shape = awful.tooltip:set_shape (dpi(8))
theme.tooltip_shape = function(cr, w, h)
    gears.shape.rounded_rect(cr, w, h, dpi(8))
end

-- =========================================
--                Title bar
-- =========================================
theme.titlebar_bg_focus = color.base00
theme.titlebar_fg_focus = color.base06
theme.titlebar_bg_normal = color.base01
theme.titlebar_fg_normal = color.base04
theme.titlebar_close_button_focus = icons.close
theme.titlebar_close_button_normal = icons.close
theme.titlebar_maximized_button_focus_inactive = icons.plus
theme.titlebar_maximized_button_focus_active = icons.plus

-- =========================================
--                  Layouts
-- =========================================
theme.layout_floating = icons.floating
theme.layout_tile = icons.tile
theme.layout_tilebottom = icons.tilebottom
theme.layout_tileleft = icons.tileleft
theme.layout_tiletop = icons.tiletop

-- =========================================
--                  Systray
-- =========================================
-- Systray ( applications icons )
theme.systray_icon_spacing = dpi(6)
local systray = {
    wibox.widget {
		base_size = dpi(20),
		widget = wibox.widget.systray
	},
	margins = dpi(6),
	widget = wibox.container.margin
}


local markup = lain.util.markup

-- Textclock
os.setlocale(os.getenv("LANG")) -- to localize the clock
local mytextclock = wibox.widget.textclock(markup(theme.fg_focus, "%A %d %B ") .. markup(theme.fg_focus, " | ") .. markup(theme.fg_focus, " %H:%M " .. markup(theme.fg_focus, "  |  ")))
mytextclock.font = theme.font

-- Calendar
theme.cal = lain.widget.cal({
    attach_to = { mytextclock },
    notification_preset = {
        font = "Terminus 10",
        fg   = theme.fg_normal,
        bg   = theme.bg_normal
    }
})

function theme.at_screen_connect(s)
    -- Quake application
    s.quake = lain.util.quake({ app = awful.util.terminal })

    -- If wallpaper is a function, call it with the screen
    local wallpaper = theme.wallpaper
    if type(wallpaper) == "function" then
        wallpaper = wallpaper(s)
    end
    gears.wallpaper.maximized(wallpaper, s, true)

    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()

    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons( awful.util.table.join(
                           awful.button({}, 1, function () awful.layout.inc( 1) end),
                           awful.button({}, 3, function () awful.layout.inc(-1) end)))

    -- Create the wibox
    s.mywibox = awful.wibar(
      {
        screen = s,
        height = dpi(28),
        width = s.geometry.width,
        stretch = false,
        bg = theme.bg_normal,
        fg = theme.fg_normal,
      }
    )

    -- Add widgets to the wibox
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            TagList(s),
            s.mypromptbox,
            mpdicon,
            mpd,
        }, -- Middle widget
        TaskList(s),
        { -- Right widgets
            layout = wibox.layout.fixed.horizontal,
			systray,
            net,
            mem_icon,
            memory,
            cpu_icon,
            cpu,
            vol_icon,
            volume,
            mytextclock,
            s.mylayoutbox,
        },
    }
end

return theme
