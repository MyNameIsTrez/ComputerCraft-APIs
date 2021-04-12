local bw_os_dir = "backwards_os"
local apis = fs.combine(bw_os_dir, "apis")
local cfg_path = fs.combine(apis, "backwards_os_cfg")

local fake_width, height = term.getSize()
local width = fake_width - 1

local typing_start_x = 3
--local typing_start_y = 1
local typed = ""
local running_program = false


function premain()
	parallel.waitForAny(
		listen_file_update,
		listen_key,
		listen_char,
		main
	)
end


function listen_file_update()
	while true do
		if long_poll.listen("file_change") == "true" then
			os.reboot()
		end
	end
end


function listen_key()
	while true do
		keyboard.listen_key(on_key)
	end
end


function listen_char()
	while true do
		keyboard.listen_char(on_char)
	end
end


function main()
	write("> ")
	term.setCursorBlink(true)
	
	--[[
	write(string.rep("a", 25) .. "\n\n\n")
	--write(string.rep("a", 25))
	--write("\n")
	--write("\n")
	--write("\n")
	write(string.rep("b", 75))
	write(string.rep("c", 51))
	write(string.rep("d", 50))
	--write(string.rep("d", 50) .. "\n")
	server.print(subterm.history)
	]]--
	
	--[[
	write(string.rep("a", 45))
	while true do
		write(string.rep("b", 1))
		sleep(1)
		--server.print(subterm.history)
	end
	]]--
	
	--[[
	write(string.rep("b", 50) .. "\n")
	write(string.rep("b", 50) .. "\n")
	server.print(subterm.history)
	]]--
	
	--[[
	--subterm.disable_history_recording()
	print("xd")
	write("foo")
	write("bar")
	--server.print("subterm.history:")
	--server.print(subterm.history)
	]]--
	
	sleep(1e6)
end


function on_key(key, key_num)
	if key == "r" then
		os.reboot()
	end
	
	if key == "t" then
		sleep(0.05) -- So the "t" isn't printed.
		error("Terminated")
	end
	
	-- Function of synced/apis/subterm.lua
	if key == "pageUp" then
		subterm.scroll_up(1)
		--server.print("typed pageUp")
	end
	
	if key == "pageDown" then
		subterm.scroll_down(1)
		--server.print("typed pageDown")
	end
	
	if key == "enter" then
		write("\n")
		
		running_program = true
		shell.run(typed)
		running_program = false
		
		write("> ")
		
		local x, y = term.getCursorPos()
		typing_start_x = x
		--typing_start_y = y
		
		typed = ""
	end
	
	if key == "backspace" or key == "delete" then
		if #typed > 0 then
			local cursor_x, cursor_y = term.getCursorPos()
			local typed_cursor_index = cursor_x - typing_start_x
			--local y = 
			
			if key == "backspace" then
				-- TODO: Shifts too much when moving the cursor.
				local shifted = #typed - typed_cursor_index + 1
				server.print(shifted)
				
				term.setCursorPos(typing_start_x + #typed - 1, cursor_y)
				term.write(" ")
				term.setCursorPos(cursor_x - 1, cursor_y)
				term.write(typed:sub(typed_cursor_index + 1, -1))
				
				term.setCursorPos(cursor_x - 1, cursor_y)
				
				typed = typed:sub(1, typed_cursor_index - 1) .. typed:sub(typed_cursor_index + 1, -1)
			elseif key == "delete" then
			end
		end
	end
	
	if key == "up" or key == "down" or key == "left" or key == "right" then
	local x, y = term.getCursorPos()
	if key == "up" then
		
	end
	if key == "down" then
		
	end
	if key == "left" then
		term.setCursorPos(x - 1, y)
	end
	if key == "right" then
		term.setCursorPos(x + 1, y)
	end
	end
end



function on_char(char, char_num)
	if not running_program then
		write(char)
	end
	typed = typed .. char
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

	local handleHttps = http.post(httpToHttpsUrl, '{"url": "' .. url .. '"}' )

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
