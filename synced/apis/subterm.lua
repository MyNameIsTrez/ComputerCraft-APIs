start_line = 1
history = { "" } -- Initializing with an empty string so it can be concatenated with.


local record_history = true

local w, h = term.getSize() -- TODO: Move to globals file.


-- The original write function has a bug where it can't write to the rightmost position,
-- 	unless the entire line is written at once.
-- It also has a bug where write(string.rep("a", w) .. "\n") moves the string.rep("a", w) down with it.
-- This version is also hopefully a little faster due to being dumbed down.
_G.write = function(str_arg)
	local str_arg = tostring(str_arg)
	local x, y = term.getCursorPos()
	
	local str_tab = get_str_tab(str_arg, x)
	
	local n_lines_printed = 0
	for i = 1, #str_tab do
		local str = str_tab[i]
		
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
		
		-- and str ~= "" reproduces vanilla CC behavior.
		if (x > w and str ~= "") or str == "\n" then
			x = 1
			y = y == h and h or y + 1
			
			if record_history then
				history[#history + 1] = ""
			end
			
			scroll_after_write()
		end
	end
	
	term.setCursorPos(x, y)
	
	return n_lines_printed
end


function get_str_tab(str, x)
	local str_tab = {}
	for _, str2 in ipairs(split_but_keep_newlines(str)) do
		for _, str3 in ipairs(split_by_terminal_width(str2, x)) do
			str_tab[#str_tab+1] = str3
		end
	end
	return str_tab
end


function split_but_keep_newlines(str)
	local t = {}
	for a, b in string.gmatch(str, "([^\n]*)(\n?)") do
		if #a > 0 then t[#t + 1] = a end
		if #b > 0 then t[#t + 1] = b end
	end
	return t
end


function split_by_terminal_width(str, x_offset)
	local t = {}
	local first_line_len = w - x_offset + 1
	t[1] = str:sub(1, first_line_len)
	for i = first_line_len + 1, #str, w do
		t[#t + 1] = str:sub(i, i + w - 1)
	end
	return t
end


function scroll_after_write()
	local scroll_amount = #history - h - subterm.start_line + 1 -- 19 - 18 - 1 + 1 = 1
	if scroll_amount >= 1 then
		scroll_down(scroll_amount)
	end
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
	if subterm.start_line - scroll_amount >= 1 then
		subterm.start_line = subterm.start_line - scroll_amount
		print_history()
	end
end


function scroll_down(scroll_amount)
	if subterm.start_line + scroll_amount - 1 <= #history - h then -- 1 + 1 - 1 <= 19 - 18
		subterm.start_line = subterm.start_line + scroll_amount
		print_history()
	end
end


function print_history()
	local start_x, start_y = term.getCursorPos()
	for i = 1, h do
		local line = history[i + subterm.start_line - 1]
		if line ~= nil then
			term.setCursorPos(1, i)
			term.clearLine()
			term.write(line)
		end
	end
end
