local awful             = require("awful")
                          require("awful.autofocus")
-- Required variables
local table, client, tag, mouse = table, client, tag, mouse

local modkey            = require("keys.mod").modkey
local altkey            = require("keys.mod").altkey
local my_table          = awful.util.table or gears.table -- 4.{0,1} compatibility


-----------------------------------------------
--
--                Mouse Bindings
--               
-----------------------------------------------
-- Button 1 = Left click
-- Button 2 = Central
-- Button 3 = Right click
-- Button 4 = Scroll Wheel Up
-- Button 5 = Scroll Wheel Down
-- Button 6 = Thumb Wheel Up
-- Button 7 = Thumb Wheel Down
-- Button 8 = Back button
-- Button 9 = Forward button

local globalbuttons = my_table.join(
    awful.button({ }, 3, function () awful.util.mymainmenu:toggle() end),
    awful.button({ modkey }, 8, function() awful.tag.viewprev() end),
    awful.button({ modkey }, 9, function() awful.tag.viewnext() end)
)

local clientbuttons = my_table.join(
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

local taglistbuttons = my_table.join(
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

local tasklistbuttons = my_table.join(
    awful.button({ }, 1, function (c)
        if c == client.focus then
            c.minimized = true
        else
            --c:emit_signal("request::activate", "tasklist", {raise = true})

            -- Without this, the following
            -- :isvisible() makes no sense
            c.minimized = false
            if not c:isvisible() and c.first_tag then
                c.first_tag:view_only()
            end
            -- This will also un-minimize
            -- the client, if needed
            client.focus = c
            c:raise()
        end
    end),
    awful.button({ }, 2, function (c) c:kill() end),
    awful.button({ }, 3, function ()
        local instance = nil

        return function ()
            if instance and instance.wibox.visible then
                instance:hide()
                instance = nil
            else
                instance = awful.menu.clients({theme = {width = dpi(250)}})
            end
        end
    end)
)

return { 
    globalbuttons = globalbuttons, 
    clientbuttons = clientbuttons, 
    taglistbuttons = taglistbuttons,
    tasklistbuttons = tasklistbuttons
} 
