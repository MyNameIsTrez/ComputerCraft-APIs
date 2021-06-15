function add_listeners(shell)


events.listen("r", function()
	os.reboot()
end)

events.listen("t", function()
	sleep(0.05) -- So the "t" isn't printed.
	error("Terminated")
end)

events.listen("pageUp", function()
	subterm.scroll_up(1)
end)

events.listen("pageDown", function()
	subterm.scroll_down(1)
end)

events.listen("enter", function()
	subterm.pressed_enter(shell)
end)

events.listen( { "backspace", "delete" }, function(key)
	subterm.pressed_backspace_or_delete_overseer(key)
end)

events.listen( { "up", "down", "left", "right" }, function(key)
	subterm.move_cursor(key)
end)

events.listen("char", function(_, char)
	subterm.pressed_char(char)
end)


end