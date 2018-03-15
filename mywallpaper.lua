--[[
     Licensed under GNU General Public License v2
      * (c) 2017, shmilee                         
--]]

local beautiful  = require("beautiful")
local gears      = require("gears")
local easy_async = require("awful.spawn").easy_async
local timer      = require("gears.timer")
local json       = require("lain.util").dkjson
local naughty    = require("naughty")

local os     = { getenv = os.getenv, remove = os.remove, time = os.time }
local io     = { popen = io.popen, open = io.open }
local math   = { max = math.max, randomseed = math.randomseed, random = math.random }
local string = { format = string.format, gsub = string.gsub, match = string.match }
local table  = { concat = table.concat, insert = table.insert }
local next   = next
local pairs  = pairs

local function simple_range(head, tail, step)
    local res = {}
    while head <= tail do
        table.insert(res, head)
        head = head + step
    end
    return res
end

local function file_exists(path)
    local file = io.open(path, "rb")
    if file then
        file:close()
    end
    return file ~= nil
end

local function file_length(path)
    local file = io.open(path, "rb")
    local len = file:seek("end")
    file:close()
    return len
end

-- http://img0.bdstatic.com/static/common/pkg/cores_xxxxxxx.js
local function baidu_url_uncompile(s)
    local t = {
        ["w"]="a",
        ["k"]="b",
        ["v"]="c",
        ["1"]="d",
        ["j"]="e",
        ["u"]="f",
        ["2"]="g",
        ["i"]="h",
        ["t"]="i",
        ["3"]="j",
        ["h"]="k",
        ["s"]="l",
        ["4"]="m",
        ["g"]="n",
        ["5"]="o",
        ["r"]="p",
        ["q"]="q",
        ["6"]="r",
        ["f"]="s",
        ["p"]="t",
        ["7"]="u",
        ["e"]="v",
        ["o"]="w",
        ["8"]="1",
        ["d"]="2",
        ["n"]="3",
        ["9"]="4",
        ["c"]="5",
        ["m"]="6",
        ["0"]="7",
        ["b"]="8",
        ["l"]="9",
        ["a"]="0",
        ["_z2C$q"]=":",
        ["_z&e3B"]=".",
        ["AzdH3F"]="/",
    }
    local patterns= {"(_z2C$q)", "(_z&e3B)", "(AzdH3F)", '([a-w%d])'}
    local i, p
    for i, p in pairs(patterns) do
        s = string.gsub(s, p, function(i) return t[i] end)
    end
    return s
end

-- BingWallPaper: fetch Bing's images with meta data
local function get_bingwallpaper(screen, args)
    local bingwallpaper = { screen=screen, url=nil, path=nil, using=nil }
    local args          = args or {}
    local api           = args.api or 'https://www.bing.com/HPImageArchive.aspx'
    local query         = args.query or { format='js', idx=0, n=8 }
    local choices       = args.choices or { 1, 2, 3, 4, 5, 6, 7, 8 }
    local curl          = args.curl or 'curl -f -s -m 10'
    local cachedir      = args.cachedir or '/tmp'
    local timeout_info  = args.timeout_info or 86400
    local async_update  = args.async_update or false
    local setting       = args.setting or function(bwp)
        gears.wallpaper.maximized(bwp.path[bwp.using], bwp.screen, true)
    end
    bingwallpaper.force_hd = args.force_hd or false
    bingwallpaper.get_url  = args.get_url or function(bwp, data, choice)
        local suffix = "_1920x1080.jpg"
        if not bwp.force_hd and bwp.screen.geometry.height < 800 then
            suffix = "_1366x768.jpg"
        end
        if data['images'][choice] then
            return 'https://www.bing.com' .. data['images'][choice]['urlbase'] .. suffix
        else
            return nil
        end
    end
    bingwallpaper.get_name = args.get_name or function(bwp, data, choice)
        if data['images'][choice] then
            return data['images'][choice]['enddate'] .. string.gsub(bwp.url[choice], "(.*/)(.*)", "_%2")
        else
            return nil
        end
    end

    function bingwallpaper.update_info()
        local query_str = {}
        for i,v in pairs(query) do
            table.insert(query_str, i .. '=' .. v)
        end
        query_str = table.concat(query_str, '&')
        local cmd = string.format("%s '%s?%s'", curl, api, query_str)
        --naughty.notify({ title = cmd })
        easy_async(cmd, function(stdout, stderr, reason, exit_code)
            bingwallpaper.url = {}
            bingwallpaper.path = {}
            local data, pos, err
            data, pos, err = json.decode(stdout, 1, nil)
            if not err and type(data) == "table" then
                for _, c in pairs(choices) do
                    bingwallpaper.url[c] = bingwallpaper.get_url(bingwallpaper, data, c)
                    if bingwallpaper.url[c] then
                        bingwallpaper.path[c] = cachedir .. '/' .. bingwallpaper.get_name(bingwallpaper, data, c)
                    end
                    --naughty.notify({ title = bingwallpaper.path[c] })
                end
            end
            if async_update then
                bingwallpaper.update()
            end
        end)
    end

    function bingwallpaper.update()
        if bingwallpaper.url == nil then
            return false
        else
            if next(bingwallpaper.url) == nil then
                -- bingwallpaper.url is empty, Net Unreachable
                return false
            end
            local i = next(bingwallpaper.url, bingwallpaper.using)
            if i == nil then
                i = next(bingwallpaper.url, i)
            end
            if bingwallpaper.path[i] == nil then
                -- bingwallpaper.path[i] is broken
                return false
            end
            bingwallpaper.using = i
            if file_exists(bingwallpaper.path[i]) then
                if file_length(bingwallpaper.path[i]) == 0 then
                    --naughty.notify({ title = 'NO ' .. bingwallpaper.path[i]})
                    bingwallpaper.update()
                else
                    --naughty.notify({ title = 'OK ' .. bingwallpaper.path[i]})
                    setting(bingwallpaper)
                end
            else
                local cmd = string.format("%s %s -o %s", curl, bingwallpaper.url[i], bingwallpaper.path[i])
                easy_async(cmd, function(stdout, stderr, reason, exit_code)
                    --naughty.notify({ title = exit_code })
                    if exit_code == 0 and file_length(bingwallpaper.path[i]) ~= 0 then
                        --naughty.notify({ title = 'DL-OK ' .. bingwallpaper.path[i]})
                        setting(bingwallpaper)
                    else
                        naughty.notify({ title = 'DL-NO ' .. bingwallpaper.path[i]})
                        os.remove(bingwallpaper.path[i])
                        bingwallpaper.update()
                    end
                end)
            end
        end
    end

    bingwallpaper.timer_info = timer({ timeout = timeout_info, autostart=true, callback=bingwallpaper.update_info })
    bingwallpaper.timer_info:emit_signal('timeout')

    return bingwallpaper
end

-- BingSlide: Use images in the given dicrectory
local function get_bingslide(screen, args)
    local bingslide = { screen=screen, path=nil, using=nil }
    local args      = args or {}
    local bingdir   = args.bingdir or nil
    local imagetype = args.imagetype or {'jpg', 'jpeg', 'png'}
    local filter    = args.filter or '.*'
    local async_update  = args.async_update or false
    local setting   = args.setting or function(bs)
        gears.wallpaper.maximized(bs.path[bs.using], bs.screen, true)
    end

    function bingslide.update_info()
        if type(bingdir) ~= 'string' then
            return false
        end
        local pfile, i = io.popen('ls -a "' .. bingdir .. '"'), 0
        bingslide.path = {}
        for filename in pfile:lines() do
            if string.match(filename, filter) ~= nil then
                local ext = string.gsub(filename, "(.*%.)(.*)", "%2")
                for _, it in pairs(imagetype) do
                    if ext == it then
                        i = i + 1
                        bingslide.path[i] = bingdir .. '/' .. filename
                        --naughty.notify({ title = bingslide.path[i]})
                    end
                end
            end
        end
        pfile:close()
    end

    function bingslide.update()
        if bingslide.path == nil then
            bingslide.update_info()
        end
        local i = next(bingslide.path, bingslide.using)
        if i == nil then
            i = next(bingslide.path, i)
        end
        if i == nil then
            -- bingslide.path is empty
            return false
        end
        bingslide.using = i
        if file_exists(bingslide.path[i]) and file_length(bingslide.path[i]) ~= 0 then
            easy_async('echo', function(stdout, stderr, reason, exit_code)
                --naughty.notify({ title = 'OK ' .. bingslide.path[i]})
                setting(bingslide)
            end)
        else
            --naughty.notify({ title = 'NO ' .. bingslide.path[i]})
            bingslide.update()
        end
    end

    if async_update then
        bingslide.update()
    end

    return bingslide
end

-- MISC Wallpapers
local miscwallpaper_available = {
    ['bingwallpaper'] = get_bingwallpaper,
    ['bingwallpaper-360chrome'] = function(screen, args)
        args.api = args.api or "http://wallpaper.apc.360.cn/index.php"
        args.curl = args.curl or 'curl -f -s -m 30' -- max-time 30 for 4K
        args.query = args.query or { c='WallPaper', a='getAppsByCategory',
                                     cid=36, start=100, count=20, from='360chrome' }
        args.choices = args.choices or simple_range(1, 20, 1)
        args.get_url = args.get_url or function(bwp, data, choice)
            if data['data'][choice] then
                return string.gsub(data['data'][choice]['url'], "(.*/)__85(/.*)", "%1__90%2")
            else
                return nil
            end
        end
        args.get_name = args.get_name or function(bwp, data, choice)
            if data['data'][choice] then
                local name = string.gsub(bwp.url[choice], "(.*/)(.*)", "-%2")
                return data['data'][choice]['class_id'] .. '-' ..
                    string.gsub(data['data'][choice]['utag'], ' ', '_') .. name
            else
                return nil
            end
        end
        return get_bingwallpaper(screen, args)
    end,
    ['bingwallpaper-baidu'] = function(screen, args)
        args.api = args.api or "http://image.baidu.com/search/acjson"
        args.query = args.query or {
            tn='resultjson_com', cg='wallpaper', ipn='rj',
            word='壁纸+不同风格+简约',
            pn=0, rn=30, width=s.geometry.width, height=s.geometry.height }
        args.choices = args.choices or simple_range(1, 30, 1)
        args.get_url = args.get_url or function(bwp, data, choice)
            if data['data'][choice] then
                return baidu_url_uncompile(data['data'][choice]['objURL'])
            else
                return nil
            end
        end
        args.get_name = args.get_name or function(bwp, data, choice)
            if bwp.url[choice] then
                local name = string.gsub(bwp.url[choice], "(.*/)(.*)", "-%2")
                name = string.gsub(name, '%?down$', "")
                return string.gsub(data['queryExt'], " ", "_") .. name
            else
                return nil
            end
        end
        return get_bingwallpaper(screen, args)
    end,
    ['bingwallpaper-nationalgeographic'] = function(screen, args)
        args.api = args.api or "https://www.nationalgeographic.com/photography/photo-of-the-day/_jcr_content/.gallery.json"
        --api = "https://www.nationalgeographic.com/photography/photo-of-the-day/_jcr_content/.gallery.2017-08.json"
        args.query = args.query or {}
        args.choices = args.choices or simple_range(1, 8, 1)
        args.get_url = args.get_url or function(bwp, data, choice)
            if data['items'][choice] then
                if bwp.force_hd then
                    return data['items'][choice]['url'] .. data['items'][choice]['sizes']['2048']
                else
                    return data['items'][choice]['url'] .. data['items'][choice]['sizes']['1024']
                end
            else
                return nil
            end
        end
        args.get_name = args.get_name or function(bwp, data, choice)
            if data['items'][choice] then
                local name = data['items'][choice]['publishDate'] .. '_' .. data['items'][choice]['title']
                name = string.gsub(name, ",", "")
                name = string.gsub(name, " ", "-")
                if bwp.force_hd then
                    return name .. '_2048.jpg'
                else
                    return name .. '_1024.jpg'
                end
            else
                return nil
            end
        end
        return get_bingwallpaper(screen, args)
    end,
    ['bingwallpaper-spotlight'] = function(screen, args)
        args.api = args.api or "https://arc.msn.com/v3/Delivery/Cache"
        args.curl = args.curl or 'curl -f -s -m 10 --header "User-Agent: WindowsShellClient"'
        args.query = args.query or { fmt='json', lc='zh-CN', ctry='CN', pid=279978 }
        args.choices = args.choices or { 1, 2, 3, 4 }
        args.get_url = args.get_url or function(bwp, data, choice)
            if data['batchrsp']['items'][choice] then
                local item, pos, err = json.decode(data['batchrsp']['items'][choice]['item'], 1, nil)
                return item['ad']['image_fullscreen_001_landscape']['u'] -- drop 002 ...
            else
                return nil
            end
        end
        args.get_name = args.get_name or function(bwp, data, choice)
            if bwp.url[choice] then
                return string.gsub(bwp.url[choice], "(.*/)(.*)%?.*=(.*)", "%2_%3.jpg")
            else
                return nil
            end
        end
        return get_bingwallpaper(screen, args)
    end,
    -- Need to sign up
    -- bingwallpaper-unsplash
    -- -- https://unsplash.com/documentation
    -- -- client_id, curl xxx -d ''
    -- bingwallpaper-pixabay
    -- -- https://pixabay.com/api/docs/
    -- -- key, orientation
    ['bingslide'] = get_bingslide,
}

local function get_miscwallpaper(screen, wallpapers, args)
    local miscwallpaper = { screen=screen, walls={}, using=nil }
    local timeout = args.timeout or 60
    local wallpapers_on = {}
    local i, j, fun, wall
    for i=1,#wallpapers do
        if wallpapers[i].weight and wallpapers[i].weight > 0 then
            table.insert(wallpapers_on, wallpapers[i])
        end
    end
    miscwallpaper.random = args.random or false
    if miscwallpaper.random then
        math.randomseed(os.time())
        miscwallpaper.using =math.random(1,#wallpapers_on)
    else
        miscwallpaper.using = 1
    end
    for i=1,#wallpapers_on do
        fun = miscwallpaper_available[wallpapers_on[i].walltype]
        if fun then
            if i == miscwallpaper.using then
                wallpapers_on[i].args.async_update = true
            end
            wall = fun(screen, wallpapers_on[i].args)
            for j=1,wallpapers_on[i].weight do
                table.insert(miscwallpaper.walls, wall)
            end
        end
    end

    function miscwallpaper.update()
        if #miscwallpaper.walls == 0 then
            return false
        end
        if miscwallpaper.random then
            miscwallpaper.using = math.random(1,#miscwallpaper.walls)
        else
            miscwallpaper.using = next(miscwallpaper.walls, miscwallpaper.using)
            if miscwallpaper.using == nil then
                miscwallpaper.using = next(miscwallpaper.walls, nil)
            end
        end
        local wall = miscwallpaper.walls[miscwallpaper.using]
        if wall then
            wall.update()
        else
            miscwallpaper.update()
        end
    end

    miscwallpaper.timer = timer({ timeout = timeout, autostart=true, callback=miscwallpaper.update })

    return miscwallpaper
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
    -- miscwallpaper, example
    if s.index == 9999 then
        s.miscwallpaper = get_miscwallpaper(s, {
            {
                walltype='bingwallpaper',
                weight=1,
                args={
                    -- idx: TOMORROW=-1, TODAY=0, YESTERDAY=1, ... 7
                    query = { format='js', idx=-1, n=8 },
                    cachedir = os.getenv("HOME") .. "/.cache/wallpaper-bing",
                    force_hd = true,
                },
            },
            {
                walltype='bingwallpaper-360chrome',
                weight=1,
                args={
                    query = {
                        c='WallPaper', a='getAppsByCategory',
                        -- cid: http://cdn.apc.360.cn/index.php?c=WallPaper&a=getAllCategoriesV2&from=360chrome
                        -- "4K专区"=36, "美女模特"=6, "爱情美图"=30,
                        -- "风景大片"=9, "小清新"=15, "萌宠动物"=14, ...
                        cid=36,
                        start=100, count=20, from='360chrome',
                    },
                    choices = simple_range(1, 20, 1),
                    cachedir = os.getenv("HOME") .. "/.cache/wallpaper-360chrome",
                },
            },
            {
                walltype='bingwallpaper-baidu',
                weight=1,
                args={
                    query = {
                        tn='resultjson_com', cg='wallpaper', ipn='rj',
                        word='壁纸+不同风格+简约',
                        pn=0, rn=30,
                        width=1920, height=1080,
                        --width=s.geometry.width, height=s.geometry.height,
                        -- ic: http://img1.bdstatic.com/static/searchresult/pkg/result_xxxxxxx.js
                        -- red: 1, orange: 256, yellow: 2, green: 4, blue: 16,
                        -- gray: 128, white: 1024, black: 512, bw: 2048, ...
                        --ic=1,
                    },
                    choices = simple_range(1, 30, 1),
                    cachedir = os.getenv("HOME") .. "/.cache/wallpaper-baidu",
                },
            },
            {
                walltype='bingwallpaper-nationalgeographic',
                weight=1,
                args={
                    --query = {},
                    choices = simple_range(1, 28, 1),
                    cachedir = os.getenv("HOME") .. "/.cache/wallpaper-nationalgeographic",
                    force_hd = true,
                },
            },
            {
                walltype='bingwallpaper-spotlight',
                weight=1,
                args={
                    query = {
                        fmt='json', lc='zh-CN', ctry='CN',
                        pid=279978, --pid: 209562, 209567, 279978
                    },
                    choices = { 1, 2, 3, 4 },
                    cachedir = os.getenv("HOME") .. "/.cache/wallpaper-spotlight",
                    timeout_info  = 1200,
                },
            },
            {
                walltype='bingslide',
                weight=1,
                args={
                    --bingdir = os.getenv("HOME") .. "/.cache/wallpaper-bing",
                    --bingdir = os.getenv("HOME") .. "/.cache/wallpaper-lovebizhi",
                    bingdir = os.getenv("HOME") .. "/.config/awesome/themes/think",
                },
            },
        }, {
            timeout = 300,
            random = true,
        })
    end
    -- screen 1
    if s.index == 1 then
        s.miscwallpaper = get_miscwallpaper(s, {
            {
                walltype='bingwallpaper',
                weight=2,
                args={
                    query = { format='js', idx=-1, n=8 },
                    cachedir = os.getenv("HOME") .. "/.cache/wallpaper-bing",
                    force_hd = true,
                },
            },
            {
                walltype='bingslide',
                weight=2,
                args={
                    bingdir = os.getenv("HOME") .. "/.cache/wallpaper-bing",
                    filter='^2018',
                },
            },
        }, {
            timeout = 300,
        })
    end
    -- screen 2
    if s.index == 2 then
        s.miscwallpaper = get_miscwallpaper(s, {
            {
                walltype='bingwallpaper-360chrome',
                weight=2,
                args={ cachedir = os.getenv("HOME") .. "/.cache/wallpaper-360chrome" },
            },
            {
                walltype='bingslide',
                weight=2,
                args={
                    bingdir = os.getenv("HOME") .. "/.cache/wallpaper-bing",
                    filter='^2017',
                },
            },
            {
                walltype='bingslide',
                weight=2,
                args={
                    bingdir = os.getenv("HOME") .. "/.cache/wallpaper-lovebizhi",
                    filter = '^风光风景',
                },
            },
        }, {
            timeout = 300,
            random = true,
        })
    end
end
