local gears                 = require('gears')
local wibox                 = require('wibox')
local awful                 = require('awful')
local naughty               = require('naughty')
local menubar               = require('menubar')
local beautiful             = require('beautiful')
local clickable_container   = require('widget.clickable-container')
local dpi                   = beautiful.xresources.apply_dpi


-- =========================================
--                Defaults
-- =========================================
naughty.config.defaults.title           = 'System Notification'
naughty.config.defaults.position        = 'top_right'
naughty.config.defaults.timeout         = 5
naughty.config.defaults.ontop           = true
naughty.config.defaults.icon_size       = beautiful.notification_icon_size
naughty.config.defaults.margin          = beautiful.notification_margin
naughty.config.defaults.border_width    = beautiful.notification_border_width
naughty.config.defaults.shape           = function(cr, w, h) gears.shape.rounded_rect(cr, w, h, dpi(6)) end

-- =========================================
--                  Theme
-- =========================================
naughty.config.padding                  = dpi(8)
naughty.config.spacing                  = dpi(8)
naughty.config.icon_dirs                = { "/usr/share/icons/Papirus/" }
naughty.config.icon_formats             = { "png", "svg", "jpg", "gif" }

-- =========================================
--              Error handling
-- =========================================
awesome.connect_signal("request::display_error", function(message, startup)
    naughty.notification {
        urgency     = "critical",
        title       = "Oops, an error happened"..(startup and " during startup!" or "!"),
        message     = message,
        app_name    = 'System Notification',
        icon        = beautiful.awesome_icon
    }
end)

-- =========================================
--              XDG icon lookup
-- =========================================
awesome.connect_signal("request::icon", function(n, context, hints)
    if context ~= "app_icon" then return end

    local path = menubar.utils.lookup_icon(hints.app_icon) or
    menubar.utils.lookup_icon(hints.app_icon:lower())

    if path then
        n.icon = path
    end
end)

-- =========================================
--              Naughty Template
-- =========================================
awesome.connect_signal("request::display", function(n)

    -- naughty.actions template
    local actions_template = wibox.widget {
        notification    = n,
        base_layout     = wibox.widget {
            spacing        = dpi(0),
            layout         = wibox.layout.flex.horizontal
        },
        widget_template = {
            {
                {
                    {
                        {
                            id     = 'text_role',
                            font   = beautiful.notification_font,
                            widget = wibox.widget.textbox
                        },
                        widget = wibox.container.place
                    },
                    widget = clickable_container
                },
                bg                 = beautiful.notification_bg,
                shape              = gears.shape.rounded_rect,
                forced_height      = dpi(30),
                widget             = wibox.container.background
            },
            margins = dpi(4),
            widget  = wibox.container.margin
        },
        style   = { underline_normal = false, underline_selected = true },
        widget  = naughty.list.actions
    }

    -- Custom notification layout
    naughty.layout.box {
        notification    = n,
        type            = "notification",
        screen          = awful.screen.preferred(),
        widget_template = {
            {
                {
                    {
                        {
                            {
                                {
                                    {
                                        {       -- TODO -- Fix titlebar
                                            {   -- Titlebar
                                                {
                                                    {
                                                        markup  = 'asdfsdafasd',
                                                        align   = 'center',
                                                        valign  = 'center',
                                                        widget  = wibox.widget.textbox

                                                    },
                                                    margins = beautiful.notification_margin,
                                                    widget  = wibox.container.margin,
                                                },
                                                bg = "#000000",
                                                widget  = wibox.container.background,
                                            },
                                            {
                                                {   -- Icon
                                                    {
                                                        resize_strategy = 'center',
                                                        widget          = naughty.widget.icon,
                                                    },
                                                    margins = beautiful.notification_margin,
                                                    widget  = wibox.container.margin,
                                                },
                                                {   -- Text notification
                                                    {
                                                        layout = wibox.layout.align.vertical,
                                                        expand = 'none',
                                                        nil,
                                                        {
                                                            {
                                                                align   = 'left',
                                                                widget  = naughty.widget.title
                                                            },
                                                            {
                                                                align   = "left",
                                                                widget  = naughty.widget.message,
                                                            },
                                                            layout = wibox.layout.fixed.vertical
                                                        },
                                                        nil
                                                    },
                                                    margins = beautiful.notification_margin,
                                                    widget  = wibox.container.margin,
                                                },
                                                layout = wibox.layout.fixed.horizontal,
                                            },
                                            fill_space = true,
                                            spacing = beautiful.notification_margin,
                                            layout  = wibox.layout.fixed.vertical,
                                        },
                                        -- Margin between the fake background
                                        -- Set to 0 to preserve the 'titlebar' effect
                                        margins = dpi(0),
                                        widget  = wibox.container.margin,
                                    },
                                    bg = beautiful.transparent,
                                    widget  = wibox.container.background,
                                },
                                -- Notification action list
                                -- naughty.list.actions,
                                actions_template,
                                spacing = dpi(4),
                                layout  = wibox.layout.fixed.vertical,
                            },
                            bg     = beautiful.transparent,
                            id     = "background_role",
                            widget = naughty.container.background,
                        },
                        strategy = "min",
                        width    = dpi(160),
                        widget   = wibox.container.constraint,
                    },
                    strategy = "max",
                    width    = beautiful.notification_max_width or dpi(500),
                    widget   = wibox.container.constraint,
                },
                -- Anti-aliasing container
                -- Real BG
                bg      = beautiful.notification_bg,
                -- This will be the anti-aliased shape of the notification
                shape   = gears.shape.rounded_rect,
                widget  = wibox.container.background
            },
            -- Margin of the fake BG to have a space between notification and the screen edge
            margins = dpi(5),
            widget  = wibox.container.margin
        }

    }

    -- Destroy popups if dont_disturb mode is on
    -- Or if the right_panel is visible
    local focused = awful.screen.focused()
    if _G.dont_disturb or (focused.right_panel and focused.right_panel.visible) then
        naughty.destroy_all_notifications()
    end

end)

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
