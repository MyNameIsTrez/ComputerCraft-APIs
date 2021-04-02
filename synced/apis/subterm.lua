history = {} -- Public.

original_write = write -- Public.


-- The original print function calls write() twice,
-- but it needs to call original_write() instead.
original_print = function(...)
	local nLinesPrinted = 0
	for n,v in ipairs({...}) do
		nLinesPrinted = nLinesPrinted + original_write(tostring(v))
	end
	nLinesPrinted = nLinesPrinted + original_write("\n")
	return nLinesPrinted
end


function history_print(...)
	local str = ""
	for _, argStr in ipairs({...}) do
		str = str .. tostring(argStr)
	end
	
	table.insert(history, str)
	table.insert(history, "")
	
	return original_print(...)
end


function history_write(argStr)
	if #history > 0 then
		local strTab = utils.split_by_chunk(history[#history] .. tostring(argStr), 50)
		local historyLen = #history
		
		for i = 1, #strTab do
			history[historyLen + i - 1] = strTab[i]
		end
	else
		local strTab = utils.split_by_chunk(tostring(argStr), 50)
		for i = 1, #strTab do
			history[i] = strTab[i]
		end
	end
	
	return original_write(tostring(argStr))
end


function enable_history_recording()
	_G.print = history_print -- Can't use "print =" here.
	_G.write = history_write
end


function disable_history_recording()
	_G.print = original_print
	_G.write = original_write
end


function debug_print_history()
	original_write(#history)
	for _, str in ipairs(history) do
		original_print(str)
		--original_write(str)
	end
end
