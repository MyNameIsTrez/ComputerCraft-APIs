-- Converts a string that looks like a table to an actual table.
function strTabToTab(strTab)
	return loadstring('return ' .. strTab)()
end


-- Converts a CSV handle to a table of its contents.
function csvToTable(handle)
	local tab = {}
	for line in handle.readLine do
		local tokipona, func, meaningsStr = line:match('"(.-)","(.-)","(.-)"')
		
		if func ~= 'separator' and func ~= 'unofficial' then
			local meaningsTab = cf.split(meaningsStr, ',')
			
			tab[#tab + 1] = { tokipona = tokipona, func = func, meanings = meaningsTab }
			
			-- More general way, but I don't know how I can get it to have keys be the
			-- variable names in the table like above.
			-- tab[#tab + 1] = { line:match('"(.-)","(.-)","(.-)"') }
		end
	end
	return tab
end