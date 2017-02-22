local awful = require("awful")
local beautiful = require("beautiful")
local gears = require("gears")

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.spiral,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier,
    -- awful.layout.suit.corner.nw,
    -- awful.layout.suit.corner.ne,
    -- awful.layout.suit.corner.sw,
    -- awful.layout.suit.corner.se,
}
local layouts = awful.layout.layouts

mytagnames = {
    { "宫", "商", "角", "徵", "羽" },
    { "壹", "貳", "叄", "肆", "伍", "陸", "柒", "捌", "玖" },
    { "一", "二", "三", "四", "五", "六", "七", "八", "九" },
    {  1, 2, 3, 4, 5, 6, 7, 8, 9, 10 },
}

mylayouts = {
    { layouts[1], layouts[1], layouts[2], layouts[1], layouts[1] },
    layouts[2],
    layouts[1],
    layouts[2],
}

--awful.tag.add("", {
--    icon = beautiful.awesome_icon,
--    screen = s,
--    layout = awful.layout.layouts[1],
--})

-- more wallpapers, 2 3 4
morewallpapers = {
    "/usr/share/wallpapers-shmilee/1080/violin-1920x1080.jpg",
    "/usr/share/wallpapers-shmilee/1200/arch-1920x1200.jpg",
    "/usr/share/wallpapers-shmilee/1200/black-1920x1200.jpg",
}

function set_wallpaper(s)
    -- Wallpaper 2 3 4
    if s.index > 1 and s.index-1 <= #morewallpapers then
        gears.wallpaper.maximized(morewallpapers[s.index-1], s, true)
    else
        if beautiful.wallpaper then
            local wallpaper = beautiful.wallpaper
            -- If wallpaper is a function, call it with the screen
            if type(wallpaper) == "function" then
                wallpaper = wallpaper(s)
            end
            gears.wallpaper.maximized(wallpaper, s, true)
        end
    end
end
