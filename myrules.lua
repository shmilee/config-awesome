-- https://awesomewm.org/doc/api/classes/client.html

-- additional Rules to apply to new clients
local myrules = {
    -- web browser videos fullscreen mode
    { rule_any = {
        instance = { "plugin-container" },
        class = { "/usr/lib/firefox/plugin-container" },
        role = { "_NET_WM_STATE_FULLSCREEN" },
      }, properties = { floating = true }},
    -- other floating clients
    { rule_any = {
        class = {
            "Tipswindow.py", -- deepin-scrot
            "Pidgin",
            "Pinentry", -- gpg passwd
            "netease-cloud-music",
        },
      }, properties = { floating = true }},
    -- WineQQ
    { rule_any = {
        instance = { 'TM.exe', 'QQ.exe' }
      }, properties = { floating = true,
                        border_width = 0 }},
    -- not maximized
    { rule_any = {
        class = {
            "Ristretto",
            "netease-cloud-music",
        },
      }, properties = {
          maximized = false,
          maximized_horizontal = false,
          maximized_vertical = false }},
    -- Add titlebars to normal clients and dialogs
    --{ rule_any = {type = { "normal", "dialog" }
    --  }, properties = { titlebars_enabled = true }
    --},
}

return myrules
