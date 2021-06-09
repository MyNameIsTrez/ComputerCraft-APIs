-- This fix gives error() a message, so the parallel API won't ignore the raisd error anymore.
function os.pullEvent(sFilter)
	local event, p1, p2, p3, p4, p5 = os.pullEventRaw(sFilter)
	if event == "terminate" then
		error("Terminated")
	end
	return event, p1, p2, p3, p4, p5
end


http.get = function( _url )
	return wrapRequest( _url, nil )
end


http.post = function( _url, _post )
	return wrapRequest( _url, _post or "" )
end


function wrapRequest( _url, _post )
	local signals = {}
	
	local requestID = http.request( _url, _post )
	
	while true do
		local event, param1, param2 = os.pullEvent()
		
		if event == "http_success" and param1 == _url then
			queue_signals(signals)
			return param2
		elseif event == "http_failure" and param1 == _url then
			queue_signals(signals)
			return nil
		else
			local signal = { event, param1, param2 }
			table.insert(signals, signal)
		end
	end
end


function queue_signals(signals)
	for i = 1, #signals do -- queues the oldest signal first
		local n = table.maxn(signals[i])
		os.queueEvent(unpack(signals[i], 1, n))
	end
end


--[[
-- This implementation pushes and pops queued events,
-- which means os.pulLEvent() won't destroy events anymore.
--local signals = {}
function _G.sleep(time)
	local id = os.startTimer(time) -- id is a table.
	
	-- TODO: Move down above push_events().
	-- Not sure why removing the "local" breaks things.
	local signals = {}
	
	--push_events(signals)
	
	repeat
		local signal = { os.pullEvent() }
		
		-- TODO: THIS FUNCTION MAYBE WON'T EVER WORK,
		-- AS IT'S POSSIBLE THAT A SLEEP(10) GETS PROCESSED
		-- BEFORE A SLEEP(2)!
		if signal[1] ~= "timer" or signal[2] ~= id then
			table.insert(signals, signal)
		end
	until signal[1] == "timer" and signal[2] == id
	
	pop_events(signals)
end


-- TODO: Move into different file!
function push_events(signals)
	repeat
		local signal = { os.pullEvent() }
		
		-- TODO: THIS FUNCTION MAYBE WON'T EVER WORK,
		-- AS IT'S POSSIBLE THAT A SLEEP(10) GETS PROCESSED
		-- BEFORE A SLEEP(2)!
		if signal[1] ~= "timer" or signal[2] ~= id then
			table.insert(signals, signal)
		end
	until signal[1] == "timer" and signal[2] == id
end


-- TODO: Move into different file!
function pop_events(signals)
	
	local a, b = term.getCursorPos()
	term.setCursorPos(1, b + 1)
	for k, v in pairs(signals) do
		if v[1] == "timer" then
			print(v[1] .. ", " .. type(v[2]))
		else
			print(v[1] .. ", " .. v[2])
		end
	end
	term.setCursorPos(a, b)
	
	for i = 1, #signals do
		os.queueEvent(unpack(signals[i], 1, table.maxn(signals[i])))
	end
	--signals = {}
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
