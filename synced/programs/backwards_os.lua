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
		local h = http.get_lossy("http://h2896147.stratoserver.net:1338/long_poll?fn_name=file_change")
		if h == nil then error("Server offline.") end
		local response = h.readAll()
		h.close()
		if response == "true" then
			os.reboot()
		end
	end
end


function main()
	utils.draw_cursor_prompt()

	shell.setDir("backwards_os/synced/programs") -- Makes shell.run recognize BWOS programs.
	subterm_events.add_listeners(shell)
	
	term.setCursorBlink(true)
	
	-- shell.run("crafting_gui")
	-- shell.run("floodfill_demo")
	
	sleep(1e6)
end


premain() -- TODO: Move to startup?