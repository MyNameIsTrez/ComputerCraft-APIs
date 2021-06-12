local bw_os_dir = "backwards_os"
local apis = fs.combine(bw_os_dir, "apis")
local cfg_path = fs.combine(apis, "backwards_os_cfg")

local fake_width, height = term.getSize()
local width = fake_width - 1

local typed_history = {}
local typed_history_index = 1 -- 1, because the first up arrow press shows the most recent command.
local running_program = false

local typing_start_x
--local typing_start_y = 1


function add_listeners(shell)


-- TODO: Hardcoding this here doesn't seem like a good idea.
typing_start_x = term.getCursorPos()


events.listen("r", function()
	os.reboot()
end)

events.listen("t", function()
	sleep(0.05) -- So the "t" isn't printed.
	error("Terminated")
end)

-- Function of synced/apis/subterm.lua
events.listen("pageUp", function()
	subterm.scroll_up(1)
end)

events.listen("pageDown", function()
	subterm.scroll_down(1)
end)

events.listen("enter", function()
	store_typed_in_history()
	
	write("\n")
	
	running_program = true
	shell.run(keyboard.typed) -- Can write "No such program\n"
	term.setCursorBlink(true)
	running_program = false
	
	write("> ")
	
	local x, y = term.getCursorPos()
	typing_start_x = x
	--typing_start_y = y
	
	keyboard.typed = ""
end)

events.listen( { "backspace", "delete" }, function(key)
	if #keyboard.typed > 0 then
		local cursor_x, cursor_y = term.getCursorPos()
		local typed_cursor_index = cursor_x - typing_start_x
		--local y = 
		
		if key == "backspace" then
			backspace_key_pressed(cursor_x, cursor_y, typed_cursor_index)
		elseif key == "delete" then
			delete_key_pressed(cursor_x, cursor_y, typed_cursor_index)
		end
	end
end)

events.listen( { "up", "down", "left", "right" }, function(key)
	if not running_program then
		move_cursor(key)
	end
end)

events.listen("char", function(_, char)
	local cursor_x, cursor_y = term.getCursorPos()
	local typed_cursor_index = cursor_x - typing_start_x
	
	local back = keyboard.typed:sub(1, typed_cursor_index)
	local front = keyboard.typed:sub(typed_cursor_index + 1, -1)
	keyboard.typed = back .. char .. front
	
	if not running_program then
		write(keyboard.typed:sub(typed_cursor_index + 1, -1))
		term.setCursorPos(cursor_x + 1, cursor_y)
	end
end)


end


function store_typed_in_history()
	local previously_typed = typed_history[#typed_history]
	if keyboard.typed ~= previously_typed then
		table.insert(typed_history, keyboard.typed)
	end
	typed_history_index = #typed_history + 1 -- Resetting the index to the last typed.
end


function backspace_key_pressed(cursor_x, cursor_y, typed_cursor_index)
	-- Clears the last character of the line.
	term.setCursorPos(typing_start_x + #keyboard.typed - 1, cursor_y)
	term.write(" ")
	
	-- Moves the cursor back by 1.
	term.setCursorPos(cursor_x - 1, cursor_y)
	-- Moves the characters after the cursor back by 1.
	term.write(keyboard.typed:sub(typed_cursor_index + 1, -1))
	
	-- Moves the cursor to its final position.
	term.setCursorPos(cursor_x - 1, cursor_y)
	
	keyboard.typed = keyboard.typed:sub(1, typed_cursor_index - 1) .. keyboard.typed:sub(typed_cursor_index + 1, -1)
end


function delete_key_pressed(cursor_x, cursor_y, typed_cursor_index)
	-- Clears the last character of the line.
	term.setCursorPos(typing_start_x + #keyboard.typed - 1, cursor_y)
	term.write(" ")
	
	-- Moves the characters after the cursor back by 1.
	term.setCursorPos(cursor_x, cursor_y)
	term.write(keyboard.typed:sub(typed_cursor_index + 2, -1))
	
	-- Moves the cursor to its final position.
	term.setCursorPos(cursor_x, cursor_y)
	
	keyboard.typed = keyboard.typed:sub(1, typed_cursor_index) .. keyboard.typed:sub(typed_cursor_index + 2, -1)
end


function move_cursor(key)
	local x, y = term.getCursorPos()
	if key == "up" then
		move_cursor_up(x, y)
	end
	if key == "down" then
		move_cursor_down(x, y)
	end
	if key == "left" then
		if x > typing_start_x then
			term.setCursorPos(x - 1, y)
		end
	end
	if key == "right" then
		if x < typing_start_x + #keyboard.typed then
			term.setCursorPos(x + 1, y)
		end
	end
end


-- TODO: Shares a lot of duplicate code with move_cursor_down()
function move_cursor_up(x, y)
	if typed_history[typed_history_index - 1] ~= nil then
		local prev_typed = keyboard.typed
		
		keyboard.typed = typed_history[typed_history_index - 1]
		typed_history_index = typed_history_index - 1
		
		term.setCursorPos(typing_start_x, y)
		term.write(keyboard.typed)
		local clear_char_count = #prev_typed - #keyboard.typed
		if clear_char_count > 0 then
			term.write(string.rep(" ", clear_char_count))
		end
		term.setCursorPos(typing_start_x + #keyboard.typed, y)
	end
end


function move_cursor_down(x, y)
	if typed_history_index == #typed_history then -- Clear the cursor line.
		term.setCursorPos(typing_start_x, y)
		local clear_char_count = #keyboard.typed
		if clear_char_count > 0 then
			term.write(string.rep(" ", clear_char_count))
		end
		term.setCursorPos(typing_start_x, y)
		
		keyboard.typed = ""
		typed_history_index = typed_history_index + 1
	elseif typed_history[typed_history_index + 1] ~= nil then
		local prev_typed = keyboard.typed
		
		keyboard.typed = typed_history[typed_history_index + 1]
		typed_history_index = typed_history_index + 1
		
		term.setCursorPos(typing_start_x, y)
		term.write(keyboard.typed)
		local clear_char_count = #prev_typed - #keyboard.typed
		if clear_char_count > 0 then
			term.write(string.rep(" ", clear_char_count))
		end
		term.setCursorPos(typing_start_x + #keyboard.typed, y)
	end
end