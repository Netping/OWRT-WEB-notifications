local util = require "luci.util"
local flist = require "luci.model.owrt_web_notification.filelist"


local notify_path = util.libpath() .. "/model/owrt_web_notification/notify"
local files = flist({path = notify_path, grep = ".lua"})

local nt, notify_type = {}, ''
local notify_models = {}

for i=1, #files do
	notify_type = util.split(files[i], '.lua')[1]
	notify_models[notify_type] = require("luci.model.owrt_web_notification.notify." .. notify_type)
end

return(notify_models)