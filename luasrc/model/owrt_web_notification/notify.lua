local uci = require "luci.model.uci".cursor()
local util = require "luci.util"
local config = "notifyconf"
local notify_section = "notify"

local notify = {}
notify.loaded = {}

function arr_exist(arr, val)
	for index, value in ipairs(arr) do
		if value == val then
			return true
		end
	end
	return false
end

function notify:new()
	local prototype = uci:get_all(config, "prototype")
	for _, k in pairs({".name", ".anonymous", ".type", ".index"}) do prototype[k] = nil end
	local count = 0
	local ntfids = {}
	local ntfnames = {}
	local newntf = ''
	uci:foreach(config, notify_section, function(n)
		if n[".name"] ~= 'prototype' then
			ntfids[#ntfids+1] = n[".name"]
			ntfnames[#ntfnames+1] = n["name"]
			count = count + 1
		end
	end
	)

	local isnewntf = false
	local defaultntf = 100000
	local newntf = ''
	while isnewntf == false do
		if arr_exist(ntfids, 'ntf' .. tostring(defaultntf)) then
			defaultntf = defaultntf + 1
		else
			newntf = 'ntf' .. tostring(defaultntf)
			isnewntf = true
		end
	end

	local isnewntfname = false
	local defaultntfname = count
	local newntfname = ''
	while isnewntfname == false do
		if arr_exist(ntfnames, prototype["name"] .. " " .. tostring(defaultntfname + 1)) then
			defaultntfname = defaultntfname + 1
		else
			newntfname = prototype["name"] .. " " .. tostring(defaultntfname + 1)
			isnewntfname = true
		end
	end

	prototype["name"] = newntfname

	local notify_id = uci:section(config, notify_section, newntf, prototype) or log("Unable to do uci:section()", {notify_section, prototype})
	notify.loaded = prototype
	notify.id = notify_id
	success = uci:commit(config) or log("Unable to uci:commit()", {config, 'New Notify'} )
	return notify
end

function notify:get(optname)
	return notify.loaded[optname]
end

function notify:set(optname, value)
	local id = notify.id
	local success = uci:set(config, id, optname, value) or log("Unable to uci:set()", {config, id, optname, value})
	success = uci:commit(config) or log("Unable to uci:commit()", {config, id, optname, value} )
end

function notify:delete()
	local id = notify.id
	local sucsess = uci:delete(config, id) or log("Unable to uci:delete()", {config, id})
	succsess = uci:commit(config) or log("Unable uci:commit() after uci:delete", {config})
end

function notify:render(optname)
	local globals = uci:get_all(config, "globals")
	local value = notify.loaded[optname]
	local rendered = {
		-- Render specific representation of these options:
		---------------------------------------------------
		state = function()
			local state_label = ''
			if value == '1' then state_label = 'ВКЛ.'
			elseif value == '0' then state_label = 'ВЫКЛ.'
			else state_label = '--'
			end
			return state_label
		end,

		event = function()
			local event_label = {}
			for _, s in pairs(globals["event"]) do
				-- for k, v in s.gmatch(s, "(%d+)\.(.*)") do
				k, v = s:match"([^.]*).(.*)"
				event_label[k] = v
			end
			return event_label[value]
		end,

		method = function()
			local method_label = {}
			for _, s in pairs(globals["method"]) do
				-- for k, v in s.gmatch(s, "(%d+)\.(.*)") do
				k, v = s:match"([^.]*).(.*)"
				method_label[k] = v
			end
			return method_label[value]
		end,

		-- All trivial options are rendered as is.
		-----------------------------------------
		default = function(optname)
			return notify:get(optname)
		end
	}
	return rendered[optname] ~= nil and rendered[optname]() or rendered['default'](optname)
end

-- Make a Functable to load notify with "notify(id)" style
local metatable = {
	__call = function(table, ...)

		-- if id provided, then load from uci or create with template
		-- if id not provided, then only create the object for methods using
		local id = arg[1] ~= nil and arg[1] or nil
		if(id) then
			table.id = id
			table.loaded = uci:get_all(config, id) or table:new(id)
		end
		return table
	end
}
setmetatable(notify, metatable)


return(notify)