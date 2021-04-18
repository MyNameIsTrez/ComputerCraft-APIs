local events = {}


local function add_event(event)
	events[event] = {}
end


--[[
function remove_event(event)
	events[event] = nil
end
]]--


-- TODO: Allow "event" to be a table.
function listen(event, callback)
	if events[event] == nil then
		add_event(event)
	end
	table.insert(events[event], callback)
end


-- TODO: Allow "event" to be a table.
function remove_listener(event, callback)
	for i, found_callback in pairs(events[event]) do
		if callback == found_callback then
			--found_callback = nil -- TODO: This may work!
			events[event][i] = nil
		end
	end
end


-- TODO: Allow "event" to be a table.
function fire(event)
	if not events[event] then
		return
	end
	
	for _, callback in ipairs(events[event]) do
		callback()
	end
end


function print_event_callbacks(event)
	for _, callback in ipairs(events[event]) do
		print(callback)
	end
end
