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
picom
conky
parcellite
fcitx-autostart
volnoti
nm-applet
/usr/bin/redshift-gtk
```

* mykeys.lua

```
[$] grep ^local mykeys.lua |grep -v -E "=.*require|key.*=" |awk -F\" '{print $2}'
arandr
synapse
XSECURELOCK_NO_COMPOSITE=1 xsecurelock
scrot
```

* conky and fonts
   - default: WenQuanYi Micro Hei
   - arch logo: openlogos
   - arrow: Wingdings 3

* other keys and rules

mytheme:think
-------------

Install [dependencies](https://github.com/shmilee/awesome-away#theme-think).

Inherit **away think** theme, then change

1. function `theme.set_videowall(s, i)`
    + local or online(like FY-4A, bili-sapce) video wallpaper

2. menu needs applications:

   + `theme.terminal = "xfce4-terminal"`

```lua
    find_icon = away.menu.find_icon
    custommenu = {
        { "终端 (&T)", theme.terminal, find_icon('terminal') },
        { "文件管理 (&F)", "thunar", find_icon('Thunar') },
        { "监视器 (&M)", theme.terminal .. " -e htop", find_icon('htop') },
        { "火狐 (&B)", "firefox", find_icon('firefox') },
        { "JabRef (&R)", "jabref", find_icon('jabref') },
        { "BT下载 (&D)", "transmission-gtk", find_icon('transmission') },
        { "辞典 (&G)", "goldendict", find_icon('goldendict') },
        { "Win7 (&W)", "VBoxSDL --startvm Win7", find_icon('virtualbox') },
    }
```

3. add meiriyiwen
