local awful = require('awful')
local gears = require('gears')
local wibox = require("wibox")
local dpi   = require("beautiful.xresources").apply_dpi
local icons = require('themes.custom.icons.tags')

local tags = {
    {
        icon = icons.web,
        --defaultApp = apps.default.browser,
        screen = 1
    },
    {
        icon = icons.code,
        --defaultApp = apps.default.editor,
        screen = 1
    },
    {
        icon = icons.social,
        --defaultApp = apps.default.social,
        screen = 1
    },
    {
        icon = icons.game,
        --defaultApp = apps.default.game,
        screen = 1
    },
    {
        icon = icons.folder,
        --defaultApp = apps.default.files,
        screen = 1
    },
    {
        icon = icons.music,
        --defaultApp = apps.default.music,
        screen = 1
    },
    {
        icon = icons.lab,
        --defaultApp = apps.default.rofi,
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
            layout = awful.layout.suit.tile,
            gap_single_client = true,
            gap = 4,
            screen = s,
            selected = i == 1
        }
        )
    end
end
)
