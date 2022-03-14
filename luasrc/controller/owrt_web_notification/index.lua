module("luci.controller.owrt_web_notification.index", package.seeall)

function index()
--	entry({"admin", "system"}, firstchild(), "Administration", 30).dependent=true
	entry({"admin", "system", "notification"}, cbi("owrt_web_notification/notification", {autoapply=true, hideresetbtn=true}), _("Notification"), 70).dependent=false
	entry({"admin", "system", "notification-settings"}, call("settings_notify"), nil).dependent=false
	entry({"admin", "system", "notification-settings-commit"}, call("settings_notify_commit"), nil).dependent=false
	entry({"admin", "system", "notification-refresh"}, call("notify_refresh"), nil).dependent=false
end

function settings_notify()
luci.http.prepare_content("text/plain")
uci_number = luci.http.formvalue("button")
local config = "notifyconf"
cursor_notify = luci.model.uci.cursor()

conf_counter = 0;
cursor_notify:foreach(config, "notify", function(s)
    if (s[".name"]~="prototype") then		conf_counter = conf_counter + 1		end
    if (tostring(conf_counter)==uci_number) then	section_name = s[".name"]	end end)

--luci.http.write(section_name)
id_notify = section_name
notify_name = cursor_notify:get(config, section_name, "name")
notify_state = cursor_notify:get(config, section_name, "state")
notify_event = cursor_notify:get(config, section_name, "event")
notify_method = cursor_notify:get(config, section_name, "method")
notify_expression = cursor_notify:get(config, section_name, "expression")
notify_text = cursor_notify:get(config, section_name, "text")
notify_sendto = cursor_notify:get(config, section_name, "sendto")
notify_timetable = cursor_notify:get(config, section_name, "timetable")

luci.http.prepare_content("application/javascript; charset=utf-8")
luci.http.write(id_notify.."\n"..notify_name.."\n"..notify_state.."\n"..notify_event.."\n"..notify_method.."\n"..notify_expression.."\n"..notify_text.."\n"..notify_sendto.."\n"..notify_timetable)
end

function settings_notify_commit()

id = luci.http.formvalue("id")
name = luci.http.formvalue("name")
method = luci.http.formvalue("method")
event = luci.http.formvalue("event")
text = luci.http.formvalue("text")
sendto = luci.http.formvalue("sendto")
expression = luci.http.formvalue("expression")
timetable = luci.http.formvalue("timetable")

local config = "notifyconf"

cursor_notify = luci.model.uci.cursor()
cursor_notify:set(config, id, "name", name)
cursor_notify:set(config, id, "method", method)
cursor_notify:set(config, id, "event", event)
cursor_notify:set(config, id, "text", text)
cursor_notify:set(config, id, "sendto", sendto)
cursor_notify:set(config, id, "expression", expression)
cursor_notify:set(config, id, "timetable", timetable)

cursor_notify:save()
cursor_notify:commit(config)
string_for_ubus = "ubus send commit '{"..' "config" : "notifyconf" '.."}'"
luci.sys.call(string_for_ubus)

luci.http.prepare_content("application/javascript; charset=utf-8")
luci.http.write("ok")
end

function notify_refresh()
luci.http.prepare_content("application/javascript; charset=utf-8")
luci.http.write(tostring(nixio.fs.stat("/etc/config/notifyconf").mtime))
end