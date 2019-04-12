My Awesome WM Config Files
==========================

Preview:
--------

[Screenshots](https://github.com/shmilee/config-awesome/issues/1)

Usage:
------

Install [dependencies](https://github.com/shmilee/awesome-away#dependencies).

```
mv ~/.config/awesome ~/.config/awesome.old
git clone --recursive https://github.com/shmilee/config-awesome.git ~/.config/awesome
cd ~/.config/awesome
ln -s rc-default.lua rc.lua
```

Update:
-------

```
cd ~/.config/awesome
git stash
git pull
git submodule update --init --recursive
git stash pop
```

Default applications
--------------------

* autostart.lua

```
[$] grep ^run_once autostart.lua|awk -F\" '{print $2}'
compton
conky
fcitx
parcellite
fcitx-autostart
volnoti
wicd-gtk
/usr/bin/redshift-gtk
```

* mykeys.lua

```
[$] grep ^local mykeys.lua |grep -v -E "=.*require|key.*=" |awk -F\" '{print $2}'
arandr
synapse
xsecurelock
scrot
```

* mymenu.lua

```lua
terminal = "xfce4-terminal"
editor = os.getenv("EDITOR") or "vim"
editor_cmd = terminal .. " -e '" .. editor .. " %s '"
```

```lua
    after = {
        { "终端 (&T)", terminal, icon_theme():find_icon_path('terminal') },
        { "文件管理 (&F)", "thunar", lookup_icon('Thunar.png') },
        {"监视器 (&M)", terminal .. " -e htop", lookup_icon('htop.png') },
        { "火狐 (&B)", "firefox", lookup_icon('firefox.png') },
        { "JabRef (&R)", "jabref", lookup_icon('jabref.png') },
        { "BT下载 (&D)", "transmission-gtk", lookup_icon('transmission.png') },
        { "辞典 (&G)", "goldendict", lookup_icon('goldendict.png') },
    }
```

theme:think
-----------

inherit **zenburn** theme, then add

1. function theme.wallpaper(s)
   - use `away.wallpaper`
     + `os.getenv("HOME") .. "/.cache/wallpaper-bing"`
     + `os.getenv("HOME") .. "/.cache/wallpaper-360chrome"`
     + `os.getenv("HOME") .. "/.cache/wallpaper-bing"`
     + `os.getenv("HOME") .. "/.cache/wallpaper-lovebizhi"`
   - fallback
     + think-1920x1200.jpg
     + violin-1920x1080.jpg

2. table theme.layouts for 4 screens
3. table theme.tagnames for 4 screens
4. Widgets from `away`, `lain`
   - mytextclock
   - mylunar, myweather, mybattery: need [dependencies](https://github.com/shmilee/awesome-away#dependencies)
   - myvolume: nedd amixer, [volnoti](https://github.com/hcchu/volnoti)
   - mytemp
   - mycpu
   - mymem
5. function theme.createmywibox(s)

fonts
-----

1. conky
   - default: WenQuanYi Micro Hei
   - arch logo: openlogos
   - arrow: PizzaDude Bullets

2. theme:think
   - default: WenQuanYi Micro Hei
   - widget: Ubuntu Mono
