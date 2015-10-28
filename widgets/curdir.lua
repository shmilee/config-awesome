local debug  = require("debug")
local curdir = debug.getinfo(1, 'S').source:match[[^@(.*/).*$]]
return curdir
