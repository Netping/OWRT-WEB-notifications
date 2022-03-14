local config, title = "notifyconf", "Notifications"
m = Map(config, translate(title))

cours = luci.model.uci.cursor()
mp=cours:get(config, "globals","maxpingers")
event_list=cours:get_list(config, "globals", "event")
method_list=cours:get_list(config, "globals", "method")

refreshing_string = "<script> document.getElementById('indicators').innerHTML ="..'"'.."<span data-indicator='poll-status' data-clickable='true' data-style='active'>"..translate("Refreshing").."</span>"..'"'..
"; refreshing_xhr = XHR.poll(5, '/cgi-bin/luci/admin/system/notification-refresh', {}, function(x) { if (notify_mtime != x.responseText) { location.reload(); }}); </script>"

default_name=cours:get(config, "prototype", "name")
default_state=cours:get(config, "prototype", "state")
default_event=cours:get(config, "prototype", "event")
default_expression=cours:get(config, "prototype", "expression")
default_method=cours:get(config, "prototype", "method")
default_text=cours:get(config, "prototype", "text")
default_sendto=cours:get(config, "prototype", "sendto")
--default_timetable=cours:get(config, "prototype", "timetable")
default_timetable= "01/01/2022 00:00:00-01/01/2022 00:00:00"

event_list_html =""
for i=1,#event_list do
event_list[i] = luci.util.split(event_list[i], ".", 1)[1]
event_list_html = event_list_html.."<option value='"..event_list[i].."'>"..event_list[i].."</option>"
end

method_list_html =""
for i=1,#method_list do
method_list[i] = luci.util.split(method_list[i], ".", 1)[1]
method_list_html = method_list_html.."<option value='"..method_list[i].."'>"..method_list[i].."</option>"
end

divs_string = "<h3>Edit notification</h3><input id='notify_edit_id' type='hidden' /><table class='notify_edit'>"..
"<tr><td width=300px>"..translate("Notification name").."</td><td><input class='notify_edit' id='notify_edit_name' type='text' /></td></tr>"..
"<tr><td>"..translate("Event").."</td><td><select class='notify_edit' id='notify_edit_event' type='Value' />"..event_list_html.."</select></td></tr>"..
"<tr><td>"..translate("Method").."</td><td><select class='notify_edit' id='notify_edit_method' type='Value' />"..method_list_html.."</select></td></tr>"..
"<tr><td>"..translate("Expression").."</td><td><input class='notify_edit' id='notify_edit_expression' type='text' /></td></tr>"..
"<tr><td>"..translate("Notification text").."</td><td><input class='notify_edit' id='notify_edit_text' type='text' /></td></tr>"..
"<tr><td>"..translate("Send to").."</td><td><input class='notify_edit' id='notify_edit_sendto' type='text' /></td></tr>"..
"<input class='notify_edit' id='notify_edit_timetable' type='hidden' />"..
"</table><br>"..
"<div id='time_intervals' class='time_intervals'></div>"..
"<div class='div_attention'>"..translate("Please specify the time intervals for allow notifications to be sent")..
"<p></p><input class='cbi-button' type='button' value='"..translate("Save").."' onClick='save_settings();' />&nbsp;<input class='cbi-button' type='button' value='"..translate("Cancel").."' onClick='location.reload();' />&nbsp;<input class='cbi-button' type='button' value='"..translate("Add time interval").."' onClick='new_date_fields();' />"..
"</div>"

settings_string = "<input type='button' onclick='settings_click(this);' value='Settings' class='settings_button'>"
header_table = "<link rel='stylesheet' href='/luci-static/netping/owrt_web_notifications.css'>\n"..
"<script src='/luci-static/netping/owrt_web_notifications.js'></script>"..
"<table class='notify-header'><tr><td width=60px>On/Off</td><td width=400px>Notification name</td><td width=110px>Signal</td><td>Method</td></tr></table>"
header_section = m:section(NamedSection, "globals", "globals", header_table)

notify_s = m:section(TypedSection, "notify")
notify_s.addremove = true
notify_s.anonymous = true
notify_s.dynamic = false
notify_s.optional = false
function notify_s:filter(value)
   return value ~= "prototype" and value -- Don't touch loopback
end 

notify_s:option(DummyValue, "", "<table class='notify-body'><tr><td width=60px>")

notify_state = notify_s:option(Flag, "state") 
notify_state.default = default_state
notify_state.rmempty = false

notify_s:option(DummyValue, "", "</td><td width=400px>")

notify_name = notify_s:option(Value, "name") 
notify_name.default = default_name
notify_name.rmempty = false

notify_s:option(DummyValue, "", "</td><td width=110px>")

notify_event = notify_s:option(DummyValue, "event") 

notify_s:option(DummyValue, "", "</td><td width=130px>")

notify_method = notify_s:option(DummyValue, "method") 

notify_s:option(DummyValue, "", "</td><td width=90px></td><td>"..settings_string.."</td></tr></table>")

notify_s:option(DummyValue, "", "<div style='display: none;'><div>")

notify_event = notify_s:option(Value, "event") 
notify_event.default = default_event
notify_event.rmempty = false

notify_method = notify_s:option(Value, "method") 
notify_method.default = default_method
notify_method.rmempty = false

notify_expression = notify_s:option(Value, "expression", translate("Expression")) 
notify_expression.default = default_expression
notify_expression.rmempty = false

notify_text = notify_s:option(Value, "text", translate("Notification text"))
notify_text.default = default_text
notify_text.rmempty = false

notify_sendto = notify_s:option(Value, "sendto", translate("Address for notification")) 
notify_sendto.default = default_sendto
notify_sendto.rmempty = false

notify_timetable = notify_s:option(Value, "timetable", translate("Time intervals")) 
notify_timetable.default = default_timetable
notify_timetable.rmempty = false

notify_s:option(DummyValue, "", "</div>")
notify_s:option(DummyValue, "", "<div id='div_gray_background' class='gray_background'><div id='div_settings_window' class='settings_window'>"..divs_string.."</div></div>")

notify_s1 = m:section(TypedSection, "globals")
notify_s1:option(DummyValue, "", "<script> var notify_mtime='"..nixio.fs.stat("/etc/config/notifyconf").mtime.."'; </script>"..refreshing_string)
notify_s1.anonymous = true

return m