local beautiful = require("beautiful")
local gears     = require("gears")
local wallpaper = require("away.wallpaper")

local os   = { getenv = os.getenv, date = os.date }
local type = type

function set_wallpaper(s)
    -- default Wallpaper
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        -- If wallpaper is a function, call it with the screen
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s, true)
    end
    -- screen 1
    if s.index == 1 then
        s.miscwallpaper = wallpaper.get_miscwallpaper(s, { timeout=300 }, {
            {
                name='bing', weight=2,
                args={
                    -- idx: TOMORROW=-1, TODAY=0, YESTERDAY=1, ... 7
                    query = { format='js', idx=-1, n=8 },
                    --cachedir = os.getenv("HOME") .. "/.cache/wallpaper-bing",
                    force_hd = true,
                },
            },
            {
                name='local', weight=1,
                args={
                    id='Local bing',
                    dirpath = os.getenv("HOME") .. "/.cache/wallpaper-bing",
                    filter='^2019',
                    --ls = 'ls -r',
                },
            },
            {
                name='local', weight=2,
                args={
                    id='Local 360chrome',
                    dirpath = os.getenv("HOME") .. "/.cache/wallpaper-360chrome",
                    --filter = '^$',
                    ls = 'ls -r',
                },
            },
        })
    -- screen 2
    elseif s.index == 2 then
        s.miscwallpaper = wallpaper.get_miscwallpaper(s, { timeout=300, random=true }, {
            {
                name='360chrome', weight=2,
                --args={},
            },
            {
                name='local', weight=2,
                args={
                    id='Local bing',
                    dirpath = os.getenv("HOME") .. "/.cache/wallpaper-bing",
                    filter='^2018',
                },
            },
            {
                name='local', weight=2,
                args={
                    id='Local lovebizhi',
                    dirpath = os.getenv("HOME") .. "/.cache/wallpaper-lovebizhi",
                    filter = '^风光风景',
                },
            },
        })
    end
end
