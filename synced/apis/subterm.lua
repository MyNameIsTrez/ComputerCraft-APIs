history = { "" } -- Initializing with an empty string so it can be concatenated with.


local record_history = true
local start_line = 1


-- The original write function has a bug where it can't write to the rightmost position,
-- 	unless the entire line is written at once.
-- It also has a bug where write(string.rep("a", 50) .. "\n") moves the string.rep("a", 50) down with it.
-- This version is also hopefully a little faster due to being dumbed down.
_G.write = function(str)
	local x, y = term.getCursorPos()
	
	local str = tostring(str)
	
	local strTab = {}
	
	for _, str2 in ipairs(split_but_keep_newlines(str)) do
		--server.print("str2: " .. str2)
		for _, str3 in ipairs(split_by_terminal_width(str2, x)) do
			--server.print("str3: " .. str3)
			strTab[#strTab+1] = str3
		end
	end
	--server.print(strTab)
	
	local n_lines_printed = 0
	for i = 1, #strTab do
		local str = strTab[i]
		
		--server.print("x: " .. x .. ", y: " .. y .. ", #strTab: " .. #strTab .. ", str: " .. str)
		
		if str == "\n" then
			n_lines_printed = n_lines_printed + 1
		else
			term.setCursorPos(x, y)
			term.write(str)
			x = x + #str
			
			if record_history then
				history[#history] = history[#history] .. str
			end
		end
		--sleep(0.5)
		
		if x > 50 or str == "\n" then
			x = 1
			y = y + 1
			
			if record_history then
				history[#history+1] = ""
			end
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


_G.print = function(...)
	local n_lines_printed = 0
	for n, v in ipairs({...}) do
		n_lines_printed = n_lines_printed + write(v)
	end
	n_lines_printed = n_lines_printed + write("\n")
	return n_lines_printed
end


function enable_history_recording()
	record_history = true
end


function disable_history_recording()
	record_history = false
end


function scroll_up(scroll_amount)
	--server.print(#history)
	if start_line - scroll_amount >= 1 then
		start_line = start_line - scroll_amount
		print_history()
	end
end


function scroll_down(scroll_amount)
	--server.print(#history)
	if start_line + scroll_amount <= #history - h then
		start_line = start_line + scroll_amount
		print_history()
	end
end


function print_history()
	for i = 1, h do
		local line = history[i + start_line - 1]
		if (line ~= nil) then
			term.setCursorPos(1, i)
			term.write(string.rep(" ", w))
			term.setCursorPos(1, i)
			term.write(line)
		end
	end
end
