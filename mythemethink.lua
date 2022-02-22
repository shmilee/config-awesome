-------------------------------
--  "think" awesome theme  --
--        By shmilee       --
-------------------------------

local away  = require("away")
local dpi   = require("beautiful").xresources.apply_dpi
local os    = { getenv = os.getenv }

-- inherit away think theme
local theme = dofile(away.util.curdir .. "themes/think/theme.lua")

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

local xrandr_info = [[Monitors: 2
 0: +*eDP1 1366/310x768/170+0+0  eDP1
 1: +HDMI1 3840/1220x2160/690+1366+0  HDMI1
]]

function theme.xrandr_menu()
    return away.xrandr({
        info = xrandr_info,
        items = {
            { menuname="HS-MiTV", dpi=144, complete=true, monitors={
                { key='eDP1-310x170', scale=1.5 }, -- laptop T450
                { key='HDMI1-1220x690', scale=1.0 } -- MiTV
            } },
            { menuname='Reset', dpi=96, complete=true, monitors={
                { key='eDP1-310x170', scale=1.0 }, -- laptop T450
            } },
        }
    })
end

function theme.custommenu()
    return {
        { "终端 (&T)", theme.terminal, find_icon('terminal') },
        { "文件管理 (&F)", "thunar", find_icon('Thunar') },
        { "监视器 (&M)", theme.terminal .. " -e htop", find_icon('htop') },
        { "火狐 (&B)", "firefox", find_icon('firefox') },
        { "JabRef (&R)", "jabref", find_icon('jabref') },
        { "BT下载 (&D)", "transmission-gtk", find_icon('transmission') },
        { "辞典 (&G)", "goldendict", find_icon('goldendict') },
        { "Win7 (&W)", "VBoxSDL --startvm Win7", find_icon('virtualbox') },
    }
end

local meiriyiwen = away.widget.meiriyiwen({
    font = 'WenQuanYi Micro Hei',
    font_size =  dpi(15),
    ratio = 0,
    height = 0.9,
})
yiwen = meiriyiwen.update

return theme
