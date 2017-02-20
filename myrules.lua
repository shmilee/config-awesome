-- additional Rules to apply to new clients
local myrules = {
    -- web browser videos fullscreen mode
    { rule_any = {
        instance = { "plugin-container" },
        class = { "/usr/lib/firefox/plugin-container" },
        role = { "_NET_WM_STATE_FULLSCREEN" },
    },
      properties = { floating = true } },
    -- deepin-scrot
    { rule = { class = "Tipswindow.py" },
      properties = { floating = true } },
    -- Pidgin
    { rule = { class = "Pidgin" },
      properties = { floating = true } },
    -- WineQQ
    { rule_any = { instance = {'TM.exe', 'QQ.exe'} },
      properties = { floating = true,
                     border_width = 0, } },
    -- Add titlebars to normal clients and dialogs
    --{ rule_any = {type = { "normal", "dialog" }
    --  }, properties = { titlebars_enabled = true }
    --},
}

return myrules
