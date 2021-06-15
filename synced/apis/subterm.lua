local start_line = 1
local history = { "" } -- Initializing with an empty string so it can be concatenated with.

local record_history = true
local running_program = false

local typed_history = {}
local typed_history_index = 1 -- 1, because the first up arrow press shows the most recent command.

local w, h = term.getSize() -- TODO: Move to globals file.




_G.print = function(...)
	local n_lines_printed = 0
	for n, v in ipairs({...}) do
		n_lines_printed = n_lines_printed + write(v)
	end
	n_lines_printed = n_lines_printed + write("\n")
	return n_lines_printed
end




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
	local scroll_amount = #history - h - start_line + 1 -- 19 - 18 - 1 + 1 = 1
	if scroll_amount >= 1 then
		scroll_down(scroll_amount)
	end
end


function scroll_down(scroll_amount)
	if start_line + scroll_amount - 1 <= #history - h then -- 1 + 1 - 1 <= 19 - 18
		start_line = start_line + scroll_amount
		draw_history()
	end
end


function draw_history()
	local start_x, start_y = term.getCursorPos()
	for i = 1, h do
		local line = history[i + start_line - 1]
		if line ~= nil then
			term.setCursorPos(1, i)
			term.clearLine()
			term.write(line)
		end
	end
end




function enable_history_recording()
	record_history = true
end


function disable_history_recording()
	record_history = false
end




function scroll_up(scroll_amount)
	if start_line - scroll_amount >= 1 then
		start_line = start_line - scroll_amount
		draw_history()
	end
end




function pressed_enter(shell)
	store_typed_in_history()
	
	-- server.print(history)
	
	write("\n")
	
	running_program = true
	shell.run(keyboard.typed) -- Can write "No such program\n"
	term.setCursorBlink(true)
	running_program = false
	
	utils.draw_cursor_prompt()
	
	keyboard.typed = ""
end


function store_typed_in_history()
	local previously_typed = typed_history[#typed_history]
	if keyboard.typed ~= previously_typed then
		table.insert(typed_history, keyboard.typed)
	end
	typed_history_index = #typed_history + 1 -- Resetting the index to the last typed.
end




function pressed_backspace_or_delete_overseer(key)
	if #keyboard.typed > 0 then
		local cursor_x, cursor_y = term.getCursorPos()
		local typed_index = cursor_x - utils.typing_start_x
		
		if key == "backspace" then
			pressed_backspace_or_delete(0, cursor_x, cursor_y, typed_index)
		elseif key == "delete" then
			pressed_backspace_or_delete(1, cursor_x, cursor_y, typed_index)
		end
		
		-- Editing the history.
		local cursor_y_history = get_cursor_y_history(cursor_y)
		local line = utils.cursor_prompt .. keyboard.typed
		history[cursor_y_history] = line
	end
end


function pressed_backspace_or_delete(is_delete, cursor_x, cursor_y, typed_index)
	clear_last_char_of_typed(cursor_y)
	
	-- Moves the cursor back by 1 for backspace, does nothing for delete.
	term.setCursorPos(cursor_x - 1 + is_delete, cursor_y)
	
	-- Moves the characters after the cursor back by 1.
	term.write(keyboard.typed:sub(typed_index + 1 + is_delete, -1))
	
	-- Moves the cursor to its final position for backspace, does nothing for delete.
	term.setCursorPos(cursor_x - 1 + is_delete, cursor_y)
	
	keyboard.typed = keyboard.typed:sub(1, typed_index - 1 + is_delete) .. keyboard.typed:sub(typed_index + 1 + is_delete, -1)
end


function clear_last_char_of_typed(cursor_y)
	local last_char_x = utils.typing_start_x + #keyboard.typed - 1
	term.setCursorPos(last_char_x, cursor_y)
	term.write(" ")
end


function get_cursor_y_history(cursor_y)
	return start_line - 1 + cursor_y
end




function move_cursor(key)
	if not running_program then
		local x, y = term.getCursorPos()

		if key == "up" then
			if typed_history[typed_history_index - 1] ~= nil then
				move_cursor_up_or_down(-1, y)
			end
		elseif key == "down" then
			if typed_history[typed_history_index + 1] ~= nil then
				move_cursor_up_or_down(1, y)
			elseif typed_history_index == #typed_history then
				move_cursor_down_clear_cursor(y)
			end
		elseif key == "left" then
			if x > utils.typing_start_x then
				term.setCursorPos(x - 1, y)
			end
		elseif key == "right" then
			if x < utils.typing_start_x + #keyboard.typed then
				term.setCursorPos(x + 1, y)
			end
		end
	end
end




function move_cursor_up_or_down(direction, y)
	local prev_typed = keyboard.typed
	
	keyboard.typed = typed_history[typed_history_index + direction]
	typed_history_index = typed_history_index + direction
	
	term.setCursorPos(utils.typing_start_x, y)
	term.write(keyboard.typed)

	local clear_char_count = #prev_typed - #keyboard.typed
	if clear_char_count > 0 then
		term.write(string.rep(" ", clear_char_count))
	end

	term.setCursorPos(utils.typing_start_x + #keyboard.typed, y)
end


function move_cursor_down_clear_cursor(y)
	term.setCursorPos(utils.typing_start_x, y)

	local clear_char_count = #keyboard.typed
	if clear_char_count > 0 then
		term.write(string.rep(" ", clear_char_count))
	end

	term.setCursorPos(utils.typing_start_x, y)
	
	keyboard.typed = ""
	typed_history_index = typed_history_index + 1
end




function pressed_char(char)
	local cursor_x, cursor_y = term.getCursorPos()
	local typed_index = cursor_x - utils.typing_start_x
	
	local back = keyboard.typed:sub(1, typed_index)
	local front = keyboard.typed:sub(typed_index + 1, -1)
	keyboard.typed = back .. char .. front
	
	if not running_program then
		write(keyboard.typed:sub(typed_index + 1, -1))
		term.setCursorPos(cursor_x + 1, cursor_y)
	end
end