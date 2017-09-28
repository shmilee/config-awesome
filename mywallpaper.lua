--[[
     Licensed under GNU General Public License v2
      * (c) 2017, shmilee                         
--]]

local beautiful  = require("beautiful")
local gears      = require("gears")
local easy_async = require("awful.spawn").easy_async
--local naughty    = require("naughty")

local newtimer    = require("lain.helpers").newtimer
local file_exists = require("lain.helpers").file_exists
local json        = require("lain.util").dkjson

local math   = { max  = math.max }
local string = { format = string.format, gsub = string.gsub }
local table  = { unpack = table.unpack}
local next   = next

local function get_bingwallpaper(screen, args)
    local bingwallpaper   = {}
    local RESOLUTION_LOW  = '1366x768'
    local RESOLUTION_HIGH = '1920x1080'
    local args         = args or {}
    local bing         = args.bing or 'https://www.bing.com'
    local idx          = args.idx or 0 --TOMORROW:-1, TODAY:0, YESTERDAY:1, ... 7
    local n            = args.n or {1, 2, 3, 4, 5, 6, 7, 8} -- n:1-8
    local curl         = args.curl or 'curl -f -s -m 10'
    local tmpdir       = args.tmpdir or '/tmp'
    local force_hd     = args.force_hd or false
    local timeout      = args.timeout or 60
    local timeout_info = args.timeout_info or 86400
    local settings     = args.settings or function(s)
        gears.wallpaper.maximized(s.bingwallpaper.path[s.bingwallpaper.using], s, true)
    end

    bingwallpaper.screen     = screen
    bingwallpaper.resolution = RESOLUTION_LOW
    bingwallpaper.using      = nil
    bingwallpaper.url        = nil
    bingwallpaper.path       = {}

    function bingwallpaper.update_info()
        local cmd = string.format(
            "%s '%s/HPImageArchive.aspx?format=js&idx=%d&n=8'", curl, bing, idx)
        easy_async(cmd, function(stdout, stderr, reason, exit_code)
            --naughty.notify({ title = bingwallpaper.screen.geometry.height })
            if force_hd or bingwallpaper.screen.geometry.height > 1000 then
                bingwallpaper.resolution = RESOLUTION_HIGH
            end
            bingwallpaper.url = {}
            local data, pos, err, url, i
            data, pos, err = json.decode(stdout, 1, nil)
            if not err and type(data) == "table" then
                for i in pairs(n) do
                    if i >= 1 and i <= 8 then
                        url = bing .. data['images'][i]['urlbase']
                        url = string.format("%s_%s.jpg", url, bingwallpaper.resolution)
                        bingwallpaper.url[i] = url
                    end
                end
            end
            --naughty.notify({ title = bingwallpaper.url[2] })
            bingwallpaper.update()
        end)
    end

    function bingwallpaper.update()
        if bingwallpaper.url == nil then
            return false
        else
            local i = next(bingwallpaper.url, bingwallpaper.using)
            if i == nil then
                i = next(bingwallpaper.url, i)
            end
            if i == nil then
                -- bingwallpaper.url is empty, Net Unreachable
                return false
            end
            local url = bingwallpaper.url[i]
            local path = tmpdir .. '/' .. string.gsub(url, "(.*/)(.*)", "%2")
            if file_exists(path) then
                bingwallpaper.path[i] = path
                bingwallpaper.using = i
                --naughty.notify({ title = bingwallpaper.path[i]})
                settings(bingwallpaper.screen)
            else
                local cmd = string.format("%s %s -o %s", curl, url, path)
                easy_async(cmd, function(stdout, stderr, reason, exit_code)
                    --naughty.notify({ title = exit_code })
                    if exit_code == 0 then
                        bingwallpaper.path[i] = path
                        bingwallpaper.using = i
                    end
                    --naughty.notify({ title = bingwallpaper.path[i]})
                    settings(bingwallpaper.screen)
                end)
            end
        end
    end

    bingwallpaper.timer = newtimer("bingwallpaper-info-" .. screen.index, timeout_info, bingwallpaper.update_info, false, true)
    bingwallpaper.timer = newtimer("bingwallpaper-" .. screen.index, timeout, bingwallpaper.update, false, true)

    return bingwallpaper
end

function set_wallpaper(s)
    -- Wallpaper
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        -- If wallpaper is a function, call it with the screen
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s, true)
    end
    -- bingwallpaper
    if s.index % 2 == 0 then
        s.bingwallpaper = get_bingwallpaper(s, {
            idx = -1,
            --tmpdir = os.getenv("HOME") .. "/.cache/bingwallpaper",
            timeout = 300,
        })
    --elseif s.index % 2 == 1 then
    --    s.bingwallpaper = get_bingwallpaper(s, {
    --        idx = 1,
    --        timeout = 300,
    --        force_hd = true,
    --    })
    end
end
