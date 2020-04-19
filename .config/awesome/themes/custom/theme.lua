--[[
             ████████╗██╗  ██╗███████╗███╗   ███╗███████╗
             ╚══██╔══╝██║  ██║██╔════╝████╗ ████║██╔════╝
                ██║   ███████║█████╗  ██╔████╔██║█████╗
                ██║   ██╔══██║██╔══╝  ██║╚██╔╝██║██╔══╝
                ██║   ██║  ██║███████╗██║ ╚═╝ ██║███████╗
                ╚═╝   ╚═╝  ╚═╝╚══════╝╚═╝     ╚═╝╚══════╝
--]]

local gears                                     = require("gears")
local lain                                      = require("lain")
local awful                                     = require("awful")
local wibox                                     = require("wibox")
local dpi                                       = require("beautiful.xresources").apply_dpi

local os = os

-- Tags list
local tags                                      = require("themes.custom.tags")
local TagList                                   = require('widget.taglist')

-- Task list
local TaskList                                  = require('widget.tasklist')

-- Icons
-- Source : https://fontawesome.com/cheatsheet
local icons                                     = require('themes.custom.icons')

-- Load custom colors based on Base16
-- http://chriskempson.com/projects/base16/
local base16_colors                             = require("themes.custom.base16-colors")

local base16_palette = {
    base16_colors.default_dark,
    base16_colors.ocean,
    base16_colors.dracula
}
local color = base16_palette[2]

-- Theme options
local theme                                     = {}
theme.confdir                                   = os.getenv("HOME") .. "/.config/awesome/themes/custom"
theme.wallpaper                                 = "/media/data/Wallpapers/pink_universe.jpg"
theme.font                                      = "Noto Sans Regular 10"
theme.tasklist_font                             = "Noto Sans Regular 10"

-- Backgrounds
theme.bg_normal                                 = color.base00 --"00000000" -- Trasnparent
theme.bg_focus                                  = color.base01
theme.bg_urgent                                 = color.base02
theme.fg_normal                                 = color.base03
theme.fg_focus                                  = color.base07
theme.fg_urgent                                 = color.base08
theme.fg_minimize                               = color.base03

-- Border
theme.border_width                              = dpi(1)
theme.border_normal                             = color.base01
theme.border_focus                              = color.base08
theme.border_marked                             = color.base02

-- Taglist
theme.taglist_bg_normal                         = theme.bg_normal
theme.taglist_bg_focus =
  'linear:0,0:0,' ..
  dpi(30) ..
    ':0,' ..
      theme.bg_focus ..
        ':0.90,' .. theme.bg_focus .. ':0.90,' .. color.base08 .. ':1,' .. color.base08

-- Tasklist
theme.tasklist_font                             = 'Roboto medium 11'
theme.tasklist_bg_normal                        = theme.bg_normal
theme.tasklist_bg_focus =
  'linear:0,0:0,' ..
  dpi(30) ..
    ':0,' ..
      theme.bg_focus ..
        ':0.90,' .. theme.bg_focus .. ':0.90,' .. color.base08 .. ':1,' .. color.base08
theme.tasklist_bg_urgent                        = theme.bg_urgent
theme.tasklist_fg_normal                        = theme.fg_normal
theme.tasklist_fg_focus                         = theme.fg_focus
theme.tasklist_fg_urgent                        = theme.fg_normal
theme.tasklist_plain_task_name                  = true

-- Menu
theme.menu_height                               = 20
theme.menu_width                                = 140
-- theme.menu_bg_normal                            = "#000000"
-- theme.menu_bg_focus                             = "#000000"
-- theme.menu_border_width                         = 6
theme.awesome_icon                              = icons.awesome
theme.icon_theme                                = "Papirus Dark"

-- Title bar
theme.titlebar_bg_focus                         = color.base00
theme.titlebar_fg_focus                         = color.base06
theme.titlebar_bg_normal                        = color.base01
theme.titlebar_fg_normal                        = color.base04

--Layouts
theme.layout_floating                           = icons.floating
theme.layout_tile                               = icons.tile
theme.layout_tilebottom                         = icons.tilebottom
theme.layout_tileleft                           = icons.tileleft
theme.layout_tiletop                            = icons.tiletop

-- Titlebar
theme.titlebar_close_button_focus               = icons.close
theme.titlebar_close_button_normal              = icons.close
theme.titlebar_maximized_button_focus_inactive  = icons.plus
theme.titlebar_maximized_button_focus_active    = icons.plus

-- Systray
theme.systray_icon_spacing = dpi(6)

local markup = lain.util.markup

-- Textclock
os.setlocale(os.getenv("LANG")) -- to localize the clock
local mytextclock = wibox.widget.textclock(markup(color.base04, "%A %d %B ") .. markup(color.base04, " | ") .. markup(color.base04, " %H:%M " .. markup(color.base04, "  |  ")))
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

-- ALSA volume
local vol_icon = {
    {
        image   = icons.volume,
        widget  = wibox.widget.imagebox
    },
	margins = dpi(6),
	widget = wibox.container.margin
}
local volume = lain.widget.alsa({
    settings = function()
        if volume_now.status == "off" then
            volume_now.level = volume_now.level .. "M"
        end

        widget:set_markup(markup.fontfg(theme.font, color.base04, volume_now.level .. "% " .. markup(color.base04, " | ")))
    end
})

-- CPU
local cpu_icon = {
    {
        image   = icons.cpu,
        widget  = wibox.widget.imagebox
    },
	margins = dpi(6),
	widget = wibox.container.margin
}
local cpu = lain.widget.cpu({
    settings = function()
        widget:set_markup(markup.fontfg(theme.font, color.base04, cpu_now.usage .. "% " .. markup(color.base04, " | ")))
    end
})

-- MEM
local mem_icon = {
    {
        image   = icons.memory,
        widget  = wibox.widget.imagebox
    },
	margins = dpi(6),
	widget = wibox.container.margin
}
local memory = lain.widget.mem({
    settings = function()
        widget:set_markup(markup.fontfg(theme.font, color.base04, mem_now.perc .. "% " .. markup(color.base04, " | ")))
    end
})

-- MPD
local mpdicon = wibox.widget.imagebox()
local mpd = lain.widget.mpd({
    settings = function()
        mpd_notification_preset = {
            text = string.format("%s [%s] - %s\n%s", mpd_now.artist,
                   mpd_now.album, mpd_now.date, mpd_now.title)
        }

        if mpd_now.state == "play" then
            artist = mpd_now.artist .. " > "
            title  = mpd_now.title .. " "
            mpdicon:set_image(icons.note_on)
        elseif mpd_now.state == "pause" then
            artist = "mpd "
            title  = "paused "
        else
            artist = ""
            title  = ""
            --mpdicon:set_image() -- not working in 4.0
            mpdicon._private.image = nil
            mpdicon:emit_signal("widget::redraw_needed")
            mpdicon:emit_signal("widget::layout_changed")
        end
        widget:set_markup(markup.fontfg(theme.font, "#e54c62", artist) .. markup.fontfg(theme.font, "#b2b2b2", title))
    end
})

-- Wifi/Ethernet connection
local wifi_icon = wibox.widget.imagebox()
local eth_icon = wibox.widget.imagebox()
local net = lain.widget.net {
    notify = "on",
    wifi_state = "on",
    eth_state = "on",
    settings = function()
        local eth0 = net_now.devices.eth0
        if eth0 then
            if eth0.ethernet then
                eth_icon:set_image(ethernet_icon_filename)
            else
                eth_icon:set_image()
            end
        end

        local wlan0 = net_now.devices.wlan0
        if wlan0 then
            if wlan0.wifi then
                local signal = wlan0.signal
                if signal < -83 then
                    wifi_icon:set_image(wifi_weak_filename)
                elseif signal < -70 then
                    wifi_icon:set_image(wifi_mid_filename)
                elseif signal < -53 then
                    wifi_icon:set_image(wifi_good_filename)
                elseif signal >= -53 then
                    wifi_icon:set_image(wifi_great_filename)
                end
            else
                wifi_icon:set_image()
            end
        end
    end
}

-- Systray ( applications icons )
local systray = {
    wibox.widget {
		base_size = dpi(20),
		widget = wibox.widget.systray
	},
	margins = dpi(6),
	widget = wibox.container.margin
}

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
