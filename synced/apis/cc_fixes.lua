-- Gives error() a message so the parallel API won't ignore the error.
function os.pullEvent(sFilter)
	local event, p1, p2, p3, p4, p5 = os.pullEventRaw(sFilter)
	if event == "terminate" then
		error("Terminated")
	end
	return event, p1, p2, p3, p4, p5
end


-- This implementation pushes and pops queued events,
-- which means os.pulLEvent() won't destroy events anymore.
function _G.sleep(time)
	local id = os.startTimer(time) -- id is a table.
	local signals = {}
	
	repeat
		local signal = { os.pullEvent() }
		
		if signal[1] ~= "timer" or signal[2] ~= id then
			table.insert(signals, signal)
		end
	until signal[1] == "timer" and signal[2] == id
	
	for i = 1, #signals do
		os.queueEvent(unpack(signals[i], 1, table.maxn(signals[i])))
	end
end


--[[
table.unpack = unpack
]]--


--[[
function table.pack(...)
  return { n = select("#", ...), ... }
end 
]]--
