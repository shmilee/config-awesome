-------------------------------
--  "think" awesome theme  --
--        By shmilee       --
-------------------------------

local away  = require("away")
local awful = require("awful")
local dpi   = require("beautiful").xresources.apply_dpi
local os    = { getenv = os.getenv }
local table = { insert = table.insert }

-- inherit away think theme
local theme = dofile(away.util.curdir .. "themes/think/theme.lua")

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
        --http://fy4.nsmc.org.cn/portal/cn/theme/FY4A.html
        return away.wallpaper.get_videowallpaper(s, {
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

-- overwite
function theme.xrandr_menu()
    return away.xrandr_menu({
        { name="H-S-MiTV", dpi=144, complete=true, monitors={
            { key='eDP1-310x170-0dae9-f11-7e-e', scale=1.5 },  -- laptop T450
            { key='HDMI1-1220x690-61a44-a45-db-d', scale=1.0 } -- Mi TV
        } },
        { name='Reset', complete=true, monitors={
            'eDP1-310x170-0dae9-f11-7e-e',  -- laptop T450, dpi=96, scale=1.0
        } },
    })
end

-- save old
local old_updates_menu = theme.updates_menu
-- overwite
function theme.updates_menu()
    local menu = old_updates_menu()
    table.insert(menu, {
        "conky", function()
            theme.kill_focused_videowall() -- kill videowallpaper
            local cmd = "conky -c " .. os.getenv("HOME") .. "/.config/awesome/conky.lua"
            local check_cmd = "pgrep -f -u $USER -x '".. cmd .. "'"
            awful.spawn.easy_async_with_shell(check_cmd, function(o, e, r, c)
                if c == 0 then
                    -- kill old
                    away.util.print_info('kill conky PID ' .. o .. '!')
                    awful.spawn.easy_async('kill ' .. o, function(out, e, r, code)
                        if code == 0 then
                            awful.spawn.with_shell(cmd) -- run new
                            theme.update_focused_videowall() -- start new videowallpaper
                        else
                            away.util.print_info('kill -9 conky PID ' .. o .. '!')
                            awful.spawn.easy_async('kill -9 ' .. o, function(o, e, r, c)
                                awful.spawn.with_shell(cmd) -- run new
                                theme.update_focused_videowall() -- start new videowallpaper
                            end)
                        end
                    end)
                else
                    awful.spawn.with_shell(cmd) -- run new
                    theme.update_focused_videowall() -- start new videowallpaper
                end
            end)
        end
    })
    return menu
end

function theme.more_awesomemenu()
    return {
        { string.rep('-', 10), function () end }, -- sep
        { "lock screen", function()
            awful.spawn.with_shell('XSECURELOCK_NO_COMPOSITE=1 xsecurelock')
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
        -- ${JABREF_OPTIONS} in:
        -- https://aur.archlinux.org/cgit/aur.git/commit/?h=jabref&id=7490271d44f20135cefe11b3e134a98cd5ef69f7
        { "JabRef (&R)", function()
            local dpi = awful.screen.focused().dpi or 96
            local Options = '-Dglass.gtk.uiScale=' .. dpi .. 'dpi'
            Options = Options .. ' -Djdk.gtk.version=2'
            --away.util.print_info("JABREF_EXT_Options='" .. Options .. "' jabref")
            awful.spawn.with_shell("JABREF_OPTIONS='" .. Options .. "' jabref")
        end, find_icon('jabref') },
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
