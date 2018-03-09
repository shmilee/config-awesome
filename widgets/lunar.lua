--[[
     Licensed under GNU General Public License v2 
      * (c) 2015, shmilee                         
--]]

local easy_async = require("awful.spawn").easy_async
local newtimer  = require("lain.helpers").newtimer
local curdir    = require("widgets.curdir")
local wibox     = require("wibox")

-- Lunar widget
local lunar = {}

local function worker(args)
    local args     = args or {}
    local timeout  = args.timeout or 3600
    local settings = args.settings or function() end

    lunar.widget = wibox.widget.textbox('')
    function update()
        easy_async(curdir .. 'lunar', function(out, err, reason, exit_code)
            lunar_now = loadstring("return " .. out)()
            widget = lunar.widget
            settings()
        end)
    end

    newtimer("lunar", timeout, update)
    return lunar.widget
end

return worker
