-- https://awesomewm.org/doc/api/classes/client.html

-- additional Rules to apply to new clients
local myrules = {
    -- web browser videos fullscreen mode
    {
        rule_any = {
            instance = { "plugin-container" },
            class = { "/usr/lib/firefox/plugin-container" },
            role = { "_NET_WM_STATE_FULLSCREEN" },
        },
        properties = { floating = true },
    },
    -- other floating clients
    {
        rule_any = {
            class = {
                "Pidgin",
                "Pinentry", -- gpg passwd
                "Gdpy3-gui", "gdpy3-gui",
                "mathpix-snipping-tool", "Mathpix Snipping Tool",
                "qq", "Qq", "wemeetapp", -- tencent
                "Weston Compositor",
                "albert",
                "dingtalk.exe", "tblive.exe", -- DingDing
            },
        },
        properties = {
            floating = true,
            border_width = 0,
        },
    },
    -- zotero 7.0 alert
    {
        rule = {
            class = "Zotero",
            instance = "Alert",
            role = "alert",
        },
        properties = { floating = true },
    },
    -- wechat search-window flicker
    {
        rule = { class = "wechat", },
        properties = { focus=false },
    },
    -- vbox
    {
        rule_any = {
            class = { "VirtualBox Machine", "VirtualBox Machine" },
        },
        properties = {
            new_tag = {
                name = "VBox",
                volatile = true, -- Remove the tag when the client is closed.
            },
            fullscreen = true,
        },
    },
    -- not maximized
    {
        rule_any = {
            class = {
                "Ristretto",
            },
        },
        properties = {
            maximized = false,
            maximized_horizontal = false,
            maximized_vertical = false,
        },
    },
    -- Add titlebars to normal clients and dialogs
    --{
    --    rule_any = {
    --        type = { "normal", "dialog" }
    --    },
    --    properties = {
    --        titlebars_enabled = true,
    --    },
    --},
}

return myrules
