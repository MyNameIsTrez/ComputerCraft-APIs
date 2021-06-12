-- This fix gives error() a message, so the parallel API won't ignore the raisd error anymore.
function os.pullEvent(sFilter)
	local event, p1, p2, p3, p4, p5 = os.pullEventRaw(sFilter)
	if event == "terminate" then
		error("Terminated")
	end
	return event, p1, p2, p3, p4, p5
end


rawset(http, "get_lossy", http.get)
http.get = nil
rawset(http, "get_lossless", function( _url )
	return wrapRequest( _url, nil )
end)


rawset(http, "post_lossy", http.post)
http.post = nil
rawset(http, "post_lossless", function( _url, _post )
	return wrapRequest( _url, _post or "" )
end)


function wrapRequest( _url, _post )
	local unused_events = {}
	
	local requestID = http.request( _url, _post )
	
	while true do
		local event, param1, param2 = os.pullEvent()
		
		if event == "http_success" and param1 == _url then
			requeue(unused_events)
			return param2
		elseif event == "http_failure" and param1 == _url then
			requeue(unused_events)
			return nil
		else
			local unused_event = { event, param1, param2 }
			table.insert(unused_events, unused_event)
		end
	end
end


function requeue(unused_events)
	for _, unused_event in ipairs(unused_events) do
		local n = table.maxn(unused_event) -- TODO: Necessary in case of nil values?
		os.queueEvent(unpack(unused_event, 1, n))
	end
end


--[[
-- This implementation pushes and pops queued events,
-- which means os.pulLEvent() won't destroy events anymore.
--local unused_events = {}
function _G.sleep(time)
	local id = os.startTimer(time) -- id is a table.
	
	-- TODO: Move down above push_events().
	-- Not sure why removing the "local" breaks things.
	local unused_events = {}
	
	--push_events(unused_events)
	
	repeat
		local signal = { os.pullEvent() }
		
		-- TODO: THIS FUNCTION MAYBE WON'T EVER WORK,
		-- AS IT'S POSSIBLE THAT A SLEEP(10) GETS PROCESSED
		-- BEFORE A SLEEP(2)!
		if signal[1] ~= "timer" or signal[2] ~= id then
			table.insert(unused_events, signal)
		end
	until signal[1] == "timer" and signal[2] == id
	
	pop_events(unused_events)
end


-- TODO: Move into different file!
function push_events(unused_events)
	repeat
		local signal = { os.pullEvent() }
		
		-- TODO: THIS FUNCTION MAYBE WON'T EVER WORK,
		-- AS IT'S POSSIBLE THAT A SLEEP(10) GETS PROCESSED
		-- BEFORE A SLEEP(2)!
		if signal[1] ~= "timer" or signal[2] ~= id then
			table.insert(unused_events, signal)
		end
	until signal[1] == "timer" and signal[2] == id
end


-- TODO: Move into different file!
function pop_events(unused_events)
	
	local a, b = term.getCursorPos()
	term.setCursorPos(1, b + 1)
	for k, v in pairs(unused_events) do
		if v[1] == "timer" then
			print(v[1] .. ", " .. type(v[2]))
		else
			print(v[1] .. ", " .. v[2])
		end
	end
	term.setCursorPos(a, b)
	
	for i = 1, #unused_events do
		os.queueEvent(unpack(unused_events[i], 1, table.maxn(unused_events[i])))
	end
	--unused_events = {}
end
]]--


--[[
table.unpack = unpack
]]--


--[[
function table.pack(...)
  return { n = select("#", ...), ... }
end 
]]--
