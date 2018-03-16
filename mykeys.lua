local gears = require("gears")
local awful = require("awful")
local naughty = require("naughty")
local menubar = require("menubar")
local beautiful = require("beautiful")
local revelation = require("revelation")
revelation.init({tag_name = 'Expose'})

-- setting tools
local xrandr = "arandr"
local searchtool = "synapse"
local screenlock = "slimlock"
local screenshot = "deepin-scrot"

local altkey = "Mod1"

local laptopkeys = gears.table.join(
    -- keycode 123 = XF86AudioRaiseVolume
    awful.key({}, "XF86AudioRaiseVolume",
        function ()
            os.execute(string.format("amixer -q set %s %s+", volume.channel, volume.step))
            volume.update()
        end),
    -- keycode 122 = XF86AudioLowerVolume
    awful.key({}, "XF86AudioLowerVolume",
        function ()
            os.execute(string.format("amixer -q set %s %s-", volume.channel, volume.step))
            volume.update()
        end),
    -- keycode 121 = XF86AudioMute
    awful.key({}, "XF86AudioMute",
        function ()
            --awful.spawn("ponymix toggle")
            os.execute(string.format("amixer -q set %s playback toggle", volume.channel))
            volume.update()
        end),
    -- keycode 198 = XF86AudioMicMute
    awful.key({}, "XF86AudioMicMute",
        function ()
            awful.spawn("amixer sset Capture toggle")
        end),

    -- keycode 235 = XF86Display
    awful.key({ }, "XF86Display",
        function ()
            --naughty.notify({ title = "Oops, Key XF86Display not set" })
            awful.spawn(xrandr)
        end),

    -- keycode 179 = XF86Tools, --> toggle the Synaptics Touchpad
    awful.key({ }, "XF86Tools",
        function ()
            os.execute("synclient TouchpadOff=$(synclient -l | grep -c 'TouchpadOff.*=.*0')")
            if os.execute("synclient -l | grep 'TouchpadOff.*=.*0' >/dev/null") then
                str = beautiful.touchpad_on
            else
                str = beautiful.touchpad_off
            end
            os.execute(string.format("volnoti-show -n 0 -s %s",str))
        end),

    -- keycode 225 = XF86Search
    awful.key({ }, "XF86Search",
        function ()
            --naughty.notify({ title = "Oops, Key XF86Search not set" })
            awful.spawn(searchtool)
        end),

    -- keycode 128 = XF86LaunchA
    awful.key({ }, "XF86LaunchA", function() menubar.show() end),

    -- keeeycode 152 = XF86Explorer
    --awful.key({ }, "XF86Explorer",
    --    function ()
    --        naughty.notify({ title = "Oops, Key XF86Explorer not set" })
    --    end),

    -- Brightness
    awful.key({ }, "XF86MonBrightnessDown",
        function ()
            os.execute(string.format("volnoti-show -s %s `xbacklight -dec %s; xbacklight`",
                "/usr/share/pixmaps/volnoti/display-brightness-symbolic.svg", 5))
        end),
    awful.key({ }, "XF86MonBrightnessUp",
        function ()
            os.execute(string.format("volnoti-show -s %s `xbacklight -inc %s; xbacklight`",
                "/usr/share/pixmaps/volnoti/display-brightness-symbolic.svg", 5))
        end)
)

local volumekeys = gears.table.join(
   -- ALSA volume control
    awful.key({ altkey }, "Up",
        function ()
            os.execute(string.format("amixer -q set %s %s+", volume.channel, volume.step))
            volume.update()
        end,
        { description = "raise volume", group = "audio" }),
    awful.key({ altkey }, "Down",
        function ()
            os.execute(string.format("amixer -q set %s %s-", volume.channel, volume.step))
            volume.update()
        end,
        { description = "lower volume", group = "audio" }),
    awful.key({ altkey }, "m",
        function ()
            os.execute(string.format("amixer -q set %s playback toggle", volume.channel))
            volume.update()
        end,
        { description = "mute volume", group = "audio" }),
    awful.key({ altkey, "Control" }, "m",
        function ()
            os.execute(string.format("amixer -q set %s 100%%", volume.channel))
            volume.update()
        end,
        { description = "maximize volume", group = "audio" })
)

local otherkeys = gears.table.join(
    awful.key({ modkey,           }, "a", function () mymainmenu:show() end,
        {description = "show main menu", group = "awesome"}),
    -- OSD Caps_Lock notify
    awful.key({ }, "Caps_Lock",
        function()
            local str = "sleep 0.2; xset q|grep 'Caps Lock:[ ]*on' >/dev/null"
            if os.execute(str) then
                str = beautiful.capslock_on
            else
                str = beautiful.capslock_off
            end
            os.execute(string.format("volnoti-show -n 0 -s %s",str))
        end),
    -- Display
    awful.key({ modkey, "Control" }, "p", function () awful.spawn(xrandr) end,
        { description = "xrandr", group = "screen" }),
    -- lights on
    awful.key({ modkey, "Control" }, "l",
        function ()
            if os.execute("xset q | grep 'DPMS is Enabled' 2>&1 >/dev/null") then
                os.execute("xset -dpms s off")
                naughty.notify({ title = "DPMS is Disabled" })
            else
                os.execute("xset +dpms s on")
                naughty.notify({ title = "DPMS is Enabled" })
            end
        end,
        { description = "screen blanking, DPMS on/off", group = "screen" }),
    --休眠
    awful.key({ modkey, "Control" }, "s",
        function ()
            awful.spawn("systemctl suspend")
        end,
        { description = "system suspend", group = "system" }),
    --锁屏
    awful.key({ modkey, "Control" }, "x", function () awful.spawn(screenlock) end,
        { description = "lock screen", group = "screen" }),
    -- 截屏
    awful.key({ }, "Print", function() awful.spawn(screenshot) end,
        { description = "print screen", group = "screen" }),
    -- next miscwallpaper
    awful.key({ modkey, "Control" }, "w",
        function ()
            local s = awful.screen.focused()
            if s.miscwallpaper then
                s.miscwallpaper.update()
            end
        end,
        { description = "next screen wallpaper", group = "screen" }),
    -- Hide / show wibox
    awful.key({ modkey }, "b",
        function ()
            awful.screen.focused().mywibox.visible = not awful.screen.focused().mywibox.visible
        end,
        { description = "hide / show wibox", group = "awesome" })
)

local revelationkeys = nil
if package.loaded["revelation"] then
    revelationkeys = gears.table.join(
        -- keycode 152 = XF86Explorer
        awful.key({ }, "XF86Explorer", revelation),
        awful.key({ modkey, }, "e", revelation,
            { description = "'expose' view of all clients", group = "revelation" }),
        awful.key({ modkey, "Control" }, "e",
            function()
                revelation({
                    rule = {class = {"Xfce4-terminal", "Gnome-terminal", "Konsole",
                            "Yakuake", "Termite", "XTerm", "URxvt", "Vte", "Vte-app"},
                            any = true}
                })
             end,
             { description = "'expose' view of terminal clients", group = "revelation" })
    )
end

return gears.table.join(laptopkeys, volumekeys, otherkeys, revelationkeys)
