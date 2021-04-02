function split_but_keep_newlines(str)
	local t = {}
	for a, b in string.gmatch(str, "([^\n]*)(\n?)") do
		if #a > 0 then t[#t+1] = a end
		if #b > 0 then t[#t+1] = b end
	end
	return t
end


local w, h = term.getSize()
function split_by_terminal_width(str, x_offset)
	local strTab = {}
	local first_line_len = w - x_offset + 1
	strTab[1] = str:sub(1, first_line_len)
	for i = first_line_len + 1, #str, w do
		strTab[#strTab + 1] = str:sub(i, i + w - 1)
	end
	return strTab
end


strTab = {}
for _, str2 in ipairs(split_but_keep_newlines("\nfoo\nbar\n\nbaz\n")) do
	for _, str3 in ipairs(split_by_terminal_width(str2, 1)) do
		strTab[#strTab+1] = str3
	end
end


print(#strTab)
utils.print_table(strTab)


--a = split_by_terminal_width(string.rep("a", 25) .. string.rep("b", 26), 3)
--a = split_by_terminal_width(string.rep("a", 25) .. string.rep("b", 75) .. string.rep("c", 51) .. string.rep("d", 50) .. "\n", 3)
