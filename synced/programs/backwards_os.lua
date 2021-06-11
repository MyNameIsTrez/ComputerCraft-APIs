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

	shell.setDir("backwards_os/synced/programs") -- Makes shell.run recognize BWOS programs.
	terminal_events.add_listeners(shell)
	
	term.setCursorBlink(true)
	
	--shell.run("backwards_os/synced/programs/crafting_gui")
	
	sleep(1e6)
end


premain() -- TODO: Move to startup?