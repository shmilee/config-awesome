local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local lain = require("lain")
local helpers = require("lain.helpers")
local awaywidget = require("away.widget")

-- get device table in path/prefix*
local function get_device(path,prefix)
    local cmd = 'ls -d ' .. path ..'/' .. prefix .. '* 2>/dev/null | sed "s|' .. path .. '/||"'
    local f = io.popen(cmd)
    local _array = f:read("*all")
    f:close()
    local _table = {}
    local w
    for w in string.gmatch(_array, "[%w_]+") do
        table.insert(_table,w)
    end
    return _table
end

local markup = lain.util.markup
local separators = lain.util.separators

-- Separators
local spr  = wibox.widget.textbox(' ')
local arrl_dl = separators.arrow_left(beautiful.bg_focus, "alpha")
local arrl_ld = separators.arrow_left("alpha", beautiful.bg_focus)
local arrr = separators.arrow_right(beautiful.bg_focus, "alpha")

-- Create a textclock widget
local mytextclock = wibox.widget.textclock(" %H:%M:%S ",1)

-- lunar
local mylunar = awaywidget.lunar({
    timeout  = 10800,
    font ='Ubuntu Mono 12',
})
mylunar:attach(mylunar.wtext)

-- Calendar
lain.widget.calendar({
    cal = '/usr/bin/env TERM=linux /usr/bin/cal --color=always',
    attach_to = {mytextclock},
    notification_preset = {
        font = 'Ubuntu Mono 12',
        fg   = beautiful.fg_normal,
        bg   = beautiful.bg_normal},
    followtag = true})

-- Net
--local netdownicon = wibox.widget.imagebox(beautiful.netdown)
--local netdowninfo = wibox.widget.textbox()
--local netupicon = wibox.widget.imagebox(beautiful.netup)
--local netupinfo = lain.widget.net({
--    notify   = "off",
--    settings = function()
--        net_sent = tonumber(net_now.sent) / 1024
--        net_rece = tonumber(net_now.received) / 1024
--        if net_sent > 1 then
--            widget:set_markup(markup("#e54c62", string.format("%.1f",net_sent) .. "M "))
--        else
--            widget:set_markup(markup("#e54c62", net_now.sent .. "K "))
--        end
--        if net_rece > 1 then
--            netdowninfo:set_markup(markup("#87af5f", string.format("%.1f",net_rece) .. "M "))
--        else
--            netdowninfo:set_markup(markup("#87af5f", net_now.received .. "K "))
--        end
--    end
--})

-- MEM
local memicon   = wibox.widget.imagebox(beautiful.mem)
local mem = lain.widget.mem({
    settings = function()
        mem_used = tonumber(mem_now.used) / 1024
        mem_prec = tonumber(mem_now.used) / tonumber(mem_now.total) * 100
        if mem_used > 1 then
            widget:set_markup(markup("#e0da37", string.format("%.2f",mem_used) .. "G(".. string.format("%.0f",mem_prec) .. "%)"))
        else
            widget:set_markup(mem_now.used .. "M(".. string.format("%.0f",mem_prec) .. "%)")
        end
    end
})

-- CPU
local cpuicon = wibox.widget.imagebox(beautiful.cpu)
local cpu = lain.widget.cpu({
    settings = function()
        cpu_usage = tonumber(cpu_now.usage)
        if cpu_usage > 50 then
            widget:set_markup(markup("#e33a6e", cpu_now.usage .. "% "))
        else
            widget:set_markup(cpu_now.usage .. "% ")
        end
    end
})
-- Coretemp
local temp_device = get_device('/sys/class/thermal','thermal_zone')
temp_device = temp_device[#temp_device]
local tempicon    = wibox.widget.imagebox(beautiful.temp)
local temp  = lain.widget.temp({
    tempfile = "/sys/class/thermal/" .. temp_device .. "/temp",
    settings = function()
        core_temp = tonumber(string.format("%.0f",coretemp_now))
        if core_temp >70 then
            widget:set_markup(markup("#D91E1E", core_temp .. "°C "))
        elseif core_temp >50 then
            widget:set_markup(markup("#f1af5f", core_temp .. "°C "))
        else
            widget:set_markup(core_temp .. "°C ")
        end
    end
})

-- ALSA volume
local volicon = wibox.widget.imagebox(beautiful.vol)
volume = lain.widget.alsa({
    settings = function()
        if volume_now.status == "off" then
            volicon:set_image(beautiful.vol_mute)
            widget:set_markup(markup("#EB8F8F", volume_now.level .. "% "))
        elseif tonumber(volume_now.level) == 0 then
            volicon:set_image(beautiful.vol_no)
            widget:set_markup(markup("#EB8F8F", volume_now.level .. "% "))
        elseif tonumber(volume_now.level) <= 50 then
            volicon:set_image(beautiful.vol_low)
            widget:set_markup(markup("#7493D2", volume_now.level .. "% "))
        else
            volicon:set_image(beautiful.vol)
            widget:set_markup(markup(beautiful.fg_normal, volume_now.level .. "% "))
        end
        if volume_now.status == "off" then
            os.execute(string.format("volnoti-show -m"))
        else
            os.execute(string.format("volnoti-show %s", volume_now.level))
        end

    end
})
volume.step = "2%"
volume.widget:buttons (gears.table.join (
    awful.button ({}, 1, function()
      awful.spawn(terminal .. " -e alsamixer")
    end),
    awful.button ({}, 3, function()
      os.execute(string.format("amixer -q set %s playback toggle", volume.channel))
      volume.update()
    end),
    awful.button ({}, 4, function()
      os.execute(string.format("amixer -q set %s %s+", volume.channel, volume.step))
      volume.update()
    end),
    awful.button ({}, 5, function()
      os.execute(string.format("amixer set %s %s-", volume.channel, volume.step))
      volume.update()
    end)
))

-- battery
local battery = awaywidget.battery({font ='Ubuntu Mono 12'})
battery:attach(battery.wicon)

-- available weather module's query
local weather_querys = {
    etouch = {
        citykey=101210101, --杭州
    },
    meizu = {
        cityIds=101210101,
    },
    tianqi = {
        version='v1',
        cityid= 101210101,
    },
    xiaomiv2 = {
        cityId=101210101,
    },
    xiaomiv3 ={
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
local weather = awaywidget.weather['tianqi']({
    timeout = 600, -- 10 min
    query = weather_querys['tianqi'],
    --curl = 'curl -f -s -m 1.7'
    --font ='Ubuntu Mono 12',
    --get_info = function(weather, data) end,
    --setting = function(weather) end,
})
weather:attach(weather.wicon)

function createmywibox(s)
    s.mywibox = awful.wibar({ position = "top", screen = s, height =20, opacity = 0.88 })

    s.mywibox.rightwidgets = {
        layout = wibox.layout.fixed.horizontal,
        --mykeyboardlayout,
    }
    -- setting
    s.mywibox.enablewidgets = {
        {memicon, mem.widget},
        {cpuicon, cpu.widget},
        {tempicon, temp.widget},
        {volicon, volume.widget},
        {battery.wicon, battery.wtext},
        {wibox.widget.systray(), weather.wicon, weather.wtext},
        {mylunar.wtext, mytextclock},
        {s.mylayoutbox},
    }
    local right_layout_toggle = true
    local wg, w
    for _, wg in ipairs(s.mywibox.enablewidgets) do
        if right_layout_toggle then
            table.insert(s.mywibox.rightwidgets, arrl_ld)
            for _, w in ipairs(wg) do
                table.insert(s.mywibox.rightwidgets, wibox.container.background(w, beautiful.bg_focus))
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
