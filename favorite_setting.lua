local gears = require("gears")
local awful = require("awful")
local beautiful = require("beautiful")
local menubar = require("menubar")
local read_pipe = require("lain.helpers").read_pipe

----- favorite_setting, autostart programs -----
local function run_once(prg,arg_string,pname,screen)
    if not prg then
        do return nil end
    end

    if not pname then
       pname = prg
    end

    if not arg_string then 
        awful.util.spawn_with_shell("pgrep -f -u $USER -x '" .. pname .. "' || (" .. prg .. ")",screen)
    else
        awful.util.spawn_with_shell("pgrep -f -u $USER -x '" .. pname .. " ".. arg_string .."' || (" .. prg .. " " .. arg_string .. ")",screen)
    end
end
run_once("compton","-CGfF -o 0.38 -O 200 -I 200 -t 0 -l 0 -r 3 -D2 -m 0.88")
run_once("conky","-c " .. os.getenv("HOME") .. "/.config/awesome/conky.lua")
run_once("fcitx")
run_once("parcellite")
run_once("sogou-autostart","","sogou-qimpanel")
run_once("volnoti","-t 2 -a 0.8 -r 50")
run_once("wicd-gtk","-t","/usr/bin/python2 -O /usr/share/wicd/gtk/wicd-client.py")

----- favorite_setting, replaces: -----
-- 1) Variable definitions,
-- 2) Wallpaper,
-- 3) Tags,
-- 4) Menu

-- 1)
-- Themes define colours, icons, font and wallpapers.
theme = os.getenv("HOME") .. "/.config/awesome/themes/think/theme.lua"
beautiful.init(theme)
-- default terminal and editor
terminal = "xfce4-terminal"
editor = os.getenv("EDITOR") or "vim"
editor_cmd = terminal .. " -e '" .. editor .. " %s '"
-- Default modkey. Usually, Mod4 is the key with a logo between Control and Alt.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
layouts = {
  awful.layout.suit.floating,
  awful.layout.suit.tile,
  awful.layout.suit.tile.left,
  awful.layout.suit.tile.bottom,
  awful.layout.suit.tile.top,
  awful.layout.suit.spiral,
  awful.layout.suit.spiral.dwindle,
  awful.layout.suit.max,
  awful.layout.suit.magnifier
}

-- 2)
-- first screen wallpaper
if beautiful.wallpaper then
  gears.wallpaper.maximized(beautiful.wallpaper, 1, true)
end
-- more screen wallpapers <5
local morewallpapers = {
  "/usr/share/wallpapers-shmilee/1080/violin-1920x1080.jpg",
  "/usr/share/wallpapers-shmilee/1200/arch-1920x1200.jpg",
  "/usr/share/wallpapers-shmilee/1200/black-1920x1200.jpg",
  "/usr/share/wallpapers-shmilee/1600/Castilla_Sky-2560x1600.jpg"
}
for s = 2, screen.count() do
  if s-1 <= #morewallpapers then
    gears.wallpaper.maximized(morewallpapers[s-1], s, true)
  else
    gears.wallpaper.maximized(beautiful.wallpaper, s, true)
  end
end

-- 3)
-- Define a tag table which hold all screen tags.
tags = {}
-- first screen tags
tags[1] = awful.tag(
  { "宫", "商", "角", "徵", "羽" },
  1,
  { layouts[1], layouts[2], layouts[1], layouts[2], layouts[2] }
)
-- more screen tags <5
local moretags = {
  names = {
    {"壹", "貳", "叄", "肆", "伍", "陸", "柒", "捌", "玖", "拾"},
    {"一", "二", "三", "四", "五", "六", "七", "八", "九", "十"},
    { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 },
    {"I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X"}
  },
  layout = layouts[2]
}
for s = 2, screen.count() do
    -- Each screen has its own tag table.
    tags[s] = awful.tag(moretags.names[s-1], s, moretags.layout)
end

-- 4)
-- Create a laucher widget and a main menu
local rootmenufile = '/etc/xdg/menus/arch-applications.menu'

local myawesomemenu = {
  { "manual", terminal .. " -e 'man awesome'" },
  { "edit config", string.format(editor_cmd, awesome.conffile) },
  { "refresh menu", function ()
    awful.util.spawn_with_shell('bash ~/.config/awesome/gen_archmenu.sh ' .. rootmenufile )
    awesome.restart()
    end },
  { "restart", awesome.restart },
  { "quit", awesome.quit }
}

local common_menu = {
  { "文件管理 (&F)", "thunar", 'Thunar.png' },
  { "记事本 (&V)", "gvim", 'gvim.png' },
  { "终端 (&T)", terminal, 'utilities-terminal.png' },
  {"监视器 (&M)", terminal .. " -e htop", 'htop.png' },
  { "火狐 (&B)", "firefox", 'firefox.png' },
  { "JabRef (&R)", "jabref", 'jabref.png' },
  { "BT下载 (&D)", "transmission-gtk", 'transmission.png' },
  { "Pidgin (&I)", "pidgin", 'pidgin.png' },
  { "Audacious (&A)", "audacious", 'audacious.png' },
  { "wps文字 (&W)", "wps", 'wps-office-wpsmain.png' },
  { "辞典 (&G)", "goldendict", 'goldendict.png' }
}
for k, v in pairs(common_menu) do
  common_menu[k][3] = menubar.utils.lookup_icon(common_menu[k][3])
end
mycommonmenu = awful.menu({ items = common_menu })

if not awful.util.file_readable(awful.util.getdir("config") .. "/archmenu.lua") then
  os.execute('bash ~/.config/awesome/gen_archmenu.sh ' .. rootmenufile)
end
local xdgmenu = require("archmenu")
local XDG_ICON_DICT = {
  ["Internet"] = 'applications-internet.png',
  ["互联网"] = 'applications-internet.png',
  ["Office"] = 'applications-office.png',
  ["办公"] = 'applications-office.png',
  ["Graphics"] = 'applications-graphics.png',
  ["图像"] = 'applications-graphics.png', ["图形"] = 'applications-graphics.png',
  ["Multimedia"] = 'applications-multimedia.png', ["Sound & Video"] = 'applications-multimedia.png',
  ["影音"]= 'applications-multimedia.png', ["多媒体"] = 'applications-multimedia.png',
  ["Education"] = 'applications-science.png',
  ["教育"] = 'applications-science.png',
  ["Games"] = 'applications-games.png',
  ["游戏"] = 'applications-games.png',
  ["System"] = 'applications-system.png', ["System Tools"] = 'applications-system.png',
  ["系统工具"] = 'applications-system.png', ["系统"] = 'applications-system.png',
  ["Development"] = 'applications-development.png', ["Programming"] = 'applications-development.png',
  ["编程"] = 'applications-development.png', ["开发"] = 'applications-development.png',
  ["Utilities"] = 'applications-accessories.png', ["Accessories"] = 'applications-accessories.png',
  ["附件"]= 'applications-accessories.png', ["工具"] = 'applications-accessories.png',
  ["Settingsmenu"] = 'applications-utilities.png', ["Settings"] = 'applications-utilities.png',
  ["设置"] = 'applications-utilities.png',
}
for k, v in pairs(xdgmenu) do
  xdgmenu[k][3] = menubar.utils.lookup_icon(XDG_ICON_DICT[xdgmenu[k][1]])
end

-- assemble
local menu_items = {
  { "awesome", myawesomemenu, beautiful.awesome_icon },
  { "常用 (&C)", common_menu, menubar.utils.lookup_icon('user-bookmarks.png') }
}
for k,v in pairs(xdgmenu) do table.insert(menu_items, v) end
mymainmenu = awful.menu({ items = menu_items })
mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
menubar.menu_gen.all_menu_dirs = { "/usr/share/applications/", "~/.local/share/applications" }
menubar.menu_gen.all_categories.multimedia.name = "影音"
menubar.menu_gen.all_categories.development.name = "开发"
menubar.menu_gen.all_categories.education.name = "教育"
menubar.menu_gen.all_categories.games.name = "游戏"
menubar.menu_gen.all_categories.graphics.name = "图像"
menubar.menu_gen.all_categories.office.name = "办公"
menubar.menu_gen.all_categories.internet.name = "互联网"
menubar.menu_gen.all_categories.settings.name = "设置"
menubar.menu_gen.all_categories.tools.name = "系统"
menubar.menu_gen.all_categories.utility.name = "工具"

----- favorite_setting, others -----

favset = {
  wibox = { h = 20, o = 0.88 }, -- height, opacity
  window = {
    gaps=false, -- size_hints_honor
    opacity = 0.98, -- unfocus window transparency, focus window = 1
  }
}

-- additional Rules to apply to new clients
favoriterules = {
  -- web browser videos fullscreen mode
  { rule = { instance = "plugin-container" },
    properties = { floating = true } },
  { rule = { role = "_NET_WM_STATE_FULLSCREEN" },
    properties = { floating = true } },
  { rule = { class = "/usr/lib/firefox/plugin-container" },
    properties = { floating = true } },
  -- deepin-scrot
  { rule = { class = "Tipswindow.py" },
    properties = { floating = true } },
  -- Pidgin
  { rule = { class = "Pidgin" },
    properties = { floating = true } },
  -- location
  { rule = { class = "Firefox" },
    properties = { tag = tags[1][2] } },
  { rule = { class = "mpv" },
    properties = { tag = tags[1][4] } },
  { rule = { class = "VirtualBox" },
    properties = { tag = tags[1][5] } },
}

-- vim:set ts=2 sw=2 et:
