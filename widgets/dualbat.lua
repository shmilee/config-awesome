
--[[
												                        
	 Licensed under GNU General Public License v2 
      * (c) 2016,      shmilee                    
	  * (c) 2013,      Luke Bonham                
	  * (c) 2010-2012, Peter Hofmann              
												                        
--]]

local newtimer     = require("lain.helpers").newtimer
local first_line   = require("lain.helpers").first_line

local naughty      = require("naughty")
local wibox        = require("wibox")
local beautiful    = require("beautiful")

local math         = { floor  = math.floor }
local string       = { format = string.format }
local tonumber     = tonumber

local setmetatable = setmetatable

-- Battery infos
-- widgets.dualbat

local function worker(args)
    local bat          = {}
    local args         = args or {}
    local timeout      = args.timeout or 10
    local powerpath    = args.path or "/sys/class/power_supply"
    local batterys     = args.batterys or {"BAT"}
    local ac           = args.ac or "AC"
    local font         = args.font or beautiful.font:gsub(" %d.*", "")
    local font_size    = tonumber(args.font_size) or 10
    local notify       = args.notify or "on"
    local followmouse  = args.followmouse or false
    local settings     = args.settings or function() end

    bat.widget = wibox.widget.textbox('')

    bat_notification_low_preset = {
        title   = "Battery low",
        text    = "Plug the cable!",
        timeout = 15,
        fg      = "#202020",
        bg      = "#CDCDCD"
    }

    bat_notification_critical_preset = {
        title   = "Battery exhausted",
        text    = "Shutdown imminent",
        timeout = 15,
        fg      = "#000000",
        bg      = "#FFFFFF"
    }

    function bat.update()
        bat_now = {
            ac_status   = "N/A",
            status      = "Unknown",
            energy_now  = 0,
            energy_full = 0,
            perc        = "N/A",
            icon        = nil,
            notification_text = ''
        }

        bat_now.ac_status = first_line(powerpath .. "/" .. ac .. "/online") or "N/A"

        for i,battery in ipairs(batterys) do
            bat_now["bat" .. i-1] = {
                name      = battery,
                status    = "N/A",
                perc      = "N/A",
                time      = "N/A",
                watt      = "N/A"
            }

            local bstr    = powerpath .. "/" .. battery
            local present = first_line(bstr .. "/present")

            if present == "1" then
                -- current_now(I)[uA], voltage_now(U)[uV], power_now(P)[uW]
                local rate_current      = tonumber(first_line(bstr .. "/current_now"))
                local rate_voltage      = tonumber(first_line(bstr .. "/voltage_now"))
                local rate_power        = tonumber(first_line(bstr .. "/power_now"))

                -- energy_now(P)[uWh], charge_now(I)[uAh]
                local energy_now        = tonumber(first_line(bstr .. "/energy_now") or
                                          first_line(bstr .. "/charge_now"))
                bat_now.energy_now      = bat_now.energy_now + energy_now

                -- energy_full(P)[uWh], charge_full(I)[uAh]
                local energy_full       = tonumber(first_line(bstr .. "/energy_full") or
                                          first_line(bstr .. "/charge_full"))
                bat_now.energy_full     = bat_now.energy_full + energy_full

                local energy_percentage = tonumber(first_line(bstr .. "/capacity")) or
                                          math.floor((energy_now / energy_full) * 100)

                bat_now["bat" .. i-1].status    = first_line(bstr .. "/status") or "N/A"
                bat_now["bat" .. i-1].perc = string.format("%d", energy_percentage)

                -- update {perc,time,watt} iff rate > 0 and battery not full
                if ((rate_current and rate_current > 0) or (rate_power and rate_power > 0))
                    and bat_now["bat" .. i-1].status ~= "N/A"
                    and bat_now["bat" .. i-1].status ~= "Unknown"
                    and bat_now["bat" .. i-1].status ~= "Full"
                then
                    local rate_time = 0
                    if bat_now["bat" .. i-1].status == "Charging" then
                        rate_time = (energy_full - energy_now) / (rate_power or rate_current)
                    elseif bat_now["bat" .. i-1].status == "Discharging" then
                        rate_time = energy_now / (rate_power or rate_current)
                    end

                    local hours   = math.floor(rate_time)
                    local minutes = math.floor((rate_time - hours) * 60)
                    local watt    = rate_power and (rate_power / 1e6) or (rate_voltage * rate_current) / 1e12
                    bat_now["bat" .. i-1].time = string.format("%02d:%02d", hours, minutes)
                    bat_now["bat" .. i-1].watt = string.format("%.2fW", watt)
                    -- Charging or Discharging
                    bat_now.status = bat_now["bat" .. i-1].status
                end
            end

            -- notifications
            local notification_text = string.format("<b>%s</b>:  %s%%\t", battery, bat_now["bat" .. i-1].perc)
            if bat_now["bat" .. i-1].status == "Charging" then
                notification_text = notification_text .. string.format("Charging (%s)", bat_now["bat" .. i-1].time)
            elseif bat_now["bat" .. i-1].status == "Discharging" then
                notification_text = notification_text .. string.format("Discharging (%s)", bat_now["bat" .. i-1].time)
            else
                notification_text = notification_text .. bat_now["bat" .. i-1].status
            end
            if i ~= #batterys then
                notification_text = notification_text .. "\n"
            end
            bat_now.notification_text = bat_now.notification_text .. notification_text
            
        end

        if ((bat_now.energy_now  and bat_now.energy_now >0) and (bat_now.energy_full and bat_now.energy_full >0)) then
            bat_now.perc = string.format("%d", math.floor((bat_now.energy_now / bat_now.energy_full) * 100))
            bat_now.notification_text = bat_now.perc .. "% :\n" .. bat_now.notification_text
        else
             bat_now.notification_text = "No battery. Using AC."
        end
        bat_now.notification_text = string.format("<tt><span font='%s %s'>", font, font_size)
            .. bat_now.notification_text .. "</span></tt>"

        widget = bat.widget
        settings()

        -- notifications for low and critical states
        if bat_now.status == "Discharging" and notify == "on" and bat_now.perc then
            local nperc = tonumber(bat_now.perc) or 100
            if nperc <= 5 then
                bat.id = naughty.notify({
                    preset = bat_notification_critical_preset,
                    replaces_id = bat.id,
                }).id
            elseif nperc <= 15 then
                bat.id = naughty.notify({
                    preset = bat_notification_low_preset,
                    replaces_id = bat.id,
                }).id
            end
        end
    end

    function bat.show(t_out)
        bat.hide()

        if followmouse then
            notification_screen = mouse.screen
        end

        bat.notification = naughty.notify({
            text    = bat_now.notification_text,
            icon    = bat_now.icon,
            timeout = t_out,
            screen  = notification_screen
        })
    end

    function bat.hide()
        if bat.notification ~= nil then
            naughty.destroy(bat.notification)
            bat.notification = nil
        end
    end

    function bat.attach(obj)
        obj:connect_signal("mouse::enter", function()
            bat.show(0)
        end)
        obj:connect_signal("mouse::leave", function()
            bat.hide()
        end)
    end

    newtimer(batterys, timeout, bat.update)

    return setmetatable(bat, { __index = bat.widget })
end

return setmetatable({}, { __call = function(_, ...) return worker(...) end })
