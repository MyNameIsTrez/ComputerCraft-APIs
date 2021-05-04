--local events = {}

function listen() end -- TODO: REMOVE!!


local queue = {}
local callback_fns = {}
local callbacks = {}


function new_listen(event, callback_fn)
	-- TODO: Combine into a single if-statement?
	if callback_fns[event] == nil then
		callback_fns[event] = {}
	end
	if callbacks[event] == nil then
		callbacks[event] = {}
	end
	
	table.insert(callback_fns[event], callback_fn)
end


function runner()
	while true do
		print("queue[1]: ", queue[1] ~= nil)
		
		if queue[1] then
			-- TODO: Rename eventData ot event_data everywhere.
			local eventData = table.remove(queue, 1)
			local event = eventData[1]
			print("event: ", event)
			print("callback_fns[event]: ", callback_fns[event])
			
			-- TODO: Try storing indexed values in variables.
			if callback_fns[event] then
				print("#callback_fns[event]: ", #callback_fns[event])
				
				for i = 1, #callback_fns[event] do
					-- TODO: USE TABLE.UNPACK()!!
					-- If one of the params is nil, it won't
					-- return the params after it.
					
					if callbacks[event][i] == nil or
						-- TODO: Store status in variable.
							coroutine.status(callbacks[event][i]) == "dead" then
						--print("creating coroutine")
						callbacks[event][i] = coroutine.create(callback_fns[event][i])
					end
					
					--print(type(unpack(eventData)))
					coroutine.resume(callbacks[event][i], unpack(eventData))
				end
			end
		end
		
		coroutine.yield()
	end
end


-- TODO: queueHandler -> queue_handler
function queueHandler()
	while true do
		--print("starting os.pullEvent()")
		-- TODO: USE TABLE.PACK()!!!
		table.insert(queue, { os.pullEvent() } )
		--print("inserted os.pullEvent(): ", queue[#queue][1])
	end
end


new_listen("key", function()
	print("key callback fired")
	sleep(2)
end)


new_listen("char", function()
	print("char callback fired")
	sleep(4)
end)


parallel.waitForAny(queueHandler, runner)


--[[
function remove_event(event)
	events[event] = nil
end
]]--


--[[
function listen(event_arg, callback_arg)
	if type(event_arg) == "table" then
		--server.print("Loop through table of callbacks.")
		-- Loop through table of callbacks.
		for event_result, callback in pairs(event_arg) do
			if type(event_result) == "table" then
				--server.print("Loop through table of keys that call the callback.")
				-- Loop through table of keys that call the callback.
				for _, event in ipairs(event_result) do
					--server.print("event: " .. event .. ", callback: " .. tostring(callback))
					add_event(event, callback)
				end
			else
				--server.print("single event: " .. event_result .. ", callback: " .. tostring(callback))
				add_event(event_result, callback)
			end
		end
	else
		--server.print("single event: " .. event_arg .. ", single callback: " .. tostring(callback_arg))
		add_event(event_arg, callback_arg)
	end
end


function add_event(event, callback)
	if events[event] == nil then
		events[event] = {}
	end
	table.insert(events[event], callback)
end
]]--


-- TODO: Allow "event" to be a table.
--[[
function remove_listener(event, callback)
	for i, found_callback in pairs(events[event]) do
		if callback == found_callback then
			--found_callback = nil -- TODO: This may work!
			events[event][i] = nil
		end
	end
end
]]--


--[[
-- TODO: Allow "event" to be a table.
function fire(event, ...)
	if not events[event] then
		return
	end
	
	--server.print(#events[event])
	--for _, callback in ipairs(events[event]) do
	--	server.print(tostring(callback))
	--end
	
	for _, callback in ipairs(events[event]) do
		--server.print(_)
		callback(...)
	end
end
]]--


--function print_event_callbacks(event)
--	for _, callback in ipairs(events[event]) do
--		print(callback)
--	end
--end
