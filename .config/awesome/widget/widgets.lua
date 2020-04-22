local lain = require("lain")
local wibox = require("wibox")
local beautiful = require ("beautiful")
local icons = require("themes.custom.icons")
local dpi = require("beautiful.xresources").apply_dpi

local os = os
local markup = lain.util.markup

-- =========================================
--                  Textclock
-- =========================================
-- os.setlocale(os.getenv("LANG")) -- to localize the clock
-- textclock = wibox.widget.textclock(markup(beautiful.fg_focus, "%A %d %B ") .. markup(beautiful.fg_focus, " | ") .. markup(beautiful.fg_focus, " %H:%M " .. markup(beautiful.fg_focus, "  |  ")))
-- textclock.font = beautiful.font

-- cal = lain.widget.cal({
-- attach_to = { mytextclock },
-- notification_preset = {
-- font = "Terminus 10",
-- fg   = beaufitul.fg_normal,
-- bg   = beaufitul.bg_normal
-- }
-- })

-- =========================================
--                  Volume
-- =========================================
vol_icon = {
    {
        image   = icons.volume,
        widget  = wibox.widget.imagebox
    },
    margins = dpi(6),
    widget = wibox.container.margin
}

volume = lain.widget.alsa({
    settings = function()
        if volume_now.status == "off" then
            volume_now.level = volume_now.level .. "M"
        end

        widget:set_markup(markup.fontfg(beautiful.font, beautiful.fg_focus, volume_now.level .. "% " .. markup(beautiful.fg_focus, " | ")))
    end
})

-- =========================================
--                   CPU
-- =========================================
cpu_icon = {
    {
        image   = icons.cpu,
        widget  = wibox.widget.imagebox
    },
    margins = dpi(6),
    widget = wibox.container.margin
}
cpu = lain.widget.cpu({
    settings = function()
        widget:set_markup(markup.fontfg(beautiful.font, beautiful.fg_focus, cpu_now.usage .. "% " .. markup(beautiful.fg_focus, " | ")))
    end
})

-- =========================================
--                  Memory
-- =========================================
mem_icon = {
    {
        image   = icons.memory,
        widget  = wibox.widget.imagebox
    },
    margins = dpi(6),
    widget = wibox.container.margin
}
memory = lain.widget.mem({
    settings = function()
        widget:set_markup(markup.fontfg(beautiful.font, beautiful.fg_focus, mem_now.perc .. "% " .. markup(beautiful.fg_focus, " | ")))
    end
})

-- =========================================
--               Wifi/Ethernet
-- =========================================
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

-- =========================================
--              Music Control
-- =========================================
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


