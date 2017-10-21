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
    - bingslide: use images in the given dicrectory

      | Input Variable | Meaning  | Type | Default |
      | -------------- | -------- | ---- | ------- |
      | bingdir   | images path      | string | nil |
      | imagetype | images extension | table of strings | {'jpg', 'png'} |
      | timeout   | refresh timeout seconds for setting next wallpaper | number | 60 |
      | setting   | Set wallpaper    | function | `function(bingslide) ... end` |

    - bingwallpaper: www.bing.com, daily images

      | Input Variable | Meaning  | Type | Default |
      | -------------- | -------- | ---- | ------- |
      | api | web api | string | 'https://www.bing.com/HPImageArchive.aspx' |
      | query | search query | table of parameters | { format='js', idx=0, n=8 } |
      | choices | choices in response | table of numbers | { 1, 2, 3, 4, 5, 6, 7, 8 } |
      | curl | curl cmd | string | 'curl -f -s -m 10' |
      | cachedir | path to store images | string | '/tmp' |
      | timeout   | refresh timeout seconds for setting next wallpaper | number | 60 |
      | timeout_info | refresh timeout seconds for fetching new json | number | 86400 |
      | setting   | Set wallpaper    | function | `function(bingwallpaper) ... end` |
      | force_hd | force to use HD image(work with `get_url`) | boolean | false |
      | get_url | get image url from response data | function | `function(bingwallpaper, data, choice) ... end` |
      | get_name | get image name  from response data | function | `function(bingwallpaper, data, choice) ... end` |

    - bingwallpaper: set lovebizhi API, `api`, `query`, `choices`, `get_url`, `get_name`
    - bingwallpaper: set baidu image API, `api`, `query`, `choices`, `get_url`, `get_name`
    - bingwallpaper: set nationalgeographic API, `api`, `query`, `choices`, `get_url`, `get_name`
    - bingwallpaper: set Windows 10 spotlight API, `api`, `query`, `choices`, `curl`, `get_url`, `get_name`
    - more ...
