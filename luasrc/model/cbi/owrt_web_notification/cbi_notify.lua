
local config, title = "notifyconf", "Notify"

m = Map(config, title)
m.template = "owrt_web_notification/notify_list"
m.pageaction = false

return m
