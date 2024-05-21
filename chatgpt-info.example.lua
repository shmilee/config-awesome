--  chatgpt info for awesome
--
--  Copyright (c) 2024 shmilee
--

local I = {}
local DIR = os.getenv("HOME") .. "/.config/awesome/chatgpt-icon/"

-- OPANAI ChatGPT
I.OPANAI_API_KEY = nil
I.ICON_OA1 = DIR .. 'chatgpt-icon.png'
I.ICON_OA2 = DIR .. 'chatgpt-logo.png'
I.ICON_OA3 = DIR .. 'openai-black.png'
I.ICON_OA4 = DIR .. 'openai-white.png'

-- ChatAnywhere CA
I.CA_KEY1 = nil  -- 'sk-xxx'
I.CA_KEY2 = nil  --'sk-xxx'
I.ICON_CA1 = DIR .. 'chatanywhere.png'
I.ICON_CA2 = DIR .. 'chatanywhere-light.png'

return I
