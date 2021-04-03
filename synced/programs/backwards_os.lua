local bw_os_dir = "backwards_os"
local apis = fs.combine(bw_os_dir, "apis")
local cfg_path = fs.combine(apis, "backwards_os_cfg")

local fake_width, height = term.getSize()
local width = fake_width - 1


function premain()
	parallel.waitForAny(
		files_updated_listening,
		keys_start_listening,
		main
	)
end


function files_updated_listening()
	while true do
		if long_poll.listen("file_change") == "true" then os.reboot() end
	end
end


function keys_start_listening()
	while true do
		keys.start_listening(on_key_actions)
	end
end


function main()
	subterm.enable_history_recording()
	
	
	--[[
	write(string.rep("a", 25) .. "\n\n\n")
	write(string.rep("b", 75))
	write(string.rep("c", 51))
	write(string.rep("d", 50))
	]]--
	--write(string.rep("d", 50) .. "\n")
	--server.print(subterm.history)
	
	
	
	write(string.rep("a", 45))
	while true do
		write(string.rep("b", 1))
		sleep(1)
		--server.print(subterm.history)
	end
	

	--write(string.rep("b", 50) .. "\n")
	--write(string.rep("b", 50) .. "\n")
	--server.print(subterm.history)
	
	--[[
	--subterm.disable_history_recording()
	
	--subterm.original_print("xd")
	print("xd")
	--subterm.history_print("xd")
	
	write("foo")
	write("bar")
	subterm.debug_print_history()
	--subterm.disable_history_recording()
	]]--
	sleep(1e6)
end


function on_key_actions(key_string, key_num)
	if key_string == "r" then os.reboot() end
	if key_string == "t" then sleep(0.05) error("Terminated") end -- Sleep so "t" isn't typed.
	if key_string == "x" then sleep(0.05) print("typed x") end
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
