local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local lain = require("lain")
local widgets = require("widgets")
local helpers = require("lain.helpers")
beautiful.init(os.getenv("HOME") .. "/.config/awesome/theme.lua")

-- get device table in path/prefix*
local function get_device(path,prefix)
    local cmd = 'ls -d ' .. path ..'/' .. prefix .. '* 2>/dev/null | sed "s|' .. path .. '/||"'
    local _array = helpers.read_pipe(cmd)
    local _table = {}
    local w
    for w in string.gmatch(_array, "[%w_]+") do
        table.insert(_table,w)
    end
    return _table
end

markup = lain.util.markup
separators = lain.util.separators

-- Separators
spr  = wibox.widget.textbox(' ')
arrl_dl = separators.arrow_left(beautiful.bg_focus, "alpha")
arrl_ld = separators.arrow_left("alpha", beautiful.bg_focus)
arrr = separators.arrow_right(beautiful.bg_focus, "alpha")

-- Create a textclock widget
mytextclock = awful.widget.textclock(" %H:%M:%S ",1)

-- lunar
lunar = widgets.lunar({
    timeout  = 10800,
    settings = function()
        widget:set_markup(lunar_now.month .. lunar_now.day)
    end
})

-- Calendar
lain.widgets.calendar:attach(mytextclock, {font = 'Ubuntu Mono', followmouse = true})

-- Net
--netdownicon = wibox.widget.imagebox(beautiful.netdown)
--netdowninfo = wibox.widget.textbox()
--netupicon = wibox.widget.imagebox(beautiful.netup)
--netupinfo = lain.widgets.net({
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
memicon   = wibox.widget.imagebox(beautiful.mem)
memwidget = lain.widgets.mem({
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
cpuicon = wibox.widget.imagebox()
cpuicon:set_image(beautiful.cpu)
cpuwidget = lain.widgets.cpu({
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
tempicon    = wibox.widget.imagebox(beautiful.temp)
tempwidget  = lain.widgets.temp({
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

-- Battery
BAT_table   = get_device('/sys/class/power_supply','BAT')
baticon = wibox.widget.imagebox(beautiful.bat)
batwidget = widgets.dualbat({
    batterys     = BAT_table,
    followmouse  = true,
    settings = function()
        if bat_now.perc == "N/A" then
            bat_now.icon = beautiful.ac
            widget:set_markup(" AC ")
        else
            bat_perc = tonumber(bat_now.perc)
            if bat_perc > 50 then
                widget:set_markup(" " .. bat_now.perc .. "% ")
                bat_now.icon = beautiful.bat
            elseif bat_perc > 15 then
                widget:set_markup(markup("#EB8F8F", bat_now.perc .. "% "))
                bat_now.icon = beautiful.bat_low
            else
                widget:set_markup(markup("#D91E1E", bat_now.perc .. "% "))
                bat_now.icon = beautiful.bat_no
            end
        end
        if bat_now.ac_status == "1" or bat_now.status == "Charging" then
            bat_now.icon = beautiful.ac
        end
        baticon:set_image(bat_now.icon)
    end
})
batwidget.attach(baticon)
batwidget.attach(batwidget)

-- ALSA volume
volicon = wibox.widget.imagebox(beautiful.vol)
volumewidget = lain.widgets.alsa({
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
    end
})
volume = {
    channel = volumewidget.channel,
    step = "2%",
    mynotify = function()
        volumewidget.update()
        if volume_now.status == "off" then
            os.execute(string.format("volnoti-show -m"))
        else
            os.execute(string.format("volnoti-show %s", volume_now.level))
        end
    end
}

-- ALSA volume bar
--volicon = wibox.widget.imagebox(beautiful.vol)
--volume  = lain.widgets.alsabar({
--    width = 30, ticks = true, ticks_size = 3, step = "2%",
--    followmouse = true,
--    settings = function()
--        if volume_now.status == "off" then
--            volicon:set_image(beautiful.vol_mute)
--        elseif volume_now.level == 0 then
--            volicon:set_image(beautiful.vol_no)
--        elseif volume_now.level <= 50 then
--            volicon:set_image(beautiful.vol_low)
--        else
--            volicon:set_image(beautiful.vol)
--        end
--    end,
--    colors =
--    {
--        background = beautiful.bg_focus,
--        mute       = "#EB8F8F",
--        unmute     = beautiful.fg_normal
--    }
--})
--volmargin = wibox.layout.margin(volume.bar, 1, 1)
--volmargin:set_top(6)
--volmargin:set_bottom(6)
--volumewidget = wibox.widget.background(volmargin)
--volumewidget:set_bgimage(beautiful.widget_bg)
--function volume.mynotify()
--    volume.notify()
--    if volume._muted then
--        os.execute(string.format("volnoti-show -m"))
--    else
--        os.execute(string.format("volnoti-show %s", volume_now.level))
--    end
--end

-- Weather
weather = 'cn'
if weather == 'cn' then
    yawn = widgets.cnweather({
        --timeout = 600,            -- 10 min
        --timeout_forecast = 18000, -- 5 hrs
        api         = 'etouch',     -- etouch, lib360, xiaomi
        city        = '杭州',       -- for etouch, lib360
        cityid      = 101210101,    -- for xiaomi
        city_desc   = '杭州市',     -- desc for the city
        followmouse = true
    })
else
    yawn = widgets.yhweather({
        country     = 'China',
        city        = 'HangZhou',
        unit        = 'c',
        theme       = 'yhlight',
        followmouse = true
    })
end
yawn.attach(yawn.icon)
