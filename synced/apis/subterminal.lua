history = {} -- Public.


-- Overwriting print for the purpose of storing what was printed.
original_print = print -- Public.

history_print = function(...)
	local str = ""
	for _, argStr in ipairs({...}) do
		str = str .. tostring(argStr)
	end
	table.insert(history, str)
	
	original_print(...)
end

function enable_print_recording()
	_G.print = history_print
end

function disable_print_recording()
	_G.print = original_print
end

function print_history()
	for _, str in ipairs(history) do
		original_print(str)
	end
end
