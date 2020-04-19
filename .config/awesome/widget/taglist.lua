local awful                                     = require('awful')
local wibox                                     = require('wibox')
local gears                                     = require('gears')
local dpi                                       = require('beautiful').xresources.apply_dpi


-- =========================================
--              Taglist Buttons
-- =========================================
local taglist_buttons = awful.util.table.join(
    awful.button({ }, 1, function(t) t:view_only() end),
    awful.button({ modkey }, 1, function(t)
        if client.focus then
            client.focus:move_to_tag(t)
        end
    end),
    awful.button({ }, 3, awful.tag.viewtoggle),
    awful.button({ modkey }, 3, function(t)
        if client.focus then
            client.focus:toggle_tag(t)
        end
    end)
)

-- =========================================
--              Taglist Icons
-- =========================================
local widget_tags = {
    {
        {
            {   -- Add icon images
                id      = "icon_role",
                widget  = wibox.widget.imagebox,
            }, -- Margin for resize icons
            margins = 4,
            widget  = wibox.container.margin,
        },  -- Margin between tags
        left    = 10,
        right   = 10,
        widget  = wibox.container.margin,
    },  -- Show indicators
    id = "background_role",
    widget = wibox.container.background,
    shape = gears.shape.rectangle,
}

-- =========================================
--                  Taglist
-- =========================================
local tagList = function(s)
  return awful.widget.taglist{
        screen = s,
        filter = awful.widget.taglist.filter.all,
        widget_template = widget_tags,
        buttons = taglist_buttons
    }
end

return tagList
