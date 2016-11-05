#!/bin/bash
if ! hash xdg_menu 2>/dev/null; then
    exit 1
fi
root_menu=${1:-/etc/xdg/menus/arch-applications.menu}
out_menu=${2:-~/.config/awesome/archmenu.lua}
if xdg_menu --format awesome --root-menu "$root_menu" > "$out_menu"; then
    sed -i -e 's|xdgmenu|local &|;' \
        -e '$a return xdgmenu' "$out_menu" && exit 0
else
    exit 1
fi
