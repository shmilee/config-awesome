--[[
     Licensed under GNU General Public License v2 
      * (c) 2015, shmilee                         
--]]

local newtimer  = require("lain.helpers").newtimer
local read_pipe = require("lain.helpers").read_pipe
local curdir    = require("widgets.curdir")
local wibox     = require("wibox")
local setmetatable = setmetatable

-- Lunar widget
local lunar = {}

local function worker(args)
    local args     = args or {}
    local timeout  = args.timeout or 3600
    local settings = args.settings or function() end

    lunar.widget = wibox.widget.textbox('')
    function update()
        lunar_now = loadstring("return " .. read_pipe(curdir .. 'lunar'))()
        widget = lunar.widget
        settings()
    end

    newtimer("lunar", timeout, update)
    return lunar.widget
end

return setmetatable(lunar, { __call = function(_, ...) return worker(...) end })
