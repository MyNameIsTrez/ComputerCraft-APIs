--------------------------------------------------
-- README


--[[

Because ComputerCraft can only send HTTP requests, and most websites block HTTP requests, most websites are unaccessible!
This API allows you to send 'HTTPS' requests: POST, GET and REQUEST.

It does so, by sending the HTTP request to a server that converts it into a HTTPS request, and sends that to any website.
That website sends a HTTPS response back to the server, which converts it into a HTTP reply and sends that back to
The original HTTP request sent from ComputerCraft!

REQUIREMENTS
	* json: https://pastebin.com/4nRg9CHU - Converts a Lua table into a JavaScript object.
]]--


--------------------------------------------------
-- VARIABLES


-- General variables


-- ComputerCraft version 1.33 and below doesn't have access to HTTPS URLs.
-- This website transforms http requests from ComputerCraft into https requests to circumvent this issue.
local httpToHttpsUrl = 'http://request.mariusvanwijk.nl/'


-- GitHub variables

-- A URL containing the structure of the folders and files inside of the ComputerCraft data storage repository.
local structureUrl = 'https://github.com/MyNameIsTrez/ComputerCraft-Data-Storage/blob/master/structure.txt'
-- Starts as nil. Call getStructure(). Will hold the file and folder structure of the GitHub repository.
local structure

-- Delimiter for getting every line of valuable content inside of a GitHub file.
local delimiter = '-line">' .. '(.-)' .. '</td>\n      </tr>'

local IPUrl = 'http://api.ipify.org'
-- Starts as nil. Call httpGetIP().
local IP

local randomQuotaUrlStart = 'http://www.random.org/quota/?ip='
local randomQuotaUrlEnd = '&format=plain'


--------------------------------------------------
-- FUNCTIONS


-- Https ----------


function getTable(url)
	print('url: ' .. tostring(url))
	os.queueEvent('yield')
	os.pullEvent('yield')
	print('d2')
	
	local handle = http.post(httpToHttpsUrl, '{"url": "' .. url .. '"}' )
	print('d3')
	os.queueEvent('yield')
	os.pullEvent('yield')
	
	if handle == nil then error('https.get() didn\'t get a response back.') end
	os.queueEvent('yield')
	os.pullEvent('yield')
	print('d4')
	
	local strTable = {}
	local i = 1
	os.queueEvent('yield')
	os.pullEvent('yield')
	print('d5')
	
	cf.printTable(handle)
	os.queueEvent('yield')
	os.pullEvent('yield')
	print('d6')
	
	for line in handle.readLine do
		--print(line)
		--sleep(0.5)
		strTable[i] = line
		i = i + 1
	end
	os.queueEvent('yield')
	os.pullEvent('yield')
	print('d7')

	print('#strTable: ' .. tostring(#strTable))
	os.queueEvent('yield')
	os.pullEvent('yield')
	print('d8')
	
	handle.close()
	os.queueEvent('yield')
	os.pullEvent('yield')
	print('d9')
	
	if strTable[1] == '404: Not Found' then error('https.get() 404: File not found.', 2) end
	os.queueEvent('yield')
	os.pullEvent('yield')
	print('d10')
	
	return strTable
end

function get(url)
	return table.concat(getTable(url))
end

function post(url, data)
	local handle = http.post(httpToHttpsUrl, '{"url": "' .. url .. '", "body": "' .. json.encode(data) .. '"}' )
	local str = handle.readAll()
	handle.close()
	return str
end

function request(data)
	local handle = http.post(httpToHttpsUrl, json.encode(data))
	local str = handle.readAll()
	handle.close()
	return str
end


-- GitHub ----------


-- Called when getting the structure.
-- Replaces characters in a string with their equivalent unicode character.
function unicodify(str)
	str = str:gsub('&#39;', "'")
	str = str:gsub('\t', '')
	str = str:gsub(' ', '')
	return str
end

function downloadFile(url, folder, fileName)
	if not fs.exists(folder) then
		fs.makeDir(folder)
	end
	
	print('d1')
	os.queueEvent('yield')
	os.pullEvent('yield')
    local strTable = https.getTable(url)
	os.queueEvent('yield')
	os.pullEvent('yield')
	print('d11')
	local handle = io.open(folder .. '/' .. fileName .. '.txt', 'w')
	os.queueEvent('yield')
	os.pullEvent('yield')
	print('d12')
	
	for str in ipairs(strTable) do
		handle:write(str)
	end
	os.queueEvent('yield')
	os.pullEvent('yield')
	print('d13')
	
	handle:close()
	os.queueEvent('yield')
	os.pullEvent('yield')
	print('d14')
end

function getStructure()
	if not structure then
    	local str = https.get(structureUrl)
    	local fileLines = {}
    	str:gsub(delimiter, function(line) fileLines[#fileLines + 1] = textutils.unserialize(unicodify(line)) end)
		
		local strTab = {}
		for key, line in ipairs(fileLines) do strTab[#strTab + 1] = line end
		-- Concat turns the table of strings into a single string, unserialize turns the string into a table.
		structure = textutils.unserialize(table.concat(strTab))
	end
	return structure
end

function httpGetIP()
	if not IP then
		local handle = http.get(IPUrl)
		IP = handle.readAll()
	end
	return IP
end

function getRandomQuota()
	if not IP then
		httpGetIP()
	end
	local url = randomQuotaUrlStart .. IP .. randomQuotaUrlEnd
	return http.get(url)
end

function getIntegers()
	url = 'https://www.random.org/integers/?num=10&min=1&max=6&col=1&base=10&format=plain&rnd=new'
	get(url)
end

function getFortune()
	return get('https://osmarks.tk/random-stuff/fortune/')
end