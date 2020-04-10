local awful             = require("awful")
                          require("awful.autofocus")
local lain              = require("lain")
local modkey            = require("keys.mod").modkey
local altkey            = require("keys.mod").altkey
local my_table          = awful.util.table or gears.table -- 4.{0,1} compatibility

clientkeys = my_table.join(
    --------------------------------------
    --      Client focus position
    --------------------------------------
    awful.key({ altkey,           }, "j",
              function()
                  awful.client.focus.global_bydirection("down")
                  if client.focus then client.focus:raise() end
              end,
              {description = "focus down",      group = "client"}),
    awful.key({ altkey,           }, "k",
              function()
                  awful.client.focus.global_bydirection("up")
                  if client.focus then client.focus:raise() end
              end,
              {description = "focus up",        group = "client"}),
    awful.key({ altkey,           }, "h",
              function()
                  awful.client.focus.global_bydirection("left")
                  if client.focus then client.focus:raise() end
              end,
              {description = "focus left",      group = "client"}),
    awful.key({ altkey,           }, "l",
              function()
                  awful.client.focus.global_bydirection("right")
                  if client.focus then client.focus:raise() end
              end,
              {description = "focus right",     group = "client"}),
    awful.key({ altkey,           }, "Tab",
              function ()
                  if cycle_prev then
                        awful.client.focus.history.previous()
                    else
                        awful.client.focus.byidx(-1)
                    end
                    if client.focus then
                        client.focus:raise()
                    end
                end,
              {description = "cycle with previous/go back", group = "client"}),
    -- awful.key({ altkey,           }, "j",
              -- function ()
                  -- awful.client.focus.byidx(1)
              -- end,
              -- {description = "focus next by index", group = "client"}),
    -- awful.key({ altkey,           }, "k",
              -- function ()
                  -- awful.client.focus.byidx(-1)
              -- end,
              -- {description = "focus previous by index", group = "client"}),

    --------------------------------------
    --      Layout manipulation
    --------------------------------------
    awful.key({ modkey, "Shift"   }, "j",       function () awful.client.swap.byidx(  1) end,
              {description = "swap with next client by index", group = "client"}),
    awful.key({ modkey, "Shift"   }, "k",       function () awful.client.swap.byidx( -1) end,
              {description = "swap with previous client by index", group = "client"}),
    awful.key({ modkey,           }, "u",       awful.client.urgent.jumpto,
              {description = "jump to urgent client", group = "client"}),
    awful.key({ modkey,           }, 't',       function (c) awful.titlebar.toggle(c) end,
              {description = "toggle title bar", group = "client"}),
    
    --------------------------------------
    --      Client options
    --------------------------------------
    awful.key({ modkey,           }, "q",       function (c) c:kill() end,
              {description = "close window",    group = "client"}),
    awful.key({ altkey, "Shift"   }, "m",       lain.util.magnify_client,
              {description = "magnify client",  group = "client"}),
    awful.key({ modkey,           }, "f",
              function (c)
                  c.fullscreen = not c.fullscreen
                  c:raise()
              end,
              {description = "toggle fullscreen", group = "client"}),
    awful.key({ modkey, "Control" }, "space",   awful.client.floating.toggle,
              {description = "toggle floating", group = "client"}),
    awful.key({ modkey,           }, "n",
              function (c)
                  -- The client currently has the input focus, so it cannot be
                  -- minimized, since minimized clients can't have the focus.
                  c.minimized = true
              end ,
              {description = "minimize",        group = "client"}),
    awful.key({ modkey,           }, "m",
              function (c)
                  c.maximized = not c.maximized
                  c:raise()
              end ,
              {description = "maximize",        group = "client"}),
    awful.key({ modkey, "Control" }, "n",
              function ()
                  local c = awful.client.restore()
                  -- Focus restored client
                  if c then
                      client.focus = c
                      c:raise()
                  end
              end,
              {description = "restore minimized", group = "client"})
)


return clientkeys
