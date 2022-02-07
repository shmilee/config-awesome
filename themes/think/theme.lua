-------------------------------
--  "think" awesome theme  --
--        By shmilee       --
-------------------------------

local away  = require("away")
local dpi   = require("beautiful").xresources.apply_dpi
local os    = { getenv = os.getenv }

-- inherit away think theme
local theme = dofile(away.util.curdir .. "themes/think/theme.lua")

function theme.set_videowall(s, i)
    if i == 1 then
        s.videowallpaper = away.wallpaper.get_videowallpaper(s, {
            path = os.getenv("HOME") ..'/视频/Futari.Dake.No.Hanabi.mp4',
            xargs = {'-b -ov -ni -nf -un -s -st -sp -o 0.816'},
            after_prg = 'conky\\s+-c\\s+.*/awesome/conky.lua',
        })
    elseif i == 2 then
        --http://fy4.nsmc.org.cn/portal/cn/theme/FY4A.html
        s.videowallpaper = away.wallpaper.get_videowallpaper(s, {
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
        s.videowallpaper = away.wallpaper.get_bilivideowallpaper(s, {
            path='https://live.bilibili.com/9196015',
            --choices = {'flv'},
            after_prg = 'conky\\s+-c\\s+.*/awesome/conky.lua',
        })
    else
        return nil
    end
end

local find_icon = away.menu.find_icon
theme.custommenu = {
    { "终端 (&T)", theme.terminal, find_icon('terminal') },
    { "文件管理 (&F)", "thunar", find_icon('Thunar') },
    { "监视器 (&M)", theme.terminal .. " -e htop", find_icon('htop') },
    { "火狐 (&B)", "firefox", find_icon('firefox') },
    { "JabRef (&R)", "jabref", find_icon('jabref') },
    { "BT下载 (&D)", "transmission-gtk", find_icon('transmission') },
    { "辞典 (&G)", "goldendict", find_icon('goldendict') },
    { "Win7 (&W)", "VBoxSDL --startvm Win7", find_icon('virtualbox') },
}

local meiriyiwen = away.widget.meiriyiwen({
    font = 'WenQuanYi Micro Hei',
    font_size =  dpi(15),
    ratio = 0,
    height = 0.9,
})
yiwen = meiriyiwen.update

return theme
