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
            "Gdpy3-gui", "gdpy3-gui",
            "mathpix-snipping-tool", "Mathpix Snipping Tool",
        },
      }, properties = { floating = true }},
    -- WineQQ
    { rule_any = {
        instance = { 'TM.exe', 'QQ.exe' }
      }, properties = { floating = true,
                        border_width = 0 }},
    { rule_any = {
        class = { "VirtualBox Machine", "VBoxSDL" },
      }, properties = {
          new_tag = {
            name = "VBox",
            volatile = true, -- Remove the tag when the client is closed.
          },
          fullscreen = true }},
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
