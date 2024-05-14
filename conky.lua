conky.config = {
    -- Use double buffering (eliminates flickering)
    double_buffer = true,
    -- Run conky in the background
    background = true,
    -- Update interval in seconds
    update_interval = 1.0,
    -- Set to zero to run forever
    total_run_times = 0,
    -- Subtract file system buffers from used memory
    no_buffers = true,
    -- For intermediary text, such as individual lines
    text_buffer_size = 2048,
    -- Imlib2 image cache size, for $image
    imlib_cache_size = 0,
    temperature_unit = 'celsius',
    -- Number of samples to take for CPU and network readings
    cpu_avg_samples = 2,
    net_avg_samples = 2,

    -- Force UTF8? requires XFT
    override_utf8_locale = true,
    -- Use Xft (anti-aliased font and stuff)
    use_xft = true,
    font = 'WenQuanYi Micro Hei:size=9',
    --font = '微软雅黑:size=9',
    xftalpha = 0.5,
    uppercase = false,

    -- Default color and border settings
    default_color = 'white',
    draw_shades = false,
    draw_outline = false,
    draw_borders = false,
    draw_graph_borders = false,

    -- Window specifications
    alignment = 'top_right',
    gap_x = 16,
    gap_y = 50,
    maximum_width = 400,
    -- Makes conky window transparent
    own_window = true,
    own_window_class = 'conky-semi',
    own_window_argb_visual = true,
    own_window_argb_value = 10,
    own_window_transparent = false,
    -- override #desktop #normel #panel #dock #
    own_window_type = 'override',
    own_window_hints = 'undecorated,below,skip_taskbar,sticky,skip_pager'
}

conky.text = [[
${font openlogos:size=20}${color #0090FF}B${color}${font} ${font Blod:size=20}$alignc$uptime${font}${alignr}
]]

local disk_devices = {'sda', 'sdb', 'sdc', 'sdd', 'sr0'}
local disk_text = [[${if_existing /dev/%s}
${color green}@%s: ${combine ${head /sys/block/%s/device/model 1 10} ${hr 1}}${color}${diskiograph_write %s 20,90 0000ff 0000ff} ${alignr}${diskiograph_read %s 20,90 0000ff 00ffff -t}
${font Wingdings 3}i${font} ${diskio_write %s} ${alignr}${diskio_read %s} ${font Wingdings 3}h${font}
${endif}]]
for i,n in pairs(disk_devices) do
    conky.text = conky.text .. string.format(disk_text, n,n,n,n,n,n,n)
end

local net_devices = {'eth0', 'eth1', 'wlan0', 'wlan1', 'docker0', 'ap0'}
local net_text = [[${if_existing /sys/class/net/%s/operstate %s}
${color green}@%s: ${addr %s} ${hr 1}${color}
${color blue}${downspeedgraph %s 20,90 0000ff 00ffff -t} ${alignr}${upspeedgraph %s 20,90 0000ff 0000ff}${color}
${font Wingdings 3}i${font} ${downspeed %s}/s ${alignr}${upspeed %s}/s ${font Wingdings 3}h${font}
Total ${totaldown %s} ${alignr}Total ${totalup %s}
${endif}]]
for i,n in pairs(net_devices) do
    conky.text = conky.text .. string.format(net_text, n,'up', n,n,n,n,n,n,n,n)
end
local n = 'tailscale0'
conky.text = conky.text .. string.format(net_text, n,'unknown', n,n,n,n,n,n,n,n)

conky.text = conky.text .. [[${color green}${hr 1}${color}
]]
local today = os.date("*t")
local today  = {year = today.year, month = today.month, day = today.day}
local function compare_date(a, b)
    return os.time(a) < os.time(b)
end
local function delta_date(a, b)
    return os.time(b) - os.time(a)
end

local the_Date = {
    {year = today.year, month =  1, day =  1, name = '元旦'},
    {year = today.year, month =  3, day = 20, name = '春分'},
    {year = today.year, month =  5, day =  1, name = '劳动节'},
    {year = today.year, month =  5, day = 21, name = '校庆'},
    {year = today.year, month =  6, day = 21, name = '夏至'},
    {year = today.year, month =  9, day = 22, name = '秋分'},
    {year = today.year, month = 10, day =  1, name = '国庆'},
    {year = today.year, month = 12, day = 21, name = '冬至'},
    {year = today.year, month = 12, day = 31, name = '学生节'},
--  {year = today.year, month =  1, day = 26, name = '寒假'},
--  {year = today.year, month =  6, day = 27, name = '暑假'},
    {year = today.year, month =  2, day = 10, name = '春节'},
    {year = today.year, month =  4, day =  4, name = '清明'},
    {year = today.year, month =  6, day = 10, name = '端午'},
    {year = today.year, month =  9, day = 17, name = '中秋'},
}
-- update year
for i = 1,#the_Date,1 do
    if compare_date(the_Date[i], today) then
        the_Date[i].year = the_Date[i].year + 1
    end
end
-- sort
table.sort(the_Date, compare_date)
-- print
local n     = 2 -- 2,1,0
local space = string.rep(' ', 6)
local indent = string.rep(space, n)
for i = 1,#the_Date,1 do
    local spr = delta_date(today, the_Date[i])
    if spr > 0 then
        spr = (string.format("%.0f", spr / 86400))
        conky.text = conky.text .. 
            string.format([[%s${font Bold:size=16}%s${font}天${alignr}${font Bold:size=12}%s${font}
]], indent, spr, the_Date[i].name)
        n = n - 1
        if n == -1 then break end 
        indent = string.gsub(indent, space, '', 1)
    end
end
conky.text = conky.text .. string.rep('\n', 2)
