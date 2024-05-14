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
[$] grep single_instance mythemethink.lua | awk -F\" '{print $2}' | sort | uniq
conky
fcitx-autostart
nm-applet
parcellite
picom
/usr/bin/redshift-gtk
volnoti
```

* mykeys.lua

```
[$] grep ^local mykeys.lua |grep -v -E "=.*require|key.*=" |awk -F\" '{print $2}'
arandr
synapse
 xsecurelock
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

1. font [LxgwNeoXiHei-Screen](https://github.com/lxgw/LxgwNeoXiHei-Screen)

2. disable videowall; function `theme.get_videowall(s, i)`
    + local or online(like FY-4A, bili-sapce) video wallpaper

3. autostart and menu applications:

   + `theme.terminal = "xfce4-terminal"`
   + `theme.updates_menu()`
   + `theme.xrandr_menu()`, `xrandr`
   + `theme.custommenu()`

```lua
    custommenu = {
        { "终端 (&T)", theme.terminal, find_icon('terminal') },
        { "文件管理 (&F)", "thunar", find_icon('Thunar') },
        { "监视器 (&M)", theme.terminal .. " -e htop", find_icon('htop') },
        { "火狐 (&B)", "firefox", find_icon('firefox') },
        { "Zotero (&R)", 'zotero', find_icon('zotero') },
        { "BT下载 (&D)", "transmission-gtk", find_icon('transmission') },
        { "辞典 (&G)", "goldendict", find_icon('goldendict') },
        { "Win7 (&7)", "VBoxManage startvm Win7", find_icon('virtualbox') },
    }
```

4. add apiusage.group
5. add yiwen = meiriyiwen.update
6. add micky
