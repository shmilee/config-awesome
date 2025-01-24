-------------------------------
--  "think" awesome theme  --
--        By shmilee       --
-------------------------------

local away  = require("away")
local awful = require("awful")
local apply_dpi = require("beautiful").xresources.apply_dpi
local os    = { getenv = os.getenv, date = os.date }
local string= { format = string.format, rep = string.rep }
local table = { insert = table.insert, concat = table.concat }

-- inherit away think theme
local theme = dofile(away.util.curdir .. "themes/think/theme.lua")

-- https://github.com/lxgw/LxgwNeoXiHei-Screen
theme.thefont = "LXGW Neo XiHei Screen"
theme.font = "LXGW Neo XiHei Screen 12"
theme.apply_dpi = apply_dpi

theme.XSECURELOCK_ENV = [[ XSECURELOCK_FONT="LXGW Neo XiHei Screen:size=24" XSECURELOCK_SHOW_DATETIME=1 XSECURELOCK_DATETIME_FORMAT="%c" XSECURELOCK_PASSWORD_PROMPT=time_hex XSECURELOCK_NO_COMPOSITE=1 ]]

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
                --- zoom, position: https://github.com/mpv-player/mpv/issues/3177
                '--video-zoom=-0.06 --video-pan-y=0.02',
            },
            after_prg = 'conky\\s+-c\\s+.*/awesome/conky.lua',
            timeout = 3600*12,
        })
    elseif i == 3 then
        return away.wallpaper.get_videowallpaper(s, {
            path='https://live.bilibili.com/9196015',
            pargs = {
                '-wid WID --stop-screensaver=no',
                '--hwdec=auto --hwdec-codecs=all',
                '--no-audio --no-osc --no-osd-bar --no-input-default-bindings',
                '--loop-file',
                '--script-opts=danmuku-enable=no',
                '--ytdl-raw-options-append=cookies=' .. os.getenv("HOME") .. '/.config/mpv/cookies/www.bilibili.com.txt',
                '--ytdl-raw-options-append=format-sort=res:720',
            },
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
    away.util.single_instance("fcitx5")
    away.util.single_instance("picom", "--config " .. os.getenv("HOME") .. "/.config/awesome/picom.conf")
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
            away.util.single_instance("picom", "--config " .. os.getenv("HOME") .. "/.config/awesome/picom.conf", nil, 'restart')
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
        { "Scrot-s (&S)", "scrot -s --line mode=edge", find_icon('gnome-screenshot') },
    }
end

-- article
local meiriyiwen = away.widget.meiriyiwen({
    api = theme.secret.mryw_api or nil,
    font = 'WenQuanYi Micro Hei',
    font_size =  apply_dpi(15),
    ratio = 0,
    height = 0.9,
})

-- globals
yiwen = meiriyiwen.update
micky = require("away.third_party.micky").move_to_client

return theme
