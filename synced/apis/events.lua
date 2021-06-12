events = {}


function listen(event_arg, callback)
	if type(event_arg) == "table" then
		for _, event in pairs(event_arg) do
			add_event(event, callback)
		end
	else
		add_event(event_arg, callback)
	end
end


function add_event(event, callback)
	if events[event] == nil then
		events[event] = {}
	end
	table.insert(events[event], callback)
end


-- TODO: Allow "event" to be a table.
function fire(event, ...)
	if not events[event] then
		return
	end
	
	for _, callback in ipairs(events[event]) do
		callback(event, ...)
	end
end


--function print_event_callbacks(event)
--	for _, callback in ipairs(events[event]) do
--		print(callback)
--	end
--end


-- TODO: Allow the "event" argument to be a table.
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
function listen() end -- TODO: REMOVE!!


local queue = {}
local coroutine_fns = {}
local coroutines = {}
local suspended_coroutines = {}


function new_listen(event, callback_fn)
	-- TODO: Combine into a single if-statement?
	if coroutine_fns[event] == nil then
		coroutine_fns[event] = {}
	end
	if coroutines[event] == nil then
		coroutines[event] = {}
	end
	
	table.insert(coroutine_fns[event], callback_fn)
end


function queue_handler()
	while true do
		-- TODO: USE TABLE.PACK()!
		table.insert(queue, { os.pullEvent() } )
	end
end


function runner()
	while true do
		print("queue[1]: ", queue[1] ~= nil)
		
		if queue[1] then
			local event_data = table.remove(queue, 1) -- Handles the oldest event first.
			local event = event_data[1]
			
			-- TODO: Try storing indexed values in variables.
			if coroutine_fns[event] then
				for i = 1, #coroutine_fns[event] do
					if coroutines[event][i] == nil or coroutine.status(coroutines[event][i]) == "dead" then
						coroutines[event][i] = coroutine.create(coroutine_fns[event][i])
					end
					
					-- TODO: USE TABLE.UNPACK()!
					-- If one of the params is nil, it won't
					-- return the params after it.
					local _, returned_event = coroutine.resume(coroutines[event][i], unpack(event_data))
					print("returned event from coroutine.resume(): ", returned_event)
					
					local status = coroutine.status(coroutines[event][i])
					if status == "suspended" then -- If os.yield() was called.
						if suspended_coroutines[returned_event] == nil then
							suspended_coroutines[returned_event] = {}
						end
						table.insert(suspended_coroutines[returned_event], coroutines[event][i])
					end
				end
			end
		end
		
		coroutine.yield()
	end
end


new_listen("key", function()
	print("key callback fired")
	sleep(2)
	print("key success!")
end)


new_listen("char", function()
	print("char callback fired")
	sleep(4)
	print("char success!")
end)


parallel.waitForAny(queue_handler, runner)
]]--
