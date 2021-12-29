module("luci.controller.owrt_web_notification.index", package.seeall)

local http = require "luci.http"
local uci = require "luci.model.uci".cursor()
local util = require "luci.util"

local config = "notifyconf"
local notify = require "luci.model.owrt_web_notification.notify"

function notify_backend_on_commit(config_name)
	local conn = ubus.connect()
	if not conn then
		error("Failed to connect to ubus")
	end
	conn:send("commit", { config = config_name})
	conn:close()
end

function index()
	if nixio.fs.access("/etc/config/notifyconf") then
		entry({"admin", "system", "notify"}, cbi("owrt_web_notification/cbi_notify"), translate("ntf_tab"), 30)
		entry({"admin", "system", "notify", "action"}, call("do_notify_action"), nil).leaf = true
	end
end

function do_notify_action(action, notify_id)
	local payload = {}
	payload["notify_data"] = luci.jsonc.parse(luci.http.formvalue("notify_data"))
	for _, k in pairs({".name", ".anonymous", ".type", ".index"}) do payload["notify_data"][k] = nil end
	payload["globals_data"] = luci.jsonc.parse(luci.http.formvalue("globals_data"))
	-- payload["notify_data"] = luci.jsonc.parse(luci.http.formvalue("notify_data"))

	local sucsess = false

	local commands = {
		add = function(...)
			notify():new()
		end,
		rename = function(notify_id, payload)
			if payload["notify_data"]["name"] then
				notify(notify_id):set("name", payload["notify_data"]["name"])
			end
		end,
		delete = function(notify_id, ...)
			notify(notify_id):delete()
		end,
		edit = function(notify_id, payloads)
			-- apply notify settings
			-- local allowed_notify_options = util.keys(uci:get_all(config, "prototype_" .. string.lower(payloads["notify_data"].method)))
			local allowed_notify_options = util.keys(uci:get_all(config, "prototype"))
			local curnotifyconf = uci:get_all(config, notify_id)
			for key, value in pairs(payloads["notify_data"]) do
				if util.contains(allowed_notify_options, key) then
					uci:set(config, notify_id, key, value)
				end
			end
			for key, value in pairs(curnotifyconf) do
				if not (util.contains(allowed_notify_options, key)) then
					uci:delete(config, notify_id, key)
				end
			end
			uci:commit(config)
			-- notify_backend_on_commit(config)

			-- apply settings of multiple ntfs
			-- for ntf_config, ntf_data in pairs(payload["ntf_data"]) do
			-- 	for ntf_type, ntf in pairs(notify_list) do
			-- 		if(ntf_config == ntf_type) then
			-- 			--ntf(notify_id):load(ntf_data)
			-- 			ntf(notify_id):set(ntf_data)
			-- 			ntf(notify_id):save()
			-- 			ntf(notify_id):commit()
			-- 		end
			-- 	end
				--success = uci:load(ntf_config) and uci:commit(ntf_config)
				--socket.sleep(0.9)
				--success = success or log(ntf_config .. "commit() error", ntf_data)
			-- end


			-- apply settings.globals
			-- local allowed_global_options = util.keys(uci:get_all(config, "globals"))
			-- for key, value in pairs(payloads["globals_data"]) do
			-- 	if util.contains(allowed_global_options, key) then
			-- 		if type(value) == "table" then
			-- 			uci:set_list(config, "globals", key, value)
			-- 		else
			-- 			uci:set(config, "globals", key, value)
			-- 		end
			-- 	end
			-- end
		end,
		default = function(...)
			-- sucsess = uci:save(config)
			-- uci:load(config)
			-- success = uci:load(config) and uci:commit(config)
			-- success = uci:commit(config)
			-- uci:commit(config)
			-- success = success or log("uci:commit() error", payload)

			http.prepare_content("text/plain")
			http.write("0")
		end
	}
	if commands[action] then
		commands[action](notify_id, payload)
		commands["default"]()
		notify_backend_on_commit('notifyconf')
	end
end
