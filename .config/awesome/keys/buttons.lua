local awful             = require("awful")
                          require("awful.autofocus")
local modkey            = require("keys.mod").modkey
local altkey            = require("keys.mod").altkey

-- =========================================
--              Mouse Bindings
-- =========================================
-- Button 1 = Left click
-- Button 2 = Central
-- Button 3 = Right click
-- Button 4 = Scroll Wheel Up
-- Button 5 = Scroll Wheel Down
-- Button 6 = Thumb Wheel Up
-- Button 7 = Thumb Wheel Down
-- Button 8 = Back button
-- Button 9 = Forward button

local globalbuttons = awful.util.table.join(
    awful.button({ }, 3, function () awful.util.mymainmenu:toggle() end),
    awful.button({ modkey }, 8, function() awful.tag.viewprev() end),
    awful.button({ modkey }, 9, function() awful.tag.viewnext() end)
)

local clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
    end),
    awful.button({ modkey }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.move(c)
    end),
    awful.button({ modkey }, 3, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.resize(c)
    end),
    awful.button({ modkey }, 8, function(t) awful.tag.viewprev(t.screen) end),
    awful.button({ modkey }, 9, function(t) awful.tag.viewnext(t.screen) end)
)

return {
    globalbuttons = globalbuttons,
    clientbuttons = clientbuttons
}
