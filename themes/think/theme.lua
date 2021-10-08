-------------------------------
--  "think" awesome theme  --
--        By shmilee       --
-------------------------------

local away  = require("away")
local lain  = require("lain")
local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local dpi   = require("beautiful").xresources.apply_dpi
local os    = {
    date = os.date,
    time = os.time,
    setlocale = os.setlocale,
    getenv = os.getenv,
    execute = os.execute,
}

-- inherit zenburn theme
local theme = dofile("/usr/share/awesome/themes/zenburn/theme.lua")

-- {{{ Main
theme.dir       = os.getenv("HOME") .. "/.config/awesome/themes/think"
-- }}}

-- {{{ Wallpaper
theme.wallpaper_fallback = {
    theme.dir .. "/think-1920x1200.jpg",
    theme.dir .. "/violin-1920x1080.jpg",
}

local function set_videowall_s1(s)
    --if true then return end
    s.videowallpaper = away.wallpaper.get_videowallpaper(s, {
        path = os.getenv("HOME") ..'/视频/Futari.Dake.No.Hanabi.mp4',
        xargs = {'-b -ov -ni -nf -un -s -st -sp -o 0.816'},
        after_prg = 'conky\\s+-c\\s+.*/awesome/conky.lua',
    })
end
local function set_videowall_s2(s)
    if true then return end
    s.videowallpaper = away.wallpaper.get_bilivideowallpaper(s, {
        path='https://live.bilibili.com/9196015',
        --choices = {'flv'},
    })
    if true then return end
    --http://fy4.nsmc.org.cn/portal/cn/theme/FY4A.html
    s.videowallpaper = away.wallpaper.get_videowallpaper(s, {
        -- 3h, 6h, 12h, 24h, 48h, 72h
        path = 'http://img.nsmc.org.cn/CLOUDIMAGE/FY4A/MTCC/VIDEO/FY4A.disk.24h.mp4',
        --path = 'http://img.nsmc.org.cn/CLOUDIMAGE/FY4A/MTCC/VIDEO/FY4A.china.24h.mp4',
        ---path = 'http://img.nsmc.org.cn/CLOUDIMAGE/GEOS/MOS/IRX/VIDEO/GEOS.MOS.IRX.GBAL.24h.mp4',
        xargs = {'-b -ov -ni -nf -un -s -st -sp -o 0.98'},
        pargs = {
            '-wid WID --stop-screensaver=no',
            '--hwdec=auto --hwdec-codecs=all',
            '--no-audio --no-osc --no-osd-bar --no-input-default-bindings',
            '--loop-file --speed=0.2',
        },
        after_prg = 'conky\\s+-c\\s+.*/awesome/conky.lua',
        timeout = 3600*12,
    })
end

theme.wallpaper = function(s)
    -- screen 1
    if s.index % 2 == 1 then
        s.miscwallpaper = away.wallpaper.get_miscwallpaper(s, { timeout=300 }, {
            {
                name = 'bing', weight = 2,
                args = {
                    -- idx: TOMORROW=-1, TODAY=0, YESTERDAY=1, ... 7
                    query = { format='js', idx=-1, n=8 },
                    --cachedir = os.getenv("HOME") .. "/.cache/wallpaper-bing",
                    force_hd = true,
                },
            },
            {
                name = 'local', weight = 1,
                args = {
                    id = 'Local bing',
                    dirpath = os.getenv("HOME") .. "/.cache/wallpaper-bing",
                    filter = os.date('^%Y%m',os.time()-365*24*3600),
                    --ls = 'ls -r',
                },
            },
            {
                name = 'local', weight = 2,
                args = {
                    id = 'Local 360chrome',
                    dirpath = os.getenv("HOME") .. "/.cache/wallpaper-360chrome",
                    --filter = '^$',
                    ls = 'ls -r',
                },
            },
        })
        set_videowall_s1(s)
        return theme.wallpaper_fallback[1]
    -- screen 2
    else
        s.miscwallpaper = away.wallpaper.get_miscwallpaper(s, { timeout=300, random=true, update_by_tag=false }, {
            {
                name = '360chrome', weight = 2,
                --args = {},
            },
            {
                name = 'wallhaven', weight = 2,
                args = {
                    query = { q='landscape', atleast='1920x1080', sorting='favorites', page=1 }
                },
            },
            {
                name = 'local', weight = 2,
                args = {
                    id = 'Local bing',
                    dirpath = os.getenv("HOME") .. "/.cache/wallpaper-bing",
                    filter = '^2018',
                },
            },
            {
                name = 'local', weight = 2,
                args = {
                    id = 'Local lovebizhi',
                    dirpath = os.getenv("HOME") .. "/.cache/wallpaper-lovebizhi",
                    filter = '^风光风景',
                },
            },
        })
        set_videowall_s2(s)
        return theme.wallpaper_fallback[2]
    end
end
-- }}}

-- {{{ Styles
theme.font      = "WenQuanYi Micro Hei " ..  dpi(9)
-- }}}

-- {{{ Widgets
-- You can add as many variables as
-- you wish and access them by using
-- beautiful.variable in your rc.lua
theme.ac          = theme.dir .. "/widgets/ac.png"
theme.bat         = theme.dir .. "/widgets/bat.png"
theme.bat_low     = theme.dir .. "/widgets/bat_low.png"
theme.bat_no      = theme.dir .. "/widgets/bat_no.png"
theme.cpu         = theme.dir .. "/widgets/cpu.png"
theme.mem         = theme.dir .. "/widgets/mem.png"
theme.netdown     = theme.dir .. "/widgets/net_down.png"
theme.netup       = theme.dir .. "/widgets/net_up.png"
theme.pause       = theme.dir .. "/widgets/pause.png"
theme.play        = theme.dir .. "/widgets/play.png"
theme.temp        = theme.dir .. "/widgets/temp.png"
theme.vol         = theme.dir .. "/widgets/vol.png"
theme.vol_low     = theme.dir .. "/widgets/vol_low.png"
theme.vol_mute    = theme.dir .. "/widgets/vol_mute.png"
theme.vol_no      = theme.dir .. "/widgets/vol_no.png"
theme.widget_bg   = theme.dir .. "/widgets/widget_bg.png"
-- }}}

-- {{{ Menu
theme.menu_height = dpi(18)
theme.menu_width  = dpi(100)
-- }}}

-- {{{ Misc
theme.awesome_icon      = theme.dir .. "/misc/arch-icon.png"
theme.capslock_on       = theme.dir .. "/misc/capslock_on.png"
theme.capslock_off      = theme.dir .. "/misc/capslock_off.png"
theme.touchpad_on       = theme.dir .. "/misc/touchpad_on.png"
theme.touchpad_off      = theme.dir .. "/misc/touchpad_off.png"
--theme.icon_theme = "Adwaita"
theme.icon_theme = "Faenza"
theme.client_rounded = true
theme.client_rounded_radius =  dpi(8)
-- }}}

-- {{{ Layout
theme.layout_tile       = theme.dir .. "/layouts/tile.png"
theme.layout_tileleft   = theme.dir .. "/layouts/tileleft.png"
theme.layout_tilebottom = theme.dir .. "/layouts/tilebottom.png"
theme.layout_tiletop    = theme.dir .. "/layouts/tiletop.png"
theme.layout_fairv      = theme.dir .. "/layouts/fairv.png"
theme.layout_fairh      = theme.dir .. "/layouts/fairh.png"
theme.layout_spiral     = theme.dir .. "/layouts/spiral.png"
theme.layout_dwindle    = theme.dir .. "/layouts/dwindle.png"
theme.layout_max        = theme.dir .. "/layouts/max.png"
theme.layout_fullscreen = theme.dir .. "/layouts/fullscreen.png"
theme.layout_magnifier  = theme.dir .. "/layouts/magnifier.png"
theme.layout_floating   = theme.dir .. "/layouts/floating.png"
local layouts = awful.layout.layouts
theme.layouts = {
    { layouts[1], layouts[1], layouts[2], layouts[1], layouts[1] },
    layouts[2],
    layouts[1],
    layouts[2],
}
-- }}}

-- {{{ Tags
theme.tagnames = {
    { "宫", "商", "角", "徵", "羽" },
    { "壹", "貳", "叄", "肆", "伍", "陸", "柒", "捌", "玖" },
    { "一", "二", "三", "四", "五", "六", "七", "八", "九" },
    {  1, 2, 3, 4, 5, 6, 7, 8, 9, 10 },
}
-- }}}

-- {{{ Create Widgets
local markup = lain.util.markup
local widget_font = 'Ubuntu Mono ' ..  dpi(12)

-- Separators
local separators = lain.util.separators
local spr  = wibox.widget.textbox(' ')
local arrl_dl = separators.arrow_left(theme.bg_focus, "alpha")
local arrl_ld = separators.arrow_left("alpha", theme.bg_focus)
local arrr = separators.arrow_right(theme.bg_focus, "alpha")

-- Create a textclock widget
local mytextclock = wibox.widget.textclock(" %H:%M:%S ",1)

-- Calendar
local mycal = lain.widget.cal({
    attach_to = { mytextclock },
    week_start = 1,
    notification_preset = {
        font = widget_font,
        fg   = theme.fg_normal,
        bg   = theme.bg_normal
    },
    followtag = true,
})
--os.setlocale(os.getenv("LANG"))
mytextclock:disconnect_signal("mouse::enter", mycal.hover_on)

-- lunar
local mylunar = away.widget.lunar({
    timeout  = 10800,
    font = widget_font,
})
mylunar:attach(mylunar.wtext)

-- {{{ Weather
-- available module's query
local weather_querys = {
    etouch = {
        citykey = 101210101, --杭州
    },
    meizu = {
        cityIds = 101210101,
    },
    tianqi = {
        version = 'v1',
        --cityid = 101210101,
        appid = 95327666,
        appsecret = 'ao8FYdtI',
    },
    xiaomiv2 = {
        cityId = 101210101,
    },
    xiaomiv3 = {
        latitude = 0,
        longitude = 0,
        locationKey = 'weathercn:101210101', --杭州
        appKey = 'weather20151024',
        sign = 'zUFJoAR2ZVrDy1vF3D07',
        isGlobal = 'false',
        locale = 'zh_cn',
        days = 6,
    },
}
local chosen_wea = 'tianqi'
local myweather = away.widget.weather[chosen_wea]({
    timeout = 600, -- 10 min
    query = weather_querys[chosen_wea],
    --curl = 'curl -f -s -m 1.7'
    --font = widget_font,
    --get_info = function(weather, data) end,
    --setting = function(weather) end,
})
myweather:attach(myweather.wicon)
-- }}}

-- Battery
local mybattery = away.widget.battery({
    font = widget_font,
})
mybattery:attach(mybattery.wicon)

-- {{{ ALSA volume
local myvolicon = wibox.widget.imagebox(theme.vol)
local myvolume = lain.widget.alsa({
    settings = function()
        if volume_now.status == "off" then
            myvolicon:set_image(theme.vol_mute)
            widget:set_markup(markup("#EB8F8F", volume_now.level .. "% "))
        elseif tonumber(volume_now.level) == 0 then
            myvolicon:set_image(theme.vol_no)
            widget:set_markup(markup("#EB8F8F", volume_now.level .. "% "))
        elseif tonumber(volume_now.level) <= 50 then
            myvolicon:set_image(theme.vol_low)
            widget:set_markup(markup("#7493D2", volume_now.level .. "% "))
        else
            myvolicon:set_image(theme.vol)
            widget:set_markup(markup(theme.fg_normal, volume_now.level .. "% "))
        end
        if volume_now.status == "off" then
            os.execute(string.format("volnoti-show -m"))
        else
            os.execute(string.format("volnoti-show %s", volume_now.level))
        end
    end
})
-- ALSA Buttons
myvolume.step = "2%"
myvolume.widget:buttons (gears.table.join (
    awful.button ({}, 1, function() -- left click
      awful.spawn(terminal .. " -e alsamixer")
    end),
    awful.button({}, 2, function() -- middle click
        os.execute(string.format("amixer -q set %s 100%%", myvolume.channel))
        myvolume.update()
    end),
    awful.button ({}, 3, function() -- right click
      os.execute(string.format("amixer -q set %s playback toggle", myvolume.channel))
      myvolume.update()
    end),
    awful.button ({}, 4, function() -- scroll up
      os.execute(string.format("amixer -q set %s %s+", myvolume.channel, myvolume.step))
      myvolume.update()
    end),
    awful.button ({}, 5, function() -- scroll down
      os.execute(string.format("amixer -q set %s %s-", myvolume.channel, myvolume.step))
      myvolume.update()
    end)
))
-- for ALSA XF86Audio Keybindings
theme.myvolume = myvolume
-- }}}

-- Coretemp
local mytempicon = wibox.widget.imagebox(theme.temp)
local mytemp = lain.widget.temp({
    --tempfile = "/sys/class/thermal/thermal_zone0/temp",
    settings = function()
        if coretemp_now == "N/A" then
            widget:set_markup(core_temp .. "°C ")
            return
        end
        local core_temp = tonumber(string.format("%.0f",coretemp_now))
        if core_temp >70 then
            widget:set_markup(markup("#D91E1E", core_temp .. "°C "))
        elseif core_temp >50 then
            widget:set_markup(markup("#f1af5f", core_temp .. "°C "))
        else
            widget:set_markup(core_temp .. "°C ")
        end
    end
})

-- CPU
local mycpuicon = wibox.widget.imagebox(theme.cpu)
local mycpu = lain.widget.cpu({
    settings = function()
        if cpu_now.usage > 50 then
            widget:set_markup(markup("#e33a6e", cpu_now.usage .. "% "))
        else
            widget:set_markup(cpu_now.usage .. "% ")
        end
    end
})

-- MEM
local mymem = away.widget.memory({
    timeout = 2,
    --settings = function(mymem) end,
})
mymem.wicon:set_image(theme.mem)

-- }}}

function theme.createmywibox(s)
    s.mywibox = awful.wibar({ position = "top", screen = s, height =  dpi(20), opacity = 0.88 })

    s.mywibox.rightwidgets = {
        layout = wibox.layout.fixed.horizontal,
        --mykeyboardlayout,
    }
    if s.videowallpaper then
        table.insert(mybattery.observer.handlers, function(observer, val)
            if observer.status == 'Discharging' then
                s.videowallpaper.kill_and_set() -- save energy
            end
        end)
    end
    -- add widgets
    s.mywibox.enablewidgets = {
        {mymem.wicon, mymem.wtext},
        {mycpuicon, mycpu.widget},
        {mytempicon, mytemp.widget},
        {myvolicon, myvolume.widget},
        {mybattery.wicon, mybattery.wtext},
        {wibox.widget.systray(), myweather.wicon, myweather.wtext},
        {mylunar.wtext, mytextclock},
        {s.mylayoutbox},
    }
    local right_layout_toggle = true
    local wg, w
    for _, wg in ipairs(s.mywibox.enablewidgets) do
        if right_layout_toggle then
            table.insert(s.mywibox.rightwidgets, arrl_ld)
            for _, w in ipairs(wg) do
                table.insert(s.mywibox.rightwidgets, wibox.container.background(w, theme.bg_focus))
            end
        else
            table.insert(s.mywibox.rightwidgets, arrl_dl)
            for _, w in ipairs(wg) do
                table.insert(s.mywibox.rightwidgets, w)
            end
        end
        right_layout_toggle = not right_layout_toggle
    end

    -- Add widgets to the wibox
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            mylauncher,
            s.mytaglist,
            arrr,
            s.mypromptbox,
        },
        s.mytasklist, -- Middle widget
        -- Right widgets
        s.mywibox.rightwidgets
    }
end

local meiriyiwen = away.widget.meiriyiwen({
    font = 'WenQuanYi Micro Hei',
    font_size =  dpi(15),
    ratio = 0,
    height = 0.9,
})
yiwen = meiriyiwen.update

return theme
