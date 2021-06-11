local bw_os_dir = "backwards_os"
local apis = fs.combine(bw_os_dir, "apis")
local cfg_path = fs.combine(apis, "backwards_os_cfg")

local fake_width, height = term.getSize()
local width = fake_width - 1

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

	terminal_events.add_listeners()
	
	term.setCursorBlink(true)
	
	--shell.run("backwards_os/synced/programs/crafting_gui")
	
	sleep(1e6)
end


premain() -- TODO: Move to startup?