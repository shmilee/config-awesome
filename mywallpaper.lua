--[[
     Licensed under GNU General Public License v2
      * (c) 2017, shmilee                         
--]]

local beautiful  = require("beautiful")
local gears      = require("gears")
local easy_async = require("awful.spawn").easy_async
local newtimer   = require("lain.helpers").newtimer
local json       = require("lain.util").dkjson
--local naughty    = require("naughty")

local io     = { popen = io.popen, open = io.open }
local math   = { max  = math.max }
local string = { format = string.format, gsub = string.gsub }
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

-- BingWallPaper: fetch Bing's images with meta data
local function get_bingwallpaper(screen, args)
    local bingwallpaper = { screen=screen, url=nil, path=nil, using=nil }
    local args          = args or {}
    local api           = args.api or 'https://www.bing.com/HPImageArchive.aspx'
    local query         = args.query or { format='js', idx=0, n=8 }
    local choices       = args.choices or { 1, 2, 3, 4, 5, 6, 7, 8 }
    local curl          = args.curl or 'curl -f -s -m 10'
    local cachedir      = args.cachedir or '/tmp'
    local timeout       = args.timeout or 60
    local timeout_info  = args.timeout_info or 86400
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
            if i == nil  or bingwallpaper.path[i] == nil then
                -- bingwallpaper.url is empty, Net Unreachable
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
                        --naughty.notify({ title = 'DL-NO ' .. bingwallpaper.path[i]})
                        bingwallpaper.update()
                    end
                end)
            end
        end
    end

    bingwallpaper.timer = newtimer("bingwallpaper-info-" .. screen.index, timeout_info, bingwallpaper.update_info, false, true)
    bingwallpaper.timer = newtimer("bingwallpaper-" .. screen.index, timeout, bingwallpaper.update, false, true)

    return bingwallpaper
end

-- BingSlide: Use images in the given dicrectory
local function get_bingslide(screen, args)
    local bingslide = { screen=screen, path=nil, using=nil }
    local args      = args or {}
    local bingdir   = args.bingdir or nil
    local imagetype = args.imagetype or {'jpg', 'png'}
    local timeout   = args.timeout or 60
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
            local ext = string.gsub(filename, "(.*%.)(.*)", "%2")
            for _, it in pairs(imagetype) do
                if ext == it then
                    i = i + 1
                    bingslide.path[i] = bingdir .. '/' .. filename
                    --naughty.notify({ title = bingslide.path[i]})
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

    bingslide.timer = newtimer("bingslide-" .. screen.index, timeout, bingslide.update, false, true)

    return bingslide
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
    -- bingslide
    if s.index == 100 then
        s.bingslide = get_bingslide(s, {
            --bingdir = os.getenv("HOME") .. "/.cache/wallpaper-bing",
            --bingdir = os.getenv("HOME") .. "/.cache/wallpaper-lovebizhi",
            bingdir = os.getenv("HOME") .. "/.config/awesome/themes/think",
            timeout = 300,
        })
    end
    -- bingwallpaper: bing
    if s.index == 1 then
        s.bingwallpaper = get_bingwallpaper(s, {
            -- idx: TOMORROW=-1, TODAY=0, YESTERDAY=1, ... 7
            query = { format='js', idx=-1, n=8 },
            cachedir = os.getenv("HOME") .. "/.cache/wallpaper-bing",
            timeout = 300,
            force_hd = true,
        })
    end
    -- bingwallpaper: lovebizhi
    if s.index == 2 then
        s.bingwallpaper = get_bingwallpaper(s, {
            api = "http://api.lovebizhi.com/macos_v4.php",
            query = {
                a='category',
                -- tid: moviestar=1, landscape=2, beauty=3, plant=4,
                -- animal=5, game=6, cartoon=7, festival=8, ... 39 ...
                tid=4,
                uuid='686eb2caaa6d11e78665605718e08fa3',
                retina=1, client_id=1008, order='hot',
                screen_width=s.geometry.width,
                screen_height=s.geometry.height,
            },
            choices = simple_range(1, 30, 1), -- { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 },
            get_url = function(bwp, data, choice)
                if data['data'][choice] then
                    if bwp.force_hd then
                        return data['data'][choice]['image']['diy']
                    else
                        return string.gsub(data['data'][choice]['image']['original'], "(.*)%.webp", "%1.jpg")
                    end
                else
                    return nil
                end
            end,
            get_name = function(bwp, data, choice)
                if data['data'][choice] then
                    local name = string.gsub(bwp.url[choice], "(.*/)(.*)", "_%2")
                    return data['name'] .. string.gsub(name, ",", "_")
                else
                    return nil
                end
            end,
            cachedir = os.getenv("HOME") .. "/.cache/wallpaper-lovebizhi",
            timeout = 300,
            force_hd = true,
        })
    end
    -- bingwallpaper: baidu
    if s.index == 100 then
        s.bingwallpaper = get_bingwallpaper(s, {
            api = "https://image.baidu.com/channel/listjson",
            query = {
                tag1='壁纸', tag2='唯美', -- ftags='风景',
                pn=0, rn=30,
                width=s.geometry.width, height=s.geometry.height,
            },
            choices = simple_range(1, 30, 1), -- { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 },
            get_url = function(bwp, data, choice)
                if data['data'][choice] then
                    return data['data'][choice]['download_url']
                else
                    return nil
                end
            end,
            get_name = function(bwp, data, choice)
                if data['data'][choice] then
                    return data['data'][choice]['abs'] .. '_' .. data['data'][choice]['id'] .. '.jpg'
                else
                    return nil
                end
            end,
            cachedir = os.getenv("HOME") .. "/.cache/wallpaper-baidu",
            timeout = 300,
        })
    end
    -- bingwallpaper: nationalgeographic
    if s.index == 100 then
        s.bingwallpaper = get_bingwallpaper(s, {
            api = "http://www.nationalgeographic.com/photography/photo-of-the-day/_jcr_content/.gallery.json",
            --api = "http://www.nationalgeographic.com/photography/photo-of-the-day/_jcr_content/.gallery.2017-08.json",
            query = {},
            choices = simple_range(1, 8, 1),
            get_url = function(bwp, data, choice)
                if data['items'][choice] then
                    if bwp.force_hd then
                        return data['items'][choice]['url'] .. data['items'][choice]['sizes']['2048']
                    else
                        return data['items'][choice]['url'] .. data['items'][choice]['sizes']['1024']
                    end
                else
                    return nil
                end
            end,
            get_name = function(bwp, data, choice)
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
            end,
            cachedir = os.getenv("HOME") .. "/.cache/wallpaper-nationalgeographic",
            timeout = 300,
            force_hd = true,
        })
    end
    -- bingwallpaper: spotlight
    if s.index == 100 then
        s.bingwallpaper = get_bingwallpaper(s, {
            api = "https://arc.msn.com/v3/Delivery/Cache",
            curl = 'curl -f -s -m 10 --header "User-Agent: WindowsShellClient"',
            query = {
                fmt='json', lc='zh-CN', ctry='CN',
                pid=279978, --pid: 209562, 209567, 279978
            },
            choices = { 1, 2, 3, 4 },
            get_url = function(bwp, data, choice)
                if data['batchrsp']['items'][choice] then
                    local item, pos, err = json.decode(data['batchrsp']['items'][choice]['item'], 1, nil)
                    return item['ad']['image_fullscreen_001_landscape']['u'] -- drop 002 ...
                else
                    return nil
                end
            end,
            get_name = function(bwp, data, choice)
                if bwp.url[choice] then
                    return string.gsub(bwp.url[choice], "(.*/)(.*)%?.*=(.*)", "%2_%3.jpg")
                else
                    return nil
                end
            end,
            cachedir = os.getenv("HOME") .. "/.cache/wallpaper-spotlight",
            timeout = 300,
            timeout_info  = 1200,
        })
    end
end
