local beautiful = require("beautiful")
local menubar = require("menubar")
local icon_theme = require("menubar.icon_theme")
local freedesktop = require("freedesktop")
local hotkeys_popup = require("awful.hotkeys_popup").widget
local focused = require("awful.screen").focused
local lookup_icon = menubar.utils.lookup_icon

-- This is used later as the default terminal and editor to run.
terminal = "xfce4-terminal"
editor = os.getenv("EDITOR") or "vim"
editor_cmd = terminal .. " -e '" .. editor .. " %s '"

-- Create a launcher widget and a main menu
local myawesomemenu = {
    { "hotkeys", function() return false, hotkeys_popup.show_help end},
    { "this bing", function()
        local s = focused()
        if s.miscwallpaper then
            s.miscwallpaper.print_using()
        end
    end },
    { "next bing", function()
        local s = focused()
        if s.miscwallpaper then
            s.miscwallpaper.update()
        end
    end },
    { "manual", terminal .. " -e 'man awesome'" },
    { "edit config", string.format(editor_cmd, awesome.conffile) },
    { "restart", awesome.restart },
    { "quit", function() awesome.quit() end}
}

mymainmenu = freedesktop.menu.build({
    icon_size = beautiful.menu_height or 16,
    before = {
        { "Awesome", myawesomemenu, beautiful.awesome_icon },
    },
    after = {
        { "终端 (&T)", terminal, icon_theme():find_icon_path('terminal') },
        { "文件管理 (&F)", "thunar", lookup_icon('Thunar') },
        { "监视器 (&M)", terminal .. " -e htop", lookup_icon('htop') },
        { "火狐 (&B)", "firefox", lookup_icon('firefox') },
        { "JabRef (&R)", "jabref", lookup_icon('jabref') },
        { "BT下载 (&D)", "transmission-gtk", lookup_icon('transmission') },
        { "辞典 (&G)", "goldendict", lookup_icon('goldendict') },
    }
})

-- Menubar configuration
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
