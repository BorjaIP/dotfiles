local awful = require('awful')
local gears = require('gears')
local wibox = require("wibox")
local dpi   = require("beautiful.xresources").apply_dpi
local icons = require('themes.custom.icons.tags')

local tags = {
    {
        icon = icons.web,
        defaultApp = 'firefox',
        layout = awful.layout.suit.tile,
        screen = 1
    },
    {
        icon = icons.code,
        layout = awful.layout.suit.tile,
        screen = 1
    },
    {
        icon = icons.social,
        layout = awful.layout.suit.floating,
        screen = 1
    },
    {
        icon = icons.game,
        layout = awful.layout.suit.floating,
        screen = 1
    },
    {
        icon = icons.folder,
        layout = awful.layout.suit.floating,
        screen = 1
    },
    {
        icon = icons.music,
        layout = awful.layout.suit.tile,
        screen = 1
    },
    {
        icon = icons.terminal,
        layout = awful.layout.suit.tile,
        screen = 1
    }
}

awful.screen.connect_for_each_screen(
function(s)
    for i, tag in pairs(tags) do
        awful.tag.add(
        i,
        {
            icon = tag.icon,
            icon_only = true,
            layout = tag.layout,
            gap_single_client = true,
            gap = 3,
            screen = s,
            defaultApp = tag.defaultApp,
            selected = i == 1
        }
        )
    end
end
)
