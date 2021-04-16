-- Toki Pona dictionary functions.

function getTable()
	local strTab = https.get('https://raw.githubusercontent.com/MyNameIsTrez/MyNameIsTrez.github.io/master/projects/Toki%20Pona%20Dictionary/toki%20pona%20dictionary.lua')
	local tab = convert.strTabToTab(strTab)
	return tab
end



function getHandle()
	return https.getHandle('https://raw.githubusercontent.com/MyNameIsTrez/MyNameIsTrez.github.io/master/projects/Toki%20Pona%20Dictionary/toki%20pona%20dictionary.csv')
end

-- function getStr()
-- 	return getHandle.readAll()
-- end

function temp()
	local handle = getHandle()
	local tab = convert.csvToTable(handle)
	return tab
end