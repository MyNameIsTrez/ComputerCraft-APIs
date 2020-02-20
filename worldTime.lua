-- Requires a JSON API: https://pastebin.com/GSRpTU2e
-- The JSON API needs to be referenced as 'json' by the computer.

-- Arguments can be 'america', 'argentina', 'salta' (optional)
function getTime(area, location, region)
	-- Written by MyNameIsTrez.
	
	-- Error handling.
	if not area then error('getTime didn\'t get the area provided.') end
	location  = location or ''
	region = region or ''
	
	local baseUrl = 'http://worldtimeapi.org/api/timezone'
	local url = baseUrl .. '/' .. area .. '/' .. location .. '/' .. region
	local handle = http.get(url)
	if not handle then error('getTime couldn\'t get the world time for the provided arguments.') end
	local strRaw = handle.readAll()
	
	-- Error handling.
	if strRaw:sub(1, 1) == '[' then error('A location (and possibly a region) needs to be provided for this area.') end
	
	local allData = json.parseObject(strRaw)
	
	local timeDataStr = string.match(allData.datetime, 'T(.+)[-+]')
	
	-- Split into hours, minutes and seconds.
	local timeDataNumeric = {}
	for data in string.gmatch(timeDataStr, '([^:]+)') do
   		table.insert(timeDataNumeric, data)
	end
	
	local timeDataAssociative = { hours = timeDataNumeric[1], minutes = timeDataNumeric[2], seconds = timeDataNumeric[3] }
	
	return { timeData = timeDataAssociative, allData = allData }
end

function getTimeArgs()
	local url = 'http://worldtimeapi.org/api/timezone'
	local handle = http.get(url)
	local strRaw = handle.readAll()
	local strTab = json.parseArray(strRaw)
	return strTab
end

function getSortedTimeArgs(unsorted)
	local sorted = {}
	
	local prevFirstArg, prevSecondArg
	for _, str in ipairs(unsorted) do
		local split = {}
		local n = 0
		
		for data in string.gmatch(str, '([^/]+)') do
			n = n + 1
			split[n] = data
		end
		
		local firstArg, secondArg, thirdArg = split[1], split[2], split[3]
		
		local sameFirst, sameSecond = false, false
		if firstArg == prevFirstArg then
			sameFirst = true
		end
		if secondArg == prevSecondArg then
			sameSecond = true
		end
		
		if not secondArg then
			table.insert(sorted, firstArg)
		else
			if not sameFirst then
				sorted[firstArg] = {}
			end
			
			if not thirdArg then
				table.insert(sorted[firstArg], secondArg)
			else
				if not sameSecond then
					sorted[firstArg][secondArg] = {}
				end
	
				table.insert(sorted[firstArg][secondArg], thirdArg)
			end
		end
		
		prevFirstArg = split[1]
		prevSecondArg = split[2]
	end
	
	return sorted
end