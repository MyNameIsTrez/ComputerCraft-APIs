local bw_os_dir = "backwards_os"
local apis = fs.combine(bw_os_dir, "apis")
local cfg_path = fs.combine(apis, "backwards_os_cfg")

local fake_width, height = term.getSize()
local width = fake_width - 1

local typed_history = {}
local typed_history_index = 1 -- 1, because the first up arrow press shows the most recent command.
local running_program = false

local w, h = term.getSize() -- TODO: Move to globals file.




function add_listeners(shell)


events.listen("r", function()
	os.reboot()
end)


events.listen("t", function()
	sleep(0.05) -- So the "t" isn't printed.
	error("Terminated")
end)


-- Function of synced/apis/subterm.lua
events.listen("pageUp", function()
	scroll_up(1)
end)


events.listen("pageDown", function()
	subterm.scroll_down(1)
end)


events.listen("enter", function()
	pressed_enter(shell)
end)


events.listen( { "backspace", "delete" }, function(key)
	pressed_backspace_or_delete(key)
end)


events.listen( { "up", "down", "left", "right" }, function(key)
	if not running_program then
		move_cursor(key)
	end
end)


events.listen("char", function(_, char)
	local cursor_x, cursor_y = term.getCursorPos()
	local typed_index = cursor_x - utils.typing_start_x
	
	local back = keyboard.typed:sub(1, typed_index)
	local front = keyboard.typed:sub(typed_index + 1, -1)
	keyboard.typed = back .. char .. front
	
	if not running_program then
		write(keyboard.typed:sub(typed_index + 1, -1))
		term.setCursorPos(cursor_x + 1, cursor_y)
	end
end)


end




function scroll_up(scroll_amount)
	if subterm.start_line - scroll_amount >= 1 then
		subterm.start_line = subterm.start_line - scroll_amount
		draw_history()
	end
end


function pressed_enter(shell)
	store_typed_in_history()
	
	-- server.print(subterm.history)
	
	write("\n")
	
	running_program = true
	shell.run(keyboard.typed) -- Can write "No such program\n"
	term.setCursorBlink(true)
	running_program = false
	
	utils.draw_cursor_prompt()
	
	keyboard.typed = ""
end


function pressed_backspace_or_delete(key)
	if #keyboard.typed > 0 then
		local cursor_x, cursor_y = term.getCursorPos()
		local typed_index = cursor_x - utils.typing_start_x
		
		if key == "backspace" then
			pressed_backspace_or_delete_key(0, cursor_x, cursor_y, typed_index)
		elseif key == "delete" then
			pressed_backspace_or_delete_key(1, cursor_x, cursor_y, typed_index)
		end
		
		-- Editing the history.
		local cursor_y_history = get_cursor_y_history(cursor_y)
		local line = utils.cursor_prompt .. keyboard.typed
		subterm.history[cursor_y_history] = line
	end
end


function store_typed_in_history()
	local previously_typed = typed_history[#typed_history]
	if keyboard.typed ~= previously_typed then
		table.insert(typed_history, keyboard.typed)
	end
	typed_history_index = #typed_history + 1 -- Resetting the index to the last typed.
end


function pressed_backspace_or_delete_key(is_delete, cursor_x, cursor_y, typed_index)
	clear_last_char_of_typed(cursor_y)
	
	-- Moves the cursor back by 1 for backspace, does nothing for delete.
	term.setCursorPos(cursor_x - 1 + is_delete, cursor_y)
	
	-- Moves the characters after the cursor back by 1.
	term.write(keyboard.typed:sub(typed_index + 1 + is_delete, -1))
	
	-- Moves the cursor to its final position for backspace, does nothing for delete.
	term.setCursorPos(cursor_x - 1 + is_delete, cursor_y)
	
	keyboard.typed = keyboard.typed:sub(1, typed_index - 1 + is_delete) .. keyboard.typed:sub(typed_index + 1 + is_delete, -1)
end


function get_cursor_y_history(cursor_y)
	return subterm.start_line - 1 + cursor_y
end


function clear_last_char_of_typed(cursor_y)
	local last_char_x = utils.typing_start_x + #keyboard.typed - 1
	term.setCursorPos(last_char_x, cursor_y)
	term.write(" ")
end


function move_cursor(key)
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