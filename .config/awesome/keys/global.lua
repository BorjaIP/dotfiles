local awful             = require("awful")
                          require("awful.autofocus")
local hotkeys_popup     = require("awful.hotkeys_popup").widget
                          require("awful.hotkeys_popup.keys")
local lain              = require("lain")
local beautiful         = require('beautiful')
local modkey            = require("keys.mod").modkey
local altkey            = require("keys.mod").altkey
local terminal          = "alacritty"


-- =========================================
--              Global Keys
-- =========================================
local globalkeys = awful.util.table.join(
    -- =========================================
    --              Awesome Keys
    -- =========================================
    -- Ctrl
    awful.key({ modkey, "Control" }, "r",       awesome.restart,
              {description = "Reload awesome",  group = "awesome"}),
    -- Shift
    awful.key({ modkey, "Shift"   }, "q",       awesome.quit,
              {description = "Quit awesome",    group = "awesome"}),
    awful.key({ modkey, "Shift"   }, "r",       function () awful.spawn(string.format("prompt 'Reboot computer?' 'sudo -A reboot'")) end,
              {description = "Reload computer", group = "awesome"}),
    awful.key({ modkey, "shift"   }, "x",       function () awful.spawn(string.format("prompt 'shutdown computer?' 'sudo -a shutdown -h now'")) end,
              {description = "Shutdown computer",group = "awesome"}),
    -- Super
    awful.key({ modkey,           }, "b",
              function ()
                  for s in screen do
                      s.mywibox.visible = not s.mywibox.visible
                  end
              end,
              {description = "Toggle wibox",    group = "awesome"}),
    awful.key({ modkey,           }, "s",       hotkeys_popup.show_help,
              {description = "Show help",       group = "awesome"}),
    awful.key({ modkey,           }, "w",       function () awful.util.mymainmenu:show() end,
              {description = "Show main menu",  group = "awesome"}),
    awful.key({ modkey,           }, "y",       function () awful.spawn(string.format("light-locker-command -l")) end,
              {description = "Lock screen",     group = "awesome"}),

    -- =========================================
    --                  Hotkeys
    -- =========================================
    -- ALSA volume control
    awful.key({ altkey,           }, "Up",
              function ()
                  os.execute(string.format("amixer -q set %s 1%%+", beautiful.volume.channel))
                  beautiful.volume.update()
              end,
              {description = "Volume up",       group = "hotkeys"}),
    awful.key({ altkey,           }, "Down",
              function ()
                  os.execute(string.format("amixer -q set %s 1%%-", beautiful.volume.channel))
                  beautiful.volume.update()
              end,
              {description = "Volume down",     group = "hotkeys"}),
    awful.key({ altkey,           }, "m",
              function ()
                  os.execute(string.format("amixer -q set %s toggle", beautiful.volume.togglechannel or beautiful.volume.channel))
                  beautiful.volume.update()
              end,
              {description = "Toggle mute",
              group = "hotkeys"}),
    -- Take a screenshot
    awful.key({ altkey,           }, "p",       function() awful.spawn(string.format("flameshot gui")) end,
              {description = "Take a screenshot", group = "hotkeys"}),
    -- Dmenu config
    awful.key({ modkey, "Shift"   }, "c",       function () awful.spawn(string.format("dmenu-config")) end,
              {description = "Show config files",group = "hotkeys"}),

    -- =========================================
    --                  Launcher
    -- =========================================
    -- Settings
    awful.key({ modkey,           }, "a",       function () awful.spawn(string.format("xfce4-settings-manager")) end,
              {description = "Run xfce4-settings",      group = "launcher"}),
    -- Terminal
    awful.key({ modkey,           }, "Return",  function () awful.spawn(terminal) end,
              {description = "Open a terminal", group = "launcher"}),
    -- Prompt
    awful.key({ modkey,           }, "r",       function () awful.screen.focused().mypromptbox:run() end,
              {description = "Run prompt",      group = "launcher"}),
    -- Dmenu
    awful.key({ modkey,           }, "space",   function () awful.spawn(string.format("dmenu_run")) end,
              {description = "Show dmenu",      group = "launcher"}),

    -- =========================================
    --                  Layout
    -- =========================================
    -- Change layout display
    awful.key({ altkey, "Control" }, "l",       function () awful.tag.incnmaster(-1, nil, true) end,
              {description = "Select next layout display", group = "layout"}),
    awful.key({ altkey, "Control" }, "h",       function () awful.tag.incnmaster( 1, nil, true) end,
              {description = "Select previous layout display", group = "layout"}),
    -- Resize layout
    awful.key({ altkey, "Shift"   }, "l",       function () awful.tag.incmwfact( 0.05) end,
              {description = "Increase layout size", group = "layout"}),
    awful.key({ altkey, "Shift"   }, "h",       function () awful.tag.incmwfact(-0.05) end,
              {description = "Decrease layout size", group = "layout"}),
    -- Change layoutbox
    awful.key({ altkey,           }, "space",   function () awful.layout.inc( 1) end,
              {description = "Select next",     group = "layout"}),
    awful.key({ altkey, "Shift"   }, "space",   function () awful.layout.inc(-1) end,
              {description = "Select previous", group = "layout"}),

    -- =========================================
    --                  Screen
    -- =========================================
    awful.key({ modkey, "Control" }, "j",       function () awful.screen.focus_relative( 1) end,
              {description = "Focus the next screen", group = "screen"}),
    awful.key({ modkey, "Control" }, "k",       function () awful.screen.focus_relative(-1) end,
              {description = "Focus the previous screen", group = "screen"}),

    -- =========================================
    --                  Tags
    -- =========================================
    -- Non-empty tag browsing
    awful.key({ modkey,           }, "Left",    function () lain.util.tag_view_nonempty(-1) end,
              {description = "View  previous nonempty", group = "tag"}),
    awful.key({ modkey,           }, "Right",   function () lain.util.tag_view_nonempty(1) end,
              {description = "View  previous nonempty", group = "tag"}),
    -- Tag browsing
    awful.key({ modkey,           }, "j",       awful.tag.viewprev,
              {description = "View previous",   group = "tag"}),
    awful.key({ modkey,           }, "k",       awful.tag.viewnext,
              {description = "View next",       group = "tag"}),
    awful.key({ modkey,           }, "Tab",     awful.tag.history.restore,
              {description = "Go back",         group = "tag"}),

    -- =========================================
    --                  Widgets
    -- =========================================
    -- MPD control
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
              {description = "Mpc on/off",      group = "widgets"}),
    awful.key({ altkey, "Control" }, "Up",
              function ()
                  os.execute("mpc toggle")
                  beautiful.mpd.update()
              end,
              {description = "Mpc toggle",      group = "widgets"}),
    awful.key({ altkey, "Control" }, "Down",
              function ()
                  os.execute("mpc stop")
                  beautiful.mpd.update()
              end,
              {description = "Mpc stop",        group = "widgets"}),
    awful.key({ altkey, "Control" }, "Left",
              function ()
                  os.execute("mpc prev")
                  beautiful.mpd.update()
              end,
              {description = "Mpc prev",        group = "widgets"}),
    awful.key({ altkey, "Control" }, "Right",
              function ()
                  os.execute("mpc next")
                  beautiful.mpd.update()
              end,
              {description = "Mpc next",        group = "widgets"})

)

-- =========================================
--                Number Keys
-- =========================================
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
    globalkeys = awful.util.table.join(globalkeys,
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
