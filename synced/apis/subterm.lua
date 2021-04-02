history = {} -- Public.


original_write = write


--[[
-- The original write function has a bug where it can't write to the rightmost position,
-- 	unless the entire line is written at once.
-- It also has a bug where write(string.rep("a", 50) .. "\n") moves the string.rep("a", 50) down with it.
-- This version is also hopefully a little faster due to being dumbed down.
original_write = function(str)
	local w, h = term.getSize()
	local x, y = term.getCursorPos()
	
	local strTab = split_by_chunk_x_offset(str, 50, x)
	server.print(strTab)
	
	term.write(strTab[1])
	
	for i = 2, #strTab do
		term.write(strTab[i])
		y = y + 1
		term.setCursorPos(x, y)
	end
	
	return #strTab
end
]]--


function split_by_chunk_x_offset(text, chunk_size, x_offset)
	local s = {}
	
	-- TODO: Maybe take x_offset = 1 outside of this loop by doing the first sub manually.
	--       Do benchmark the performance difference though, cause it could also be worse.
	for i = 1, #text, chunk_size - x_offset + 1 do
		s[#s + 1] = text:sub(i, i + chunk_size - 1 - x_offset + 1)
		x_offset = 1
	end
	
	return s
end


-- The original print function calls write(), but it needs to call original_write().
original_print = function(...)
	local nLinesPrinted = 0
	for n,v in ipairs({...}) do
		nLinesPrinted = nLinesPrinted + original_write(tostring(v))
	end
	nLinesPrinted = nLinesPrinted + original_write("\n")
	return nLinesPrinted
end


function history_print(...)
	local str = ""
	for _, argStr in ipairs({...}) do
		str = str .. tostring(argStr)
	end
	
	table.insert(history, str)
	table.insert(history, "")
	
	return original_print(...)
end


function history_write(argStr)
	if #history > 0 then
		local strTab = split_by_chunk(history[#history] .. tostring(argStr), 50)
		local historyLen = #history
		
		for i = 1, #strTab do
			history[historyLen + i - 1] = strTab[i]
		end
	else
		local strTab = split_by_chunk(tostring(argStr), 50)
		for i = 1, #strTab do
			history[i] = strTab[i]
		end
	end
	
	return original_write(tostring(argStr))
end


function split_by_chunk(text, chunk_size)
	local s = {}
	
	for i = 1, #text, chunk_size do
		s[#s + 1] = text:sub(i, i + chunk_size - 1)
	end
	
	return s
end


function enable_history_recording()
	_G.print = history_print -- Can't use "print =" here.
	_G.write = history_write
end


function disable_history_recording()
	_G.print = original_print
	_G.write = original_write
end


function debug_print_history()
	original_write(#history)
	for _, str in ipairs(history) do
		original_print(str)
		--original_write(str)
	end
end
