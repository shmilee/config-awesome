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
local the_Date = {
    {y = 2024, m =  1, d =  1, name = '元旦'},
--    {y = 2019, m =  1, d = 16, name = '(冬)考试周'},
--    {y = 2019, m =  1, d = 26, name = '寒假'},
--    {y = 2024, m =  2, d = 18, name = '(春)开学'},
    {y = 2023, m =  4, d =  5, name = '清明'},
--    {y = 2023, m =  4, d = 16, name = '(春)考试周'},
    {y = 2023, m =  5, d =  1, name = '劳动节'},
--    {y = 2023, m =  5, d = 14, name = '(春)校运会'},
    {y = 2023, m =  5, d = 21, name = '校庆'},
    {y = 2023, m =  6, d =  3, name = '端午'},
--    {y = 2023, m =  6, d = 13, name = '(夏)考试周'},
--    {y = 2023, m =  6, d =  27, name = '暑假'},
--    {y = 2018, m =  9, d = 14, name = '(秋)开学'},
    {y = 2023, m =  9, d = 10, name = '中秋'},
    {y = 2023, m = 10, d =  1, name = '国庆'},
--    {y = 2018, m = 10, d = 26, name = '(秋)校运会'},
--    {y = 2018, m = 11, d = 14, name = '(秋)考试周'},
    {y = 2023, m = 12, d = 31, name = '学生节'}
}
table.sort(the_Date, function (a,b)
    return os.time({year = a.y, month = a.m, day = a.d, hour = 12})
        < os.time({year = b.y, month = b.m, day = b.d, hour = 12})
end)
local n     = 2 -- 2,1,0
local space = '      '
local space = space .. space -- 2
local from  = os.date('*t')
local from  = os.time({year = from.year, month = from.month, day = from.day, hour = 12})
for i = 1,#the_Date,1 do
    local to  = os.time({year = the_Date[i].y, month = the_Date[i].m, day = the_Date[i].d, hour = 12})
    local spr = to - from
    if spr > 0 then
        spr = (string.format("%.0f", spr / 86400))
        conky.text = conky.text .. 
            string.format([[%s${font Bold:size=16}%s${font}天${alignr}${font Bold:size=12}%s${font}
]], space, spr, the_Date[i].name)
        n = n - 1
        if n == -1 then break end 
        space = string.gsub(space,'      ','',1)
    end
end

for i = 1,2,1 do -- 2
    conky.text = conky.text .. [[

]]
end
