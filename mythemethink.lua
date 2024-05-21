-------------------------------
--  "think" awesome theme  --
--        By shmilee       --
-------------------------------

local away  = require("away")
local awful = require("awful")
local dpi   = require("beautiful").xresources.apply_dpi
local os    = { getenv = os.getenv, date = os.date }
local string= { format = string.format, rep = string.rep }
local table = { insert = table.insert, concat = table.concat }
local CIloaded, ChatInfo = pcall(require, "chatgpt-info")
if not CIloaded then
    ChatInfo = {}
end

-- inherit away think theme
local theme = dofile(away.util.curdir .. "themes/think/theme.lua")

-- https://github.com/lxgw/LxgwNeoXiHei-Screen
theme.thefont = "LXGW Neo XiHei Screen"
theme.font = "LXGW Neo XiHei Screen 12"

theme.XSECURELOCK_ENV = [[ XSECURELOCK_FONT="LXGW Neo XiHei Screen" XSECURELOCK_SHOW_DATETIME=1 XSECURELOCK_DATETIME_FORMAT="%c" XSECURELOCK_PASSWORD_PROMPT=time_hex XSECURELOCK_NO_COMPOSITE=1 ]]

-- overwite
theme.enable_videowall = false
function theme.get_videowall(s, i)
    if i == 1 then
        return away.wallpaper.get_videowallpaper(s, {
            path = os.getenv("HOME") ..'/视频/Futari.Dake.No.Hanabi.mp4',
            xargs = {'-b -ov -ni -nf -un -s -st -sp -o 0.816'},
            after_prg = 'conky\\s+-c\\s+.*/awesome/conky.lua',
        })
    elseif i == 2 then
        --http://fy4.nsmc.org.cn/nsmc/cn/theme/FY4B.html
        return away.wallpaper.get_videowallpaper(s, {
            -- 3h, 6h, 12h, 24h, 48h, 72h
            path = 'http://img.nsmc.org.cn/CLOUDIMAGE/FY4B/AGRI/GCLR/VIDEO/FY4B.disk.gclr.24h.mp4',
            --path = 'http://img.nsmc.org.cn/CLOUDIMAGE/FY4B/AGRI/GCLR/VIDEO/FY4B.china.24h.mp4',
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
    elseif i == 3 then
        return away.wallpaper.get_bilivideowallpaper(s, {
            path='https://live.bilibili.com/9196015',
            --choices = {'flv'},
            after_prg = 'conky\\s+-c\\s+.*/awesome/conky.lua',
        })
    else
        return nil
    end
end

theme.terminal = "xfce4-terminal"
local find_icon = away.menu.find_icon

function theme.autostart_programs()
    -- util.single_instance(program, args, matcher, start, callback)
    away.util.single_instance("conky", "-c " .. os.getenv("HOME") .. "/.config/awesome/conky.lua")
    away.util.single_instance("parcellite")
    away.util.single_instance("nm-applet")
    away.util.single_instance("/usr/bin/redshift-gtk", nil, "python3 /usr/bin/redshift-gtk")
    away.util.single_instance("fcitx-autostart", nil, "fcitx")
    away.util.single_instance("picom", "-f -o 0.38 -O 200 -I 200 -t 0 -l 0 -r 3 -D2")
    away.util.single_instance("volnoti", "-t 2 -a 0.8 -r 50")
end

-- overwite
function theme.xrandr_menu()
    return away.xrandr_menu({
        { name="HS-U27QX", dpi=192, complete=true, monitors={
            { key='eDP1-310x170-1366x768', scale=2.0 },  -- laptop T450
            { key='DELL-U2723QX-600x340-3840x2160', scale=1.0 }    -- DELL U2723QX
        } },
        { name="HS-ZJ308", dpi=192, complete=true, monitors={
            { key='eDP1-310x170-1366x768', scale=2.0 },  -- laptop T450
            { key='PC-Monitor-600x340-3840x2160', scale=1.0 }    -- MAXHUB
        } },
        { name="HS-ZJ402", dpi=192, complete=true, monitors={
            { key='eDP1-310x170-1366x768', scale=2.0 },  -- laptop T450
            { key='PC-Monitor-1220x680-3840x2160', scale=1.0 }    -- MAXHUB
        } },
        { name="HS-MiTV", dpi=144, complete=true, monitors={
            { key='eDP1-310x170-1366x768', scale=1.5 },  -- laptop T450
            { key='Mi-TV-1220x690-3840x2160', scale=1.0 } -- Mi TV
        } },
        { name='Reset', complete=true, monitors={
            'eDP1-310x170-1366x768',  -- laptop T450, dpi=96, scale=1.0
        } },
    })
end

-- save old
local old_updates_menu = theme.updates_menu
-- overwite
function theme.updates_menu()
    local menu = old_updates_menu()
    away.util.table_merge(menu, {
        {"conky", function()
            theme.kill_focused_videowall() -- kill videowallpaper
            away.util.single_instance(
                "conky", "-c " .. os.getenv("HOME") .. "/.config/awesome/conky.lua",
                nil, 'restart', function(o, e, r, c)
                    theme.update_focused_videowall() -- start new videowallpaper
                end)
        end},
        {"kill-9-conky", function()
            awful.spawn.with_shell('killall -s 9 conky')
        end},
        {"parcellite", function()
            away.util.single_instance("parcellite", nil, nil, 'restart')
        end},
        {"nm-applet", function()
            away.util.single_instance("nm-applet", nil, nil, 'restart')
        end},
        {"picom", function()
            away.util.single_instance("picom", "-f -o 0.38 -O 200 -I 200 -t 0 -l 0 -r 3 -D2", nil, 'restart')
        end},
    })
    return menu
end

function theme.more_awesomemenu()
    return {
        { string.rep('-', 10), function () end }, -- sep
        { "Xlock (&X)", function()
            awful.spawn.with_shell(theme.XSECURELOCK_ENV .. 'xsecurelock')
        end },
        -- systemctl
        { "suspend", function() awful.spawn("systemctl suspend") end },
        { "reboot", function() awful.spawn("systemctl reboot") end },
        { "poweroff", function() awful.spawn("systemctl poweroff") end },
        { string.rep('-', 10), function () end }
    }
end

-- overwite
function theme.custommenu()
    return {
        { "终端 (&T)", theme.terminal, find_icon('terminal') },
        { "文件管理 (&F)", "thunar", find_icon('Thunar') },
        { "监视器 (&M)", theme.terminal .. " -e htop", find_icon('htop') },
        { "火狐 (&B)", "firefox", find_icon('firefox') },
        { "Zotero (&R)", 'zotero', find_icon('zotero') },
        { "BT下载 (&D)", "transmission-gtk", find_icon('transmission') },
        { "辞典 (&G)", function()
            -- https://doc.qt.io/qt-5/highdpi.html#high-dpi-support-in-qt
            local dpi = awful.screen.focused().dpi or 96
            local scale = dpi//(96/4)/4  -- 1.0, 1.25, 1.5, ...
            local qt_env = 'QT_FONT_DPI=96 QT_SCALE_FACTOR=' .. scale
            awful.spawn.with_shell(qt_env .. " goldendict")
        end, find_icon('goldendict') },
        { "Win7 (&7)", "VBoxManage startvm Win7", find_icon('virtualbox') },
    }
end

-- ChatAnywhere usage
local causage_api1 = function(KEY, model)
    local get_info = function(self, data)
        -- get self.today {.tokens, .count, .cost} and self.detail
        local today = { tokens=0, count=0, cost=0 }
        local detail = {
            ' Day   Tokens\tCount\tCost',  -- \t=8
            '-----  ------\t-----\t----',
        }
        local row = "%s\t<b>%s</b>\t <b>%d</b>\t<b>%.2f</b>"
        for i = #data,1,-1 do  -- reversed
            local day = data[i]['time']:sub(6,10)  -- 5
            local tokens = data[i]['totalTokens']
            local count = data[i]['count']
            local cost = data[i]['cost']
            if tokens > 10000 then
                tokens = string.format("%.1fw", tokens/10000)
            end
            if i == #data then  -- last, latest
                if day == os.date('%m-%d') then  -- today
                    today.tokens = tokens
                    today.count = count
                    today.cost = cost
                end
            end
            table.insert(detail, string.format(row, day, tokens, count, cost))
        end
        self.today = today
        self.detail = table.concat(detail, '\n')
    end
    return {
        url = "https://api.chatanywhere.org/v1/query/day_usage_details",
        header = { ['Content-Type']  = "application/json",
                   ['Authorization'] = KEY, },
        postdata = string.format('{"days":5,"model":"%s"}', model),
        get_info = get_info,
    }
end
local causages = {}
if ChatInfo.CA_KEY1 then
    table.insert(causages, away.widget.apiusage({
        id = 'FreeCA', timeout= 3601, font = 'Ubuntu Mono 14',
        apis = { causage_api1(ChatInfo.CA_KEY1, 'gpt-%') },
        setting = function(self)
            self.now.icon = ChatInfo.ICON_CA1
            self.now.notification_icon = ChatInfo.ICON_CA2
            local today =  self.today or { tokens=-1, count=-1, cost=-1 }
            local text = string.format("<b>%d</b>", today.count)
            if today.count > 70 then
                text = away.util.markup_span(text, '#FF6600')
            elseif today.count > 40 then
                text = away.util.markup_span(text, '#E0DA37')
            end
            self.now.text = text
            local title = 'FreeModel: gpt-%'
            local indent = string.rep(' ', (28-title:len())//2)
            title = string.format('%s<b>%s</b>\n', indent, title)
            self.now.notification_text = title .. (self.detail or '')
        end
        })
    )
end
if ChatInfo.CA_KEY2 then
    table.insert(causages, away.widget.apiusage({
        id = 'BuyCA', timeout= 3599, font = 'Ubuntu Mono 14',
        apis = {
            causage_api1(ChatInfo.CA_KEY2, '%'),
            { url = "https://api.chatanywhere.org/v1/query/balance",
              header = { ['Content-Type']  = "application/json",
                         ['Authorization'] = ChatInfo.CA_KEY2, },
              postdata = '',
              get_info = function(self, data)
                -- get self.balance {.used, .total, .perc}
                local used = data['balanceUsed']
                local total = data['balanceTotal']
                local perc = used/total*100
                self.balance = { used=used, total=total, perc=perc }
              end
            },
        },
        setting = function(self)
            self.now.icon = ChatInfo.ICON_OA2
            self.now.notification_icon = ChatInfo.ICON_OA1
            local balance = self.balance or { used=-1, total=-1, perc=-1 }
            local text = string.format("<b>+%.0f%%</b>", balance.perc)
            if balance.perc > 80 then
                text = away.util.markup_span(text, '#FF6600')
            elseif balance.perc > 50 then
                text = away.util.markup_span(text, '#E0DA37')
            end
            self.now.text = text
            local title = string.format('BuyModel: %.1f/%.1f',
                                        balance.used, balance.total)
            local indent = string.rep(' ', (28-title:len())//2)
            title = string.format('%s<b>%s</b>\n', indent, title)
            self.now.notification_text = title .. (self.detail or '')

        end
        })
    )
end

local groupwidgets = { causages[1].wicon, causages[1].wtext}
if #causages == 2 then
    groupwidgets = { causages[2].wicon, causages[1].wtext, causages[2].wtext}
end
--away.util.print_info(away.third_party.inspect(causages))
-- group( 1.workers, 2.wibox.widget args )
local CAwidget = away.widget.apiusage.group(causages, groupwidgets)
CAwidget:attach(CAwidget.wlayout)
CAwidget.wlayout:buttons(CAwidget.updatebuttons)
-- Add to theme
theme.widgets.CAwidget = CAwidget
local i = #theme.groupwidgets - 1
theme.groupwidgets[i] = away.util.table_merge(
    theme.groupwidgets[i], { CAwidget.wlayout })

-- article
local meiriyiwen = away.widget.meiriyiwen({
    font = 'WenQuanYi Micro Hei',
    font_size =  dpi(15),
    ratio = 0,
    height = 0.9,
})

-- globals
yiwen = meiriyiwen.update
micky = require("away.third_party.micky").move_to_client

return theme
