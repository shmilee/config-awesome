local beautiful = require("beautiful")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup").widget
local focused = require("awful.screen").focused
local icon_theme = require("menubar.icon_theme")
local freedesktop_menu = require("away.third_party.freedesktop_menu")

-- This is used later as the default terminal and editor to run.
terminal = "xfce4-terminal"
editor = os.getenv("EDITOR") or "vim"
editor_cmd = terminal .. " -e '" .. editor .. " %s '"

-- Create a launcher widget and a main menu
local myawesomemenu = {
    { "hotkeys", function() hotkeys_popup.show_help(nil, awful.screen.focused()) end},
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

local function find_icon(i)
    return menubar.utils.lookup_icon(i) or icon_theme():find_icon_path(i)
end

mymainmenu = freedesktop_menu.build({
    icon_size = beautiful.menu_height or 16,
    before = {
        { "Awesome", myawesomemenu, beautiful.awesome_icon },
    },
    after = {
        { "终端 (&T)", terminal, find_icon('terminal') },
        { "文件管理 (&F)", "thunar", find_icon('Thunar') },
        { "监视器 (&M)", terminal .. " -e htop", find_icon('htop') },
        { "火狐 (&B)", "firefox", find_icon('firefox') },
        { "JabRef (&R)", "jabref", find_icon('jabref') },
        { "BT下载 (&D)", "transmission-gtk", find_icon('transmission') },
        { "辞典 (&G)", "goldendict", find_icon('goldendict') },
        { "Win7 (&W)", "VBoxSDL --startvm Win7", find_icon('virtualbox') },
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
