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
