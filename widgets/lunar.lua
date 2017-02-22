--[[
     Licensed under GNU General Public License v2 
      * (c) 2015, shmilee                         
--]]

local newtimer  = require("lain.helpers").newtimer
local async_pipe = require("lain.helpers").async
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
        async_pipe(curdir .. 'lunar', function(f)
            lunar_now = loadstring("return " .. f)()
            widget = lunar.widget
            settings()
        end)
    end

    newtimer("lunar", timeout, update)
    return lunar.widget
end

return worker
