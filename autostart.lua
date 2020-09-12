local awful = require("awful")

-- {{{ autostart programs
local function run_once(prg,arg_string,pname,screen)
    if not prg then
        do return nil end
    end

    if not pname then
       pname = prg
    end

    if not arg_string then 
        awful.spawn.with_shell("pgrep -f -u $USER -x '" .. pname .. "' || (" .. prg .. ")",screen)
    else
        awful.spawn.with_shell("pgrep -f -u $USER -x '" .. pname .. " ".. arg_string .."' || (" .. prg .. " " .. arg_string .. ")",screen)
    end
end
-- }}}

run_once("picom","-CGfF -o 0.38 -O 200 -I 200 -t 0 -l 0 -r 3 -D2 -m 0.88")
run_once("conky","-c " .. os.getenv("HOME") .. "/.config/awesome/conky.lua")
run_once("parcellite")
run_once("fcitx-autostart",nil,"fcitx")
run_once("volnoti","-t 2 -a 0.8 -r 50")
run_once("wicd-gtk","-t","/usr/bin/python2 -O /usr/share/wicd/gtk/wicd-client.py")
run_once("/usr/bin/redshift-gtk", nil, "python3 /usr/bin/redshift-gtk")
