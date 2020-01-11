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
 
 
-- Website that transforms http requests from ComputerCraft into https requests.
-- The website responds back to ComputerCraft's http message with the https response.
local httpToHttpsUrl = 'http://request.mariusvanwijk.nl/'
 
 
-- GitHub variables
 
 
-- An file containing all the names of the files and folders inside of this GitHub repository.
local fileStructureUrl = 'https://github.com/MyNameIsTrez/ComputerCraft-Data-Storage/blob/master/structure.txt'
 
-- A file containing the structure of the folders and files inside of the ComputerCraft data storage repository.
local structureUrl = 'https://github.com/MyNameIsTrez/ComputerCraft-Data-Storage/blob/master/structure.txt'
 
-- Delimiter for getting every line of valuable content inside of a GitHub file.
local delimiter = '-line">' .. '(.-)' .. '</td>\n      </tr>'
 
-- Starts at nil, will hold the file and folder structure of the GitHub repository.
local structure
 
 
--------------------------------------------------
-- FUNCTIONS
 
 
-- Https ----------
 
 
function get(url)
    local handle = http.post(httpToHttpsUrl, '{"url": "' .. url .. '"}' )
    local string = handle.readAll()
    handle.close()
    return string
end
 
function post(url, data)
    local handle = http.post(httpToHttpsUrl, '{"url": "' .. url .. '", "body": "' .. json.encode(data) .. '"}' )
    local string = handle.readAll()
    handle.close()
    return string
end
 
function request(data)
    local handle = http.post(httpToHttpsUrl, json.encode(data))
    local string = handle.readAll()
    handle.close()
    return string
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
 
function downloadFile(url, outputLocation, fileName)
    local str = https.get(url)
    local handle = io.open(outputLocation .. '/' .. fileName .. '.txt', 'w')
    handle:write(str)
    handle:close()
end
 
function getStructure(url)
    if not structure then
        local str = https.get(url)
        local fileLines = {}
        str:gsub(delimiter, function(line) fileLines[#fileLines + 1] = textutils.unserialize(unicodify(line)) end)
       
        local strTab = {}
        for key, line in ipairs(fileLines) do strTab[#strTab + 1] = line end
        -- Concat turns the table of strings into a single string, unserialize turns the string into a table.
        structure = textutils.unserialize(table.concat(strTab))
    end
    return structure
end
 
 
--------------------------------------------------