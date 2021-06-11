local bw_os_dir = "backwards_os"
local apis = fs.combine(bw_os_dir, "apis")
local cfg_path = fs.combine(apis, "backwards_os_cfg")

local fake_width, height = term.getSize()
local width = fake_width - 1

local typing_start_x -- Initialized in main()
--local typing_start_y = 1
local typed_history = {}
local typed_history_index = 0
local running_program = false


function premain()
	parallel.waitForAny(
		keyboard.listen,
		listen_file_update,
		main
	)
end


-- TODO: Replace with events.listen call.
function listen_file_update()
	while true do
		-- The server responds every N seconds.
		if long_poll.listen() == "true" then
			os.reboot()
		end
	end
end


function main()
	term.write("> ")
	-- This line below is in case the string above gets changed.
	typing_start_x = term.getCursorPos()
	
	term.setCursorBlink(true)
	
	-- TODO: If you type a single "a" character, commenting this back in makes n+1 "a" characters appear every 10s, instead of just +1. So somehow this program is making copies of fired "a" character events API events, or of vanilla queued events.
	shell.run("backwards_os/synced/programs/crafting_gui")
	
	sleep(1e6)
end


local events_tab = {}


events_tab["r"] = function()
	os.reboot()
end

events_tab["t"] = function()
	sleep(0.05) -- So the "t" isn't printed.
	error("Terminated")
end

-- Function of synced/apis/subterm.lua
events_tab["pageUp"] = function()
	subterm.scroll_up(1)
	--server.print("typed pageUp")
end

events_tab["pageDown"] = function()
	subterm.scroll_down(1)
	--server.print("typed pageDown")
end

events_tab["enter"] = function()
	local previously_typed = typed_history[#typed_history]
	if keyboard.typed ~= previously_typed then
		table.insert(typed_history, keyboard.typed)
	end
	
	-- "+ 1", because the first up arrow press shows the most recent command.
	typed_history_index = #typed_history + 1
	
	write("\n")
	
	running_program = true
	shell.run(keyboard.typed)
	running_program = false
	
	term.write("> ")
	
	local x, y = term.getCursorPos()
	typing_start_x = x
	--typing_start_y = y
	
	keyboard.typed = ""
end

-- TODO: Move into function.
events_tab[ { "backspace", "delete" } ] = function()
	if #keyboard.typed > 0 then
		local cursor_x, cursor_y = term.getCursorPos()
		local typed_cursor_index = cursor_x - typing_start_x
		--local y = 
		
		if key == "backspace" then
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
		elseif key == "delete" then
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
	end
end

events_tab[ { "up", "down", "left", "right" } ] = function(key)
	if not running_program then
		move_cursor(key)
	end
end

events_tab["char"] = function(char)
	--server.print("bar")
	--server.print("")
	
	--[[ Showcase of how it's possible to print before typing chars.
	local a, b = term.getCursorPos()
	term.setCursorPos(1, 2)
	write(char)
	term.setCursorPos(a, b)
	]]--
	
	local cursor_x, cursor_y = term.getCursorPos()
	--server.print("cursor_x: " .. cursor_x .. ", cursor_y: " .. cursor_y)
	--print(char)
	local typed_cursor_index = cursor_x - typing_start_x
	--server.print("typed_cursor_index: " .. typed_cursor_index)
	
	--keyboard.typed = keyboard.typed .. char
	--print(char)
	local back = keyboard.typed:sub(1, typed_cursor_index)
	local front = keyboard.typed:sub(typed_cursor_index + 1, -1)
	keyboard.typed = back .. char .. front
	--server.print("keyboard.typed: " .. keyboard.typed)
	
	if not running_program then
		write(keyboard.typed:sub(typed_cursor_index + 1, -1))
		term.setCursorPos(cursor_x + 1, cursor_y)
	end
	--server.print(keyboard.typed)
end


events.listen(events_tab)


function move_cursor(key)
	local x, y = term.getCursorPos()
	if key == "up" then
		if typed_history[typed_history_index - 1] ~= nil then
			local prev_typed = keyboard.typed
			
			keyboard.typed = typed_history[typed_history_index - 1]
			typed_history_index = typed_history_index - 1
			
			--server.print(prev_typed)
			--server.print(keyboard.typed)
			--server.print(#prev_typed - #keyboard.typed)
			
			term.setCursorPos(typing_start_x, y)
			term.write(keyboard.typed)
			local clear_char_count = #prev_typed - #keyboard.typed
			if clear_char_count > 0 then
				term.write(string.rep(" ", clear_char_count))
			end
			term.setCursorPos(typing_start_x + #keyboard.typed, y)
		end
	end
	if key == "down" then
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
			
			--server.print(prev_typed)
			--server.print(keyboard.typed)
			--server.print(#prev_typed - #keyboard.typed)
			
			term.setCursorPos(typing_start_x, y)
			term.write(keyboard.typed)
			local clear_char_count = #prev_typed - #keyboard.typed
			if clear_char_count > 0 then
				term.write(string.rep(" ", clear_char_count))
			end
			term.setCursorPos(typing_start_x + #keyboard.typed, y)
		end
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





--[[
function loadAPIs()
	for _, API in ipairs(APIs) do
		term.write("Loading API '" .. API.id .. "'...")
		local pathAPI = APIsPath .. API.name
		os.loadAPI(pathAPI)
		print(' Loaded!')
	end
end

function downloadCfg()
	term.write("Downloading cfg from GitHub...")

	local url = 'https://raw.githubusercontent.com/MyNameIsTrez/ComputerCraft-APIs/master/backwardsos_cfg.lua'

	local handleHttps = http.post_lossless(httpToHttpsUrl, '{"url": "' .. url .. '"}' )

	if not handleHttps then
		handleHttps.close()
		error('Downloading file failed!')
	end

	local str = handleHttps.readAll()
	handleHttps.close()

	local handleFile = fs.open(cfgPath, 'w')
	handleFile.write(str)
	handleFile.close()
	
	print(' Downloaded!')
end


if not fs.exists(cfgPath) then
	downloadCfg()
end

os.loadAPI(cfgPath)

if not cfg.useBackwardsOS or rs.getInput(cfg.disableSide) then
	return
end

if cfg.redownloadAPIsOnStartup and http then
	importAPIs()
end

loadAPIs()

term.clear()
term.setCursorPos(1, 1)

if cfg.useMonitor then
	term.redirect(cf.getMonitor())
end

local programsPath = 'BackwardsOS/programs'

if not fs.exists(programsPath) then
	fs.makeDir(programsPath)
end

local options = fs.list(programsPath)
local program = lo.listOptions(options)

term.clear()
term.setCursorPos(1, 1)

local path = 'BackwardsOS/programs/' .. program .. '/' ..program .. '.lua'

if fs.exists(path) then
	shell.run(path)
else
	error("Program '" .. tostring(program) .. "' not found.")
end
]]--


premain()
