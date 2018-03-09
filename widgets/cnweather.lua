
--[[
                                                  
     Licensed under GNU General Public License v2 
      * (c) 2015, shmilee                         
                                                  
--]]

local easy_async = require("awful.spawn").easy_async
local newtimer   = require("lain.helpers").newtimer
local json       = require("lain.util").dkjson
local curdir     = require("widgets.curdir")

local naughty    = require("naughty")
local wibox      = require("wibox")
local focused    = require("awful.screen").focused

local string     = { format = string.format,
                     gsub   = string.gsub,
                     byte   = string.byte }
local math       = { floor  = math.floor }

local setmetatable = setmetatable

-- lain.widgets.contrib.zhweather
-- current weather and forecast

local curl         = 'curl -f -s -m 1.7'

-- http://openweather.weather.com.cn/Home/Help/icon.html
local icon_table   = {
    ["晴"]               = '00',
    ["多云"]             = '01',
    ["阴"]               = '02',
    ["阵雨"]             = '03',
    ["雷阵雨"]           = '04',
    ["雷阵雨伴有冰雹"]   = '05',
    ["雨夹雪"]           = '06',
    ["小雨"]             = '07',
    ["中雨"]             = '08',
    ["大雨"]             = '09',
    ["暴雨"]             = '10',
    ["大暴雨"]           = '11',
    ["特大暴雨"]         = '12',
    ["阵雪"]             = '13',
    ["小雪"]             = '14',
    ["中雪"]             = '15',
    ["大雪"]             = '16',
    ["暴雪"]             = '17',
    ["雾"]               = '18',
    ["冻雨"]             = '19',
    ["沙尘暴"]           = '20',
    ["小到中雨"]         = '21',
    ["中到大雨"]         = '22',
    ["大到暴雨"]         = '23',
    ["暴雨到大暴雨"]     = '24',
    ["大暴雨到特大暴雨"] = '25',
    ["小到中雪"]         = '26',
    ["中到大雪"]         = '27',
    ["大到暴雪"]         = '28',
    ["浮尘"]             = '29',
    ["扬沙"]             = '30',
    ["强沙尘暴"]         = '31',
    ["霾"]               = '53',
    ["无"]               = 'undefined' }

function encodeURI(s)
    local s = string.gsub(s, "([^%w%.%- ])", function(c) return string.format("%%%02X", string.byte(c)) end)
    return string.gsub(s, " ", "+")
end

-- http://www.pm25.com/news/91.html
-- AQI PM2.5 --> Air Pollution Level
local function aqi2apl(aqi)
    aqi = tonumber(aqi)
    if aqi == nil then
        return 'AQI: N/A '
    end
    local aql={'优', '良',   '轻度污染', '中度污染', '重度污染','重度污染', '严重污染'}
    ----  aqi  0-50, 51-100, 101 - 150,  151 - 200,  201 - - 250 - - - 300, 301 - - 500
    local i=math.floor(aqi/50.16)+1
    if i <= 0 then
        return 'AQI: N/A '
    else
        if i > 7 then i = 7 end
        return "空气质量: " .. tostring(aqi) .. ', ' .. aql[i]
    end
end

local function cnweather_forecast(api, city, cityid, callback)
    local notification_text = ''
    local cmd = 'echo'
    local function get_data(f) return notification_text end

    if api == 'etouch' then
        cmd = string.format("%s --compressed 'http://wthrcdn.etouch.cn/weather_mini?citykey=%s'", curl, cityid)
        function get_data(weather_now)
            if not err and type(weather_now) == "table" and weather_now["desc"] == 'OK' then
                for i = 1, #weather_now.data.forecast do
                    local day  = weather_now.data.forecast[i].date
                    local tmin = string.gsub(weather_now.data.forecast[i].low, '低温', '')
                    local tmax = string.gsub(weather_now.data.forecast[i].high, '高温', '')
                    local desc = weather_now.data.forecast[i].type
                    local wind =  weather_now.data.forecast[i].fengli
                    notification_text = notification_text ..
                        string.format("<b>%s</b>:  %s,  %s - %s,  %s ", day, desc, tmin, tmax, wind)
                    if i < #weather_now.data.forecast then
                        notification_text = notification_text .. "\n"
                    end
                end
            end
            return notification_text
        end
    elseif api == 'xiaomi' then
        cmd = string.format("%s 'https://weatherapi.market.xiaomi.com/wtr-v2/weather?cityId=%s'", curl, cityid)
        function get_data(weather_now)
            if not err and type(weather_now) == "table" and weather_now.forecast ~= nil then
                -- weather_now.forecast.date_y == os.date('%Y年%m月%d日')
                for i = 1, 5 do
                    local day  = os.date('%m月%d日',os.time()+60*60*24*(i-1))
                    local temp = weather_now.forecast['temp'.. i]
                    local desc = weather_now.forecast['weather'.. i]
                    local wind = weather_now.forecast['wind'.. i]
                    notification_text = notification_text ..
                        string.format("<b>%s</b>:  %s,  %s,  %s ", day, desc, temp, wind)
                    if i < 5 then
                        notification_text = notification_text .. "\n"
                    end
                end
            end
            return notification_text
        end
    end

    return easy_async(cmd, function(stdout, stderr, reason, exit_code)
        local weather_now, pos, err
        weather_now, pos, err = json.decode(stdout, 1, nil)
        notification_text = get_data(weather_now)
        callback(notification_text)
    end)
end

local function cnweather_now(api, city, cityid, callback)
    local weathertype = ' N/A '
    local weather_now_icon='undefined.png'
    local aql = 'AQI: N/A '
    local cmd = 'echo'
    local function get_data(f) return weathertype, weather_now_icon, aql end

    if api == 'etouch' then
        cmd = string.format("%s --compressed 'http://wthrcdn.etouch.cn/weather_mini?citykey=%s'", curl, cityid)
        function get_data(weather_now)
            if not err and type(weather_now) == "table" and weather_now["desc"] == 'OK' then
                weathertype = weather_now.data.forecast[1].type
                weather_now_icon = icon_table[weathertype] .. ".png"
                aql = '温度: ' .. weather_now.data.wendu .. '℃\n' ..  aqi2apl(weather_now.data.aqi)
            end
            return weathertype, weather_now_icon, aql
        end
    elseif api == 'xiaomi' then
        cmd = string.format("%s 'https://weatherapi.market.xiaomi.com/wtr-v2/weather?cityId=%s'", curl, cityid)
        function get_data(weather_now)
            if not err and type(weather_now) == "table" and weather_now.realtime ~= nil then
                weathertype = weather_now.realtime.weather
                if weathertype:match("转(.*)") ~= nil then
                    weathertype=weathertype:match("转(.*)")
                end
                weather_now_icon = icon_table[weathertype] .. ".png"
                aql = '温度: ' .. weather_now.realtime.temp .. '℃\n' .. aqi2apl(weather_now.aqi.aqi)
            end
            return weathertype, weather_now_icon, aql
        end
    end

    return easy_async(cmd, function(stdout, stderr, reason, exit_code)
        local weather_now, pos, err
        weather_now, pos, err = json.decode(stdout, 1, nil)
        weathertype, weather_now_icon, aql = get_data(weather_now)
        callback(weathertype, weather_now_icon, aql)
    end)
end
--}}}

local function worker(args)
    local cnweather            = {}
    local args                 = args or {}
    local timeout              = args.timeout or 600            -- 10 min
    local timeout_forecast     = args.timeout_forecast or 18000 -- 5 hrs
    local api                  = args.api or 'etouch'           -- etouch, xiaomi
    local city                 = args.city or '杭州'            -- for ?
    local cityid               = args.cityid or 101210101       -- for etouch, xiaomi
    local city_desc            = args.city_desc or city         -- desc for the city
    local icons_path           = args.icons_path or curdir .. "cnweather/"
    local notification_preset  = args.notification_preset or {}
    local followscreen         = args.followscreen or true
    local settings             = args.settings or function() end

    cnweather.widget = wibox.widget.textbox()
    cnweather.icon   = wibox.widget.imagebox()

    function cnweather.show(t_out)
        cnweather.hide()

        if followscreen then
            notification_screen = focused()
        end

        if not cnweather.notification_text then
            cnweather.update()
            cnweather.forecast_update()
        end
        cnweather.notification = naughty.notify({
            text    = string.format("<b>%s</b>\n%s\n%s ", city_desc, cnweather.aql, cnweather.notification_text),
            icon    = cnweather.icon_path,
            timeout = t_out,
            screen  = notification_screen

        })
    end

    function cnweather.hide()
        if cnweather.notification then
            naughty.destroy(cnweather.notification)
            cnweather.notification = nil
        end
    end

    function cnweather.attach(obj)
        obj:connect_signal("mouse::enter", function()
            cnweather.show(0)
        end)
        obj:connect_signal("mouse::leave", function()
            cnweather.hide()
        end)
    end

    function cnweather.forecast_update()
        cnweather_forecast(api, city, cityid, function(notification_text)
            cnweather.notification_text = notification_text
            if cnweather.notification_text == '' then
                cnweather.icon_path = icons_path .. "day/undefined.png"
                cnweather.notification_text = "API/connection error or bad/not set city ID"
            end
        end)
    end

    function cnweather.update()
        local dorn, icon, aql
        if tonumber(os.date('%H')) < 18 and tonumber(os.date('%H')) >= 6 then
            dorn = 'day/'
        else
            dorn = 'night/'
        end
        cnweather_now(api, city, cityid, function(weathertype, weather_now_icon, aql)
            cnweather.weathertype = weathertype
            cnweather.icon_path = icons_path .. dorn ..  weather_now_icon
            cnweather.aql = aql
            cnweather.widget:set_markup(weathertype)
            cnweather.icon:set_image(cnweather.icon_path)
            widget = cnweather.widget
            settings()
            end)
    end

    cnweather.attach(cnweather.widget)
    newtimer("cnweather-" .. city .. cityid, timeout, cnweather.update)
    newtimer("cnweather_forecast-" .. city .. cityid, timeout_forecast, cnweather.forecast_update)
    return setmetatable(cnweather, { __index = cnweather.widget })
end

return setmetatable({}, { __call = function(_, ...) return worker(...) end })
