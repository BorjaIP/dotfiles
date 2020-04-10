local awful             = require("awful")
                          require("awful.autofocus")
local hotkeys_popup     = require("awful.hotkeys_popup").widget
                          require("awful.hotkeys_popup.keys")
local lain              = require("lain")
local beautiful         = require('beautiful')

-- Required variables
local awesome, client, screen, tag = awesome, client, screen, tag
local string, os, table = string, os, table

local my_table          = awful.util.table or gears.table -- 4.{0,1} compatibility
local terminal          = os.getenv("TERMINAL") or "lxterminal"
local modkey            = require("keys.mod").modkey
local altkey            = require("keys.mod").altkey


local globalkeys = my_table.join(
    -----------------------------------------------
    --
    --                Awesome keys
    --               
    -----------------------------------------------
    awful.key({ modkey, "Control" }, "r",       awesome.restart,
              {description = "reload awesome",  group = "awesome"}),
    awful.key({ modkey, "Shift"   }, "q",       awesome.quit,
              {description = "quit awesome",    group = "awesome"}),
    awful.key({ modkey,           }, "s",       hotkeys_popup.show_help,
              {description = "show help",       group = "awesome"}),
    awful.key({ modkey,           }, "w",       function () awful.util.mymainmenu:show() end,
              {description = "show main menu",  group = "awesome"}),
    awful.key({ modkey }, "b",
              function ()
                  for s in screen do
                      s.mywibox.visible = not s.mywibox.visible
                  end
              end,
              {description = "toggle wibox",    group = "awesome"}),

    -- awful.key({ modkey }, "x",
              -- function ()
                  -- awful.prompt.run {
                    -- prompt       = "Run Lua code: ",
                    -- textbox      = awful.screen.focused().mypromptbox.widget,
                    -- exe_callback = awful.util.eval,
                    -- history_path = awful.util.get_cache_dir() .. "/history_eval"
                  -- }
              -- end,
              -- {description = "lua execute prompt", group = "awesome"}),

    -----------------------------------------------
    --
    --                Screen
    --               
    -----------------------------------------------
    awful.key({ modkey, "Control" }, "j",       function () awful.screen.focus_relative( 1) end,
              {description = "focus the next screen", group = "screen"}),
    awful.key({ modkey, "Control" }, "k",       function () awful.screen.focus_relative(-1) end,
              {description = "focus the previous screen", group = "screen"}),

    -----------------------------------------------
    --
    --                Tags
    --               
    -----------------------------------------------
    -- Tag browsing
    awful.key({ modkey,           }, "j",       awful.tag.viewprev,
              {description = "view previous",   group = "tag"}),
    awful.key({ modkey,           }, "k",       awful.tag.viewnext,
              {description = "view next",       group = "tag"}),
    awful.key({ modkey,           }, "Tab",     awful.tag.history.restore,
              {description = "go back",         group = "tag"}),

    -- Non-empty tag browsing
    awful.key({ modkey,           }, "Left",    function () lain.util.tag_view_nonempty(-1) end,
              {description = "view  previous nonempty", group = "tag"}),
    awful.key({ modkey,           }, "Right",   function () lain.util.tag_view_nonempty(1) end,
              {description = "view  previous nonempty", group = "tag"}),

    -----------------------------------------------
    --
    --                Layout
    --               
    -----------------------------------------------
    -- Resize
    awful.key({ altkey, "Shift"   }, "l",       function () awful.tag.incmwfact( 0.05) end,
              {description = "increase master width factor", group = "layout"}),
    awful.key({ altkey, "Shift"   }, "h",       function () awful.tag.incmwfact(-0.05) end,
              {description = "decrease master width factor", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "h",       function () awful.tag.incnmaster( 1, nil, true) end,
              {description = "increase the number of master clients", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "l",       function () awful.tag.incnmaster(-1, nil, true) end,
              {description = "decrease the number of master clients", group = "layout"}),
    awful.key({ modkey, "Control" }, "h",       function () awful.tag.incncol( 1, nil, true) end,
              {description = "increase the number of columns", group = "layout"}),
    awful.key({ modkey, "Control" }, "l",       function () awful.tag.incncol(-1, nil, true) end,
              {description = "decrease the number of columns", group = "layout"}),
    awful.key({ modkey,           }, "space",   function () awful.layout.inc( 1) end,
              {description = "select next",     group = "layout"}),
    awful.key({ modkey, "Shift"   }, "space",   function () awful.layout.inc(-1) end,
              {description = "select previous", group = "layout"}),


    -----------------------------------------------
    --
    --                Launcher
    --               
    -----------------------------------------------
    -- User programs
    awful.key({ modkey,           }, "Return",  function () awful.spawn(terminal) end,
              {description = "open a terminal", group = "launcher"}),

    -- Prompt
    awful.key({ modkey,           }, "r",                  function () awful.screen.focused().mypromptbox:run() end,
              {description = "run prompt",      group = "launcher"}),


    -----------------------------------------------
    --
    --                Hotkeys
    --               
    -----------------------------------------------
    -- Copy primary to clipboard (terminals to gtk)
    awful.key({ modkey            }, "c",       function () awful.spawn.with_shell("xsel | xsel -i -b") end,
              {description = "copy terminal to gtk", group = "hotkeys"}),
    -- Copy clipboard to primary (gtk to terminals)
    awful.key({ modkey            }, "v",       function () awful.spawn.with_shell("xsel -b | xsel") end,
              {description = "copy gtk to terminal", group = "hotkeys"}),

    -- Take a screenshot
    -- https://github.com/lcpz/dots/blob/master/bin/screenshot
    awful.key({ altkey,           }, "p",       function() os.execute("screenshot") end,
              {description = "take a screenshot", group = "hotkeys"}),

    -- Brightness
    awful.key({ }, "XF86MonBrightnessUp",       function () os.execute("xbacklight -inc 10") end,
              {description = "+10%",            group = "hotkeys"}),
    awful.key({ }, "XF86MonBrightnessDown",     function () os.execute("xbacklight -dec 10") end,
              {description = "-10%",            group = "hotkeys"}),

    -- ALSA volume control
    awful.key({ altkey,           }, "Up",
              function ()
                  os.execute(string.format("amixer -q set %s 1%%+", beautiful.volume.channel))
                  beautiful.volume.update()
              end,
              {description = "volume up",       group = "hotkeys"}),
    awful.key({ altkey,           }, "Down",
              function ()
                  os.execute(string.format("amixer -q set %s 1%%-", beautiful.volume.channel))
                  beautiful.volume.update()
              end,
              {description = "volume down",     group = "hotkeys"}),
    awful.key({ altkey,           }, "m",
              function ()
                  os.execute(string.format("amixer -q set %s toggle", beautiful.volume.togglechannel or beautiful.volume.channel))
                  beautiful.volume.update()
              end,
              {description = "toggle mute",     group = "hotkeys"}),


    -----------------------------------------------
    --
    --                Widgets
    --               
    -----------------------------------------------
    -- MPD control
    awful.key({ altkey, "Control" }, "Up",
              function ()
                  os.execute("mpc toggle")
                  beautiful.mpd.update()
              end,
              {description = "mpc toggle",      group = "widgets"}),
    awful.key({ altkey, "Control" }, "Down",
              function ()
                  os.execute("mpc stop")
                  beautiful.mpd.update()
              end,
              {description = "mpc stop",        group = "widgets"}),
    awful.key({ altkey, "Control" }, "Left",
              function ()
                  os.execute("mpc prev")
                  beautiful.mpd.update()
              end,
              {description = "mpc prev",        group = "widgets"}),
    awful.key({ altkey, "Control" }, "Right",
              function ()
                  os.execute("mpc next")
                  beautiful.mpd.update()
              end,
              {description = "mpc next",        group = "widgets"}),
    awful.key({ altkey }, "0",
              function ()
                  local common = { text = "MPD widget ", position = "top_middle", timeout = 2 }
                  if beautiful.mpd.timer.started then
                      beautiful.mpd.timer:stop()
                      common.text = common.text .. lain.util.markup.bold("OFF")
                  else
                      beautiful.mpd.timer:start()
                      common.text = common.text .. lain.util.markup.bold("ON")
                  end
                  naughty.notify(common)
              end,
              {description = "mpc on/off",      group = "widgets"}),

    -- Widgets popups
    awful.key({ altkey,           }, "c",       function () if beautiful.cal then beautiful.cal.show(7) end end,
              {description = "show calendar",   group = "widgets"}),
    -- awful.key({ altkey,           }, "h",       function () if beautiful.fs then beautiful.fs.show(7) end end,
              -- {description = "show filesystem", group = "widgets"}),
    awful.key({ altkey,           }, "w",       function () if beautiful.weather then beautiful.weather.show(7) end end,
              {description = "show weather",    group = "widgets"})

    --[[ dmenu
    awful.key({ modkey }, "x", function ()
            os.execute(string.format("dmenu_run -i -fn 'Monospace' -nb '%s' -nf '%s' -sb '%s' -sf '%s'",
            beautiful.bg_normal, beautiful.fg_normal, beautiful.bg_focus, beautiful.fg_focus))
        end,
        {description = "show dmenu", group = "launcher"})
    --]]

)


-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    -- Hack to only show tags 1 and 9 in the shortcut window (mod+s)
    local descr_view, descr_toggle, descr_move, descr_toggle_focus
    if i == 1 or i == 9 then
        descr_view = {description = "view tag #", group = "tag"}
        descr_toggle = {description = "toggle tag #", group = "tag"}
        descr_move = {description = "move focused client to tag #", group = "tag"}
        descr_toggle_focus = {description = "toggle focused client on tag #", group = "tag"}
    end
    globalkeys = my_table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = awful.screen.focused()
                        local tag = screen.tags[i]
                        if tag then
                           tag:view_only()
                        end
                  end,
                  descr_view),
        -- Toggle tag display.
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = awful.screen.focused()
                      local tag = screen.tags[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end,
                  descr_toggle),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:move_to_tag(tag)
                          end
                     end
                  end,
                  descr_move),
        -- Toggle tag on focused client.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:toggle_tag(tag)
                          end
                      end
                  end,
                  descr_toggle_focus)
    )
end


return globalkeys
