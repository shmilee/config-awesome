local gears = require("gears")
local awful = require("awful")
local naughty = require("naughty")
local menubar = require("menubar")
local beautiful = require("beautiful")
local reveloaded, revelation = pcall(require, "away.third_party.revelation")
if reveloaded then
    revelation.init({tag_name = 'Expose'})
end

-- setting tools
local xrandr = "arandr"
local searchtool = "synapse"
local screenlock = "XSECURELOCK_NO_COMPOSITE=1 xsecurelock"
local screenshot = "scrot"

local altkey = "Mod1"

local laptopkeys = gears.table.join(
    beautiful.widgets.volume.laptopkeys,
    -- keycode 235 = XF86Display
    awful.key({ }, "XF86Display",
        function ()
            --naughty.notify({ title = "Oops, Key XF86Display not set" })
            awful.spawn(xrandr)
        end),

    -- keycode 179 = XF86Tools, --> toggle the Synaptics Touchpad
    awful.key({ }, "XF86Tools",
        function ()
            local Tget = "synclient -l | grep -c 'TouchpadOff.*=.*0'"
            local check_cmd = string.format("synclient TouchpadOff=$(%s); %s", Tget, Tget)
            awful.spawn.easy_async_with_shell(check_cmd, function (o, e, r, c)
                local Timg
                if c == 0 then
                    Timg = beautiful.touchpad_on
                else
                    Timg = beautiful.touchpad_off
                end
                awful.spawn(string.format("volnoti-show -n 0 -s %s", Timg))
            end)
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
            local check_cmd = "xbacklight -dec 5; xbacklight"
            local bri_img = "/usr/share/pixmaps/volnoti/display-brightness-symbolic.svg"
            awful.spawn.easy_async_with_shell(check_cmd, function (o, e, r, c)
                awful.spawn(string.format("volnoti-show -s %s %s", bri_img, o))
            end)
        end),
    awful.key({ }, "XF86MonBrightnessUp",
        function ()
            local check_cmd = "xbacklight -inc 5; xbacklight"
            local bri_img = "/usr/share/pixmaps/volnoti/display-brightness-symbolic.svg"
            awful.spawn.easy_async_with_shell(check_cmd, function (o, e, r, c)
                awful.spawn(string.format("volnoti-show -s %s %s", bri_img, o))
            end)
        end)
)

local otherkeys = gears.table.join(
    awful.key({ modkey, }, "a",
        function ()
            local s = awful.screen.focused()
            s.mymainmenu:toggle()
        end,
        {description = "show main menu", group = "awesome"}),
    -- OSD Caps_Lock notify
    awful.key({ }, "Caps_Lock",
        function()
            local check_cmd = "sleep 0.2; xset q|grep 'Caps Lock:[ ]*on' >/dev/null"
            awful.spawn.easy_async_with_shell(check_cmd, function (o, e, r, c)
                local caps_img
                if c == 0 then
                    caps_img = beautiful.capslock_on
                else
                    caps_img = beautiful.capslock_off
                end
                awful.spawn(string.format("volnoti-show -n 0 -s %s", caps_img))
            end)
        end),
    -- Display
    awful.key({ modkey, "Control" }, "p", function () awful.spawn(xrandr) end,
        { description = "xrandr", group = "screen" }),
    -- lights on
    awful.key({ modkey, "Control" }, "l",
        function ()
            local check_cmd = "xset q | grep 'DPMS is Enabled' 2>&1 >/dev/null"
            awful.spawn.easy_async_with_shell(check_cmd, function (o, e, r, c)
                local cmd, title
                if c == 0 then
                    cmd, title = "xset -dpms s off", "DPMS is Disabled"
                else
                    cmd, title = "xset +dpms s on", "DPMS is Enabled"
                end
                awful.spawn.easy_async(cmd, function (out, err, r, ecode)
                    naughty.notify({ title = title })
                end)
            end)
        end,
        { description = "screen blanking, DPMS on/off", group = "screen" }),
    --休眠
    awful.key({ modkey, "Control" }, "s",
        function ()
            awful.spawn("systemctl suspend")
        end,
        { description = "system suspend", group = "system" }),
    --锁屏
    awful.key({ modkey, "Control" }, "x", function () awful.spawn.with_shell(screenlock) end,
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
if reveloaded then
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

return gears.table.join(laptopkeys, otherkeys, revelationkeys)
