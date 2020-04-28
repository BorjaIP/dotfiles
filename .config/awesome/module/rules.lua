local awful = require("awful")
local beautiful = require("beautiful")
local clientkeys = require("keys.client")
local buttons = require("keys.buttons")

-- Screen geometry
local screen_width = awful.screen.focused().geometry.width
local screen_height = awful.screen.focused().geometry.height

-- =========================================
--                  Rules
-- =========================================
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    {
        rule = { },
        properties = {
            border_width = beautiful.border_width,
            border_color = beautiful.border_normal,
            focus = awful.client.focus.filter,
            raise = true,
            keys = clientkeys,
            buttons = buttons.clientbuttons,
            size_hints_honor = false, -- Remove gaps between terminals
            screen = awful.screen.preferred,
            -- callback = awful.client.setslave,
            placement = awful.placement.no_overlap+awful.placement.no_offscreen,
        }
    },

    -- Titlebars
    {
        rule_any = { type = { "normal", "dialog" } },
        properties = { titlebars_enabled = false }
    },
    -- =========================================
    --                  Programs
    -- =========================================
    -- Firefox
    {
        rule = { instance = "firefox" },
        properties = {
            tag =  "1",
            maximized = true
        }
    },

    -- Thunar
    {
        rule = { instance = "thunar" },
        properties = {
            -- honor_padding = true,
            -- honor_workarea = true,
            x = screen_width * 0.25,
            y = screen_width * 0.15,
            width = screen_width * 0.5,
            height = screen_height * 0.5
        }
    },

    -- Mailspring
    {
        rule = { instance = "mailspring" },
        properties = {
            tag = "3",
            screen = 2,
            floating = true,
            width = screen_width * 0.7,
            height = screen_height * 0.7
        }
    },

    -- Transmission
    {
        rule = { instance = "transmission" },
        properties = {
            tag = "5",
            screen = 2,
            floating = true,
            switchtotag = true,
            width = screen_width * 0.5,
            height = screen_height * 0.6
        }
    },

    -- Telegram
    {
        rule = { instance = "telegram" },
        properties = {
            tag = "3",
            screen = 1,
            floating = true,
            -- switchtotag = true, TODO: test
            width = screen_width * 0.5,
            height = screen_height * 0.6
        }
    },
    --
    {
        rule_any = {
            class = "gcr-prompter",
            "File Operation Progress",
            "Library"
        },
        properties = {
            floating = true,
            ontop = true,
            width = screen_width * 0.4,
            height = screen_width * 0.4
        }
    }
}

