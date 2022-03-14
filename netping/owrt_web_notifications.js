function settings_click(object) {
button_settings = document.getElementsByClassName('settings_button');
var i = 0; var button_number = 0;
for (let element of button_settings)  {	i++; if (object==element) button_number = i;    } 
settings_notification(button_number);
}

function settings_notification(button_number) {
document.getElementById('div_gray_background').style.display="block";
XHR.post('/cgi-bin/luci/admin/system/notification-settings', { button : button_number }, function(x) {
var data_array = x.responseText.split("\n");
document.getElementById('notify_edit_id').value = data_array[0];
document.getElementById('notify_edit_name').value = data_array[1];
document.querySelector('#notify_edit_event').value = data_array[3];
document.querySelector('#notify_edit_method').value = data_array[4];
document.getElementById('notify_edit_expression').value = data_array[5];
document.getElementById('notify_edit_text').value = data_array[6];
document.getElementById('notify_edit_sendto').value = data_array[7];
document.getElementById('notify_edit_timetable').value = data_array[8];
var datetime_array = data_array[8].split(",");
var date_begin_array = []; var date_end_array = [];
for (index=0; index < datetime_array.length; ++index) { temp_date = datetime_array[index].split("-"); date_begin_array[index] = toDate(temp_date[0]); date_end_array[index] = toDate(temp_date[1]);}
add_date_fields (date_begin_array, date_end_array);
});
}

function save_settings() {
var if_error = 0;
notify_id = document.getElementById('notify_edit_id').value; if_error = (notify_id.trim().length > 0) ? if_error : if_error + 1;
notify_name = document.getElementById('notify_edit_name').value; if_error = (notify_name.trim().length > 0) ? if_error : if_error + 1;
notify_event = document.querySelector('#notify_edit_event').value; if_error = (notify_event.trim().length > 0)? if_error : if_error + 1;
notify_method = document.querySelector('#notify_edit_method').value; if_error = (notify_method.trim().length > 0)? if_error : if_error + 1;
notify_expression = document.getElementById('notify_edit_expression').value; if_error = (notify_expression.trim().length > 0)? if_error : if_error + 1;
notify_text = document.getElementById('notify_edit_text').value; if_error = (notify_text.trim().length > 0)? if_error : if_error + 1;
notify_sendto = document.getElementById('notify_edit_sendto').value; if_error = (notify_sendto.trim().length > 0)? if_error : if_error + 1;
//document.getElementById('notify_edit_timetable').value;
set_begins = []; set_ends = [];
date_begin_elements = document.getElementsByClassName('date_begin'); i = 0; for (let element of date_begin_elements)  { set_begins[i] =  element.value; if_error = (set_begins[i].length > 0) ? if_error : if_error + 1; i++; }
date_end_elements = document.getElementsByClassName('date_end'); i = 0; for (let element of date_end_elements)  { set_ends[i] =  element.value; if_error = (set_ends[i].length > 0) ? if_error : if_error + 1; i++; }

if (if_error > 0) { alert("One or more field is empty. Please try after edit this."); return; }
date_string = Date_to_string (set_begins, set_ends);
XHR.post('/cgi-bin/luci/admin/system/notification-settings-commit', { id : notify_id, name: notify_name, event: notify_event, method: notify_method, expression: notify_expression, text: notify_text, sendto: notify_sendto, timetable: date_string }, function(x) { console.log(x); location.reload(); });
}

function Date_to_string (set_begins, set_ends) {
var date_string = "";
for (index=0; index < set_begins.length; ++index) {
date_string += set_begins[index].substring(8, 10) + "/" + set_begins[index].substring(5, 7) + "/" + set_begins[index].substring(0, 4) + " " + set_begins[index].substring(11, 17) + ":00-";
date_string += set_ends[index].substring(8, 10) + "/" + set_ends[index].substring(5, 7) + "/" + set_ends[index].substring(0, 4) + " " + set_ends[index].substring(11, 17) + ":00,";
}
date_string = date_string.substring(0, date_string.length -1 ); return date_string;
}

function toDate (var_date) {
var_date = var_date.trim();
day = var_date.substring(0, 2); month = var_date.substring(3, 5); year =  var_date.substring(6, 10);
hour =  var_date.substring(11, 13); minute = var_date.substring(14, 16);
return (year + "-" + month + "-" + day + "T" + hour + ":" + minute); 
};

function add_date_fields (date_begin_array, date_end_array) {
for (index=0; index < date_begin_array.length; ++index) {
document.getElementById('time_intervals').innerHTML += "<div id='div_interval'><input id='date_begin' class='date_begin' type='datetime-local' value='"+ date_begin_array[index]  +"' min='2020-01-01T00:00' max='2100-01-01T00:00' />" + 
"&nbsp;<input id='date_end' class='date_end' type='datetime-local' value='"+ date_end_array[index]  +"' min='2020-01-01T00:00' max='2100-01-01T00:00' />&nbsp;<input class='date_remove' type='button' value='&nbsp;X&nbsp;' onClick='this.parentNode.remove();'/><div>";
}}

function new_date_fields () {
var div_interval = document.createElement('div');
div_interval.Id = 'div_interval';
div_interval.innerHTML =  "<input id='date_begin' class='date_begin' type='datetime-local' value='' min='2020-01-01T00:00' max='2100-01-01T00:00' />" + 
"&nbsp;<input id='date_end' class='date_end' type='datetime-local' value='' min='2020-01-01T00:00' max='2100-01-01T00:00' />&nbsp;<input class='date_remove' type='button' value='&nbsp;X&nbsp;' onClick='this.parentNode.remove();'/>";
document.getElementById('time_intervals').appendChild(div_interval);
}