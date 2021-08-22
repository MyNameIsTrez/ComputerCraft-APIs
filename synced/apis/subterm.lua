local top_line_y = 1
local history = { "" } -- Initializing with an empty string so it can be concatenated with.

local record_history = true
local running_program = false

local typed_history = {}

-- Starts at 1 instead of 0, because you have to press the up arrow first to show the most recently typed command.
-- TODO: Refactor this variable away by using #typed_history.
local typed_history_index = 1

local saved_cursor_x, saved_cursor_y
-- local saved_cursor_x, saved_cursor_y = term.getCursorPos()

local w, h = term.getSize() -- TODO: Move to globals file.




local old_term_write = term.write
function term.write(...)
	if record_history then
		-- overwrite_history_line_with_typed(saved_cursor_y)
	-- 	-- server.print(..., #history, type(...), ... == "")
		history[#history] = history[#history] .. ...
		-- history[#history] = utils.typed
	end
	-- server.print(history[1])
	return old_term_write(...)
end




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
	local cursor_x, cursor_y = term.getCursorPos()
	
	local str_tab = get_str_tab(str_arg, cursor_x)
	
	local n_lines_printed = 0
	for i = 1, #str_tab do
		local str = str_tab[i]
		
		if str == "\n" then
			n_lines_printed = n_lines_printed + 1
		else
			term.setCursorPos(cursor_x, cursor_y)
			term.write(str)
			cursor_x = cursor_x + #str
			
			-- if record_history then
			-- 	history[#history] = history[#history] .. str
			-- end
		end
		--sleep(0.5)
		
		if (cursor_x > w and str ~= "") or str == "\n" then
			cursor_x = 1
			cursor_y = cursor_y == h and h or cursor_y + 1
			
			if record_history then
				history[#history + 1] = ""
			end
			
			scroll_after_write()
		end
	end
	
	term.setCursorPos(cursor_x, cursor_y)
	
	return n_lines_printed
end


function get_str_tab(str, cursor_x)
	local str_tab = {}
	for _, str2 in ipairs(split_but_keep_newlines(str)) do
		for _, str3 in ipairs(split_by_terminal_width(str2, cursor_x)) do
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
	local scroll_amount = #history - h - top_line_y + 1 -- 19 - 18 - 1 + 1 = 1
	if scroll_amount >= 1 then
		scroll_down(scroll_amount)
	end
end


function scroll_down(scroll_amount)
	if top_line_y + scroll_amount - 1 <= #history - h then -- 1 + 1 - 1 <= 19 - 18
		top_line_y = top_line_y + scroll_amount
		draw_history()

		local lines_scrolled_up = get_lines_scrolled_up()
		if lines_scrolled_up == 0 then
			term.setCursorBlink(true)
			term.setCursorPos(saved_cursor_x, saved_cursor_y)
		end
	end
end


function draw_history()
	local start_x, start_y = term.getCursorPos()
	for i = 1, h do
		local line = history[i + top_line_y - 1]
		if line ~= nil then
			term.setCursorPos(1, i)
			term.clearLine()
			old_term_write(line)
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
	if top_line_y - scroll_amount >= 1 then
		term.setCursorBlink(false)

		top_line_y = top_line_y - scroll_amount

		draw_history()
	end
end




function pressed_enter(shell)
	store_typed_in_history()
	
	write("\n")
	
	running_program = true
	shell.run(keyboard.typed) -- This can write "No such program\n"
	term.setCursorBlink(true)
	running_program = false
	
	utils.draw_cursor_prompt()

	saved_cursor_x, saved_cursor_y = term.getCursorPos()
	
	keyboard.typed = ""
end


function store_typed_in_history()
	local previously_typed = typed_history[#typed_history]
	if keyboard.typed ~= "" and keyboard.typed ~= previously_typed then
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
		
		overwrite_history_line_with_typed(cursor_y)

		saved_cursor_x, saved_cursor_y = term.getCursorPos()
	end
end


function overwrite_history_line_with_typed(cursor_y)
	local visual_cursor_y = get_visual_cursor_y(cursor_y)
	local line = utils.cursor_prompt .. keyboard.typed
	server.print(line)
	server.print("----")
	history[visual_cursor_y] = line
end


function pressed_backspace_or_delete(is_delete, cursor_x, cursor_y, typed_index)
	clear_last_char_of_typed(cursor_y)
	
	-- Moves the cursor back by 1 for backspace, does nothing for delete.
	term.setCursorPos(cursor_x - 1 + is_delete, cursor_y)
	
	-- Moves the characters after the cursor back by 1.
	local chars_moved_back = keyboard.typed:sub(typed_index + 1 + is_delete, -1)
	if chars_moved_back ~= "" then
		term.write(chars_moved_back)
	end
	
	-- Moves the cursor to its final position for backspace, does nothing for delete.
	term.setCursorPos(cursor_x - 1 + is_delete, cursor_y)
	
	keyboard.typed = keyboard.typed:sub(1, typed_index - 1 + is_delete) .. keyboard.typed:sub(typed_index + 1 + is_delete, -1)
end


function clear_last_char_of_typed(cursor_y)
	local last_char_x = utils.typing_start_x + #keyboard.typed - 1
	term.setCursorPos(last_char_x, cursor_y)
	term.write(" ")
end


function get_visual_cursor_y(cursor_y)
	return top_line_y - 1 + cursor_y
end




function move_cursor(key)
	if not running_program then
		scroll_to_bottom()

		local cursor_x, cursor_y = term.getCursorPos()

		if key == "up" then
			if typed_history[typed_history_index - 1] ~= nil then
				move_cursor_up_or_down(-1, cursor_y)
			end
		elseif key == "down" then
			if typed_history[typed_history_index + 1] ~= nil then
				move_cursor_up_or_down(1, cursor_y)
			elseif typed_history_index == #typed_history then
				move_cursor_down_clear_cursor(cursor_y)
			end
		elseif key == "left" then
			if cursor_x > utils.typing_start_x then
				term.setCursorPos(cursor_x - 1, cursor_y)
			end
		elseif key == "right" then
			if cursor_x < utils.typing_start_x + #keyboard.typed then
				term.setCursorPos(cursor_x + 1, cursor_y)
			end
		end

		saved_cursor_x, saved_cursor_y = term.getCursorPos()
	end
end


function scroll_to_bottom()
	local lines_scrolled_up = get_lines_scrolled_up()
	if lines_scrolled_up > 0 then
		scroll_down(lines_scrolled_up)
		term.setCursorBlink(true)
	end
end


function get_lines_scrolled_up()
	return math.max(#history - top_line_y + 1 - h, 0)
end


-- function get_last_typed_cursor_xy()
-- 	return #history[#history] + 1, math.min(#history, h)
-- end




function move_cursor_up_or_down(direction, cursor_y)
	local prev_typed = keyboard.typed
	
	keyboard.typed = typed_history[typed_history_index + direction]
	typed_history_index = typed_history_index + direction
	
	term.setCursorPos(utils.typing_start_x, cursor_y)
	term.write(keyboard.typed)

	local clear_char_count = #prev_typed - #keyboard.typed
	if clear_char_count > 0 then
		term.write(string.rep(" ", clear_char_count))
	end

	term.setCursorPos(utils.typing_start_x + #keyboard.typed, cursor_y)
	
	overwrite_history_line_with_typed(cursor_y)
end


function move_cursor_down_clear_cursor(cursor_y)
	term.setCursorPos(utils.typing_start_x, cursor_y)

	local clear_char_count = #keyboard.typed
	if clear_char_count > 0 then
		term.write(string.rep(" ", clear_char_count))
	end

	term.setCursorPos(utils.typing_start_x, cursor_y)
	
	keyboard.typed = ""
	typed_history_index = typed_history_index + 1
end




function pressed_char(char)
	scroll_to_bottom()

	-- local cursor_x, cursor_y = get_last_typed_cursor_xy()
	local cursor_x, cursor_y = term.getCursorPos()
	-- server.print(cursor_x, cursor_y)

	local typed_index = cursor_x - utils.typing_start_x
	-- server.print(typed_index)
	
	local back = keyboard.typed:sub(1, typed_index)
	local front = keyboard.typed:sub(typed_index + 1, -1)
	keyboard.typed = back .. char .. front
	-- server.print(back, char, front)
	
	if not running_program then
		write(keyboard.typed:sub(typed_index + 1, -1)) -- TODO: Use term.write() instead?
		-- server.print(keyboard.typed:sub(typed_index + 1, -1))
		saved_cursor_x, saved_cursor_y = cursor_x + 1, cursor_y
		term.setCursorPos(saved_cursor_x, saved_cursor_y)
		-- server.print(saved_cursor_x, saved_cursor_y)
		-- server.print(history[#history])
		-- server.print("----")
	end
end