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
local delimiter = '-line">' .. '(.-)' .. '</td>'

local IPUrl = 'http://api.ipify.org'
-- Starts as nil. Call httpGetIP().
local IP

local randomQuotaUrlStart = 'http://www.random.org/quota/?ip='
local randomQuotaUrlEnd = '&format=plain'

-- Set by calling getStorageStructure().
local storageStructure


--------------------------------------------------
-- FUNCTIONS


-- Https ----------


function getHandle(url)
	local handle = http.post(httpToHttpsUrl, '{"url": "' .. url .. '"}' )
	cf.yield()
	
	if handle == nil then error('https.getHandle() didn\'t get a response back.') end

	return handle
end


function getTable(url)	
	local handle = getHandle(url)
	
	local strTable = {}
	local i = 1
	for line in handle.readLine do
		strTable[i] = line
		i = i + 1
	end
	cf.yield()
	
	handle.close()
	cf.yield()
	
	if strTable[1] == '404: Not Found' then print(url)error('https.get() 404: File not found.') end

	return strTable
end

function get(url)
	local tab = getTable(url)
	return table.concat(tab)
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


-- Joppe's file storage server ----------


function getStorageStructure()
	if not storageStructure then
		storageStructure = json.parseArray(http.get('http://joppekoers.nl:1337').readAll())
	end
	return storageStructure
end

function getStorageData(url)
	return http.get('http://joppekoers.nl:1337/' .. url).readAll()
end

function downloadStorageFile(url, folder, name)
	if not fs.exists(folder) then
		fs.makeDir(folder)
	end
	
    local strTable = getTable(url)
	cf.yield()

	local handle = io.open(folder .. '/' .. name .. '.txt', 'w')
	cf.yield()
	
	for _, str in ipairs(strTable) do
		handle:write(str)
		handle:write('\n')
	end
	cf.yield()
	
	handle:close()
	cf.yield()
end


--[[

-- GitHub (not used) ----------


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
	
    local strTable = getTable(url)
	cf.yield()

	local handle = io.open(folder .. '/' .. fileName .. '.txt', 'w')
	cf.yield()
	
	for _, str in ipairs(strTable) do
		handle:write(str)
		handle:write('\n')
	end
	cf.yield()
	
	handle:close()
	cf.yield()
end

function getStructure()
	if not structure then
		local str = get(structureUrl)
		local fileLines = {}

		-- For every string inside the delimiter (pattern), process it further.
		str:gsub(delimiter, function(line)
			local unicodedLine = unicodify(line) -- Unicodify the string so `&#39;` becomes `'`.
			fileLines[#fileLines + 1] = unicodedLine
		end)

		local str2 = table.concat(fileLines) -- Concat turns the table of strings into a single string.
		structure = textutils.unserialize(str2) -- Unserialize turns str2 into a table.
	end
	return structure
end

]]--


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