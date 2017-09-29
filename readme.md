My Awesome WM Config Files
==========================

Preview:
--------

* archmenu

![archmenu](preview/archmenu.jpg)

* laptop with 2 batterys, desktop without battery

![bat](preview/bat.jpg)

* weather, calendar

![cal-weather](preview/cal-weather.jpg)

Usage:
------

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
sogou-autostart
volnoti
wicd-gtk
redshift-gtk
```

* mykeys.lua

```
[$] grep ^local mykeys.lua |grep -v -E "=.*require|key.*=" |awk -F\" '{print $2}'
arandr
synapse
slimlock
deepin-scrot
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

Wallpaper
---------

* theme: think
    - themes/think/think-1920x1200.jpg
    - themes/think/violin-1920x1080.jpg

* mywallpaper.lua
    - bingwallpaper: www.bing.com, daily images
    - bingslide: use images in the given dicrectory
    - more ...
