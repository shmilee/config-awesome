#!/bin/bash
need_pkg=('awesome' 'lain-git' 'archlinux-xdg-menu' 'volnoti'
          'YaHei-font')

rc_src='/etc/xdg/awesome/rc.lua'

## BEGIN ##
workdir=`pwd`
if [ "${workdir}" != "${HOME}/.config/awesome" ];then
    echo "ERROR: not awesome config dir."
    exit 1
fi

[ -f rc.lua ] && mv rc.lua rc.lua.bak

## 1. add favorite_setting
# autostart, replaces
line1='^--.*Variable definitions'
sed "/$line1/i \
require(\"favorite_setting\")\n\
" $rc_src > rc.lua
line2=$(grep -n '^--.*Wibox' rc.lua | cut -d: -f1)
((line2--))
sed -i "/$line1/,${line2}d" rc.lua
sed -i '/local gears = require("gears")/d' rc.lua
# favset
sed -i \
    -e 's|\(awful.wibox.*position.*screen = s\)|\1, height = favset.wibox.h, opacity = favset.wibox.o|'\
    -e '/keys = clientkeys,/a \
                     size_hints_honor = favset.window.gaps,'\
    -e 's|c.border_color = beautiful.border_focus|& c.opacity = 1|' \
    -e 's|c.border_color = beautiful.border_normal|& c.opacity = favset.window.opacity|' rc.lua
# favrules
sed -i '/--.*Signals/i \
for k,v in pairs(favoriterules) do table.insert(awful.rules.rules, v) end\
' rc.lua

## 2. mykeys & revelation
sed -i '/--.*Key bindings$/i mykeys = require("mykeys")' rc.lua
sed -i '/-- Menubar$/i \
    -- mycommonmenu\
    awful.key({ modkey,           }, "c", function () mycommonmenu:show() end),\
    -- more keys\
    mykeys,' rc.lua

## 3. lain-wibox, mywidgets
sed -i -e '/textclock.*widget/d'\
       -e '/right_layout:add(wibox.widget.systray())/d'\
       -e '/right_layout:add(mytextclock)/d' rc.lua
sed -i '/--.*Wibox$/i require("mywidgets")' rc.lua
sed -i '/left_layout:add(mypromptbox\[s\])/i \
    left_layout:add(arrr)' rc.lua
sed -i '/right_layout:add(mylayoutbox\[s\])/i \
\
    local right_layout_toggle = true\
    local function right_layout_add (...)\
        local arg = {...}\
        if right_layout_toggle then\
            right_layout:add(arrl_ld)\
            for i, n in pairs(arg) do\
                right_layout:add(wibox.widget.background(n ,beautiful.bg_focus))\
            end\
        else\
            right_layout:add(arrl_dl)\
            for i, n in pairs(arg) do\
                right_layout:add(n)\
            end\
        end\
        right_layout_toggle = not right_layout_toggle\
    end\
\
    right_layout:add(spr)\
    --right_layout_add(netdownicon,netdowninfo, netupicon,netupinfo)\
    right_layout_add(memicon,memwidget)\
    right_layout_add(cpuicon,cpuwidget)\
    right_layout_add(tempicon,tempwidget)\
    right_layout_add(volicon,volumewidget)\
    right_layout_add(baticon,batwidget)\
    if s == 1 then\
        right_layout_add(wibox.widget.systray(),yawn.icon)\
    else\
        right_layout_add(yawn.icon)\
    end\
    right_layout_add(lunar,mytextclock)\
    right_layout_add(mylayoutbox\[s\])' rc.lua
sed -i '/right_layout:add(mylayoutbox\[s\])/d' rc.lua

exit 0
