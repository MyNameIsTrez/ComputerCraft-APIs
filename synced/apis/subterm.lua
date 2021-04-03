history = {} -- Public.


-- The original write function has a bug where it can't write to the rightmost position,
-- 	unless the entire line is written at once.
-- It also has a bug where write(string.rep("a", 50) .. "\n") moves the string.rep("a", 50) down with it.
-- This version is also hopefully a little faster due to being dumbed down.
original_write = function(str)
	local x, y = term.getCursorPos()
	
	local strTab = {}
	
	for _, str2 in ipairs(split_but_keep_newlines(str)) do
		--server.print(str2)
		for _, str3 in ipairs(split_by_terminal_width(str2, x)) do
			server.print(str3)
			strTab[#strTab+1] = str3
		end
	end
	--server.print(strTab)
	
	local n_lines_printed = 0
	for i = 1, #strTab do
		local str = strTab[i]
		
		server.print("x: " .. x .. ", y: " .. y .. ", #strTab: " .. #strTab .. ", str: " .. str)
		
		if str == "\n" then
			n_lines_printed = n_lines_printed + 1
		else
			term.setCursorPos(x, y)
			term.write(str)
			x = x + #str
		end
		sleep(1)
		
		if #strTab > 1 or x > 50 then
			x = 1
			y = y + 1
		end
	end
	
	term.setCursorPos(x, y)
	--server.print("n_lines_printed: " .. n_lines_printed)
	
	return n_lines_printed
end


function split_but_keep_newlines(str)
	local t = {}
	for a, b in string.gmatch(str, "([^\n]*)(\n?)") do
		if #a > 0 then t[#t+1] = a end
		if #b > 0 then t[#t+1] = b end
	end
	return t
end


local w, h = term.getSize()
function split_by_terminal_width(str, x_offset)
	local strTab = {}
	local first_line_len = w - x_offset + 1
	strTab[1] = str:sub(1, first_line_len)
	for i = first_line_len + 1, #str, w do
		strTab[#strTab + 1] = str:sub(i, i + w - 1)
	end
	return strTab
end


-- The original print function calls write(), but it needs to call original_write().
original_print = function(...)
	local nLinesPrinted = 0
	for n, v in ipairs({...}) do
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


function split_by_chunk(str, chunk_size)
	local s = {}
	
	for i = 1, #str, chunk_size do
		s[#s + 1] = str:sub(i, i + chunk_size - 1)
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
