module("luci.controller.owrt_web_notification.index", package.seeall)

function index()
--	entry({"admin", "system"}, firstchild(), "Administration", 30).dependent=true
--	entry({"admin", "system", "notification"}, cbi("owrt_web_notification/notification", {autoapply=true, hideresetbtn=true}), _("Notification"), 70).dependent=false
	entry({"admin", "system", "notification"}, template("owrt_web_notification/notification", {autoapply=true, hideresetbtn=true}), _("Notification"), 70).dependent=false
	entry({"admin", "system", "notification", "settings"}, call("settings_notify"), nil).dependent=false
	entry({"admin", "system", "notification", "settings-commit"}, call("settings_notify_commit"), nil).dependent=false
	entry({"admin", "system", "notification", "refresh"}, call("notify_refresh"), nil).dependent=false
	entry({"admin", "system", "notification", "check"}, call("notify_check"), nil).dependent=false
	entry({"admin", "system", "notification", "add"}, call("notify_add"), nil).dependent=false
	entry({"admin", "system", "notification", "delete"}, call("notify_delete"), nil).dependent=false
end

function settings_notify()

    local config = "notifyconf"
    cursor_notify = luci.model.uci.cursor()

    id_notify = luci.http.formvalue("id")
    section_name = id_notify
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


function notify_check()

    id = luci.http.formvalue("id")
    local config = "notifyconf"
    cursor_notify = luci.model.uci.cursor()
    notify_state = cursor_notify:get(config, id, "state")
    notify_state = (notify_state=='0') and '1' or '0'
    cursor_notify:set(config, id, "state", notify_state)

    cursor_notify:save()
    cursor_notify:commit(config)
    string_for_ubus = "ubus send commit '{"..' "config" : "notifyconf" '.."}'"
    luci.sys.call(string_for_ubus)

    luci.http.prepare_content("application/javascript; charset=utf-8")
    luci.http.write("ok")
end

function notify_add()

    local config = "notifyconf"
    cursor_notify = luci.model.uci.cursor()

    default_name=cursor_notify:get(config, "prototype", "name")
    default_state=cursor_notify:get(config, "prototype", "state")
    default_event=cursor_notify:get(config, "prototype", "event")
    default_expression=cursor_notify:get(config, "prototype", "expression")
    default_method=cursor_notify:get(config, "prototype", "method")
    default_text=cursor_notify:get(config, "prototype", "text")
    default_sendto=cursor_notify:get(config, "prototype", "sendto")
    --default_timetable=cursor_notify:get(config, "prototype", "timetable")
    default_timetable= "01/01/2022 00:00:00-01/01/2022 00:00:00"

    add_notify = cursor_notify:add(config, "notify")
    cursor_notify:set(config, add_notify, "name", default_name)
    cursor_notify:set(config, add_notify, "state", default_state)
    cursor_notify:set(config, add_notify, "event", default_event)
    cursor_notify:set(config, add_notify, "expression", default_expression)
    cursor_notify:set(config, add_notify, "method", default_method)
    cursor_notify:set(config, add_notify, "text", default_text)
    cursor_notify:set(config, add_notify, "sendto", default_sendto)
    cursor_notify:set(config, add_notify, "timetable", default_timetable)

    cursor_notify:save()
    cursor_notify:commit(config)
    string_for_ubus = "ubus send commit '{"..' "config" : "notifyconf" '.."}'"
    luci.sys.call(string_for_ubus)

    luci.http.prepare_content("application/javascript; charset=utf-8")
    luci.http.write("ok")
end

function notify_delete()

    id = luci.http.formvalue("id")
    local config = "notifyconf"
    cursor_notify = luci.model.uci.cursor()

    cursor_notify:delete(config, id)

    cursor_notify:save()
    cursor_notify:commit(config)
    string_for_ubus = "ubus send commit '{"..' "config" : "notifyconf" '.."}'"
    luci.sys.call(string_for_ubus)

    luci.http.prepare_content("application/javascript; charset=utf-8")
    luci.http.write("ok")

end