--------------------------------------------------
-- README
 
 
--[[
Because ComputerCraft can only send HTTP requests, and most websites block HTTP requests, most websites are unaccessible!
This API allows you to send 'HTTPS' requests: POST, GET and REQUEST.
 
It does so, by sending the HTTP request to a server that converts it into a HTTPS request, and sends that to any website.
That website sends a HTTPS response back to the server, which converts it into a HTTP reply and sends that back to
The original HTTP request sent from ComputerCraft!
 
REQUIREMENTS
    * https://pastebin.com/4nRg9CHU - This API needs the json API to convert a Lua table into a JavaScript object.
]]--
 
 
--------------------------------------------------
-- VARIABLES
 
 
-- General variables
 
 
-- Website that transforms http requests from ComputerCraft into https requests.
-- The website responds back to ComputerCraft's http message with the https response.
local httpToHttpsUrl = 'http://request.mariusvanwijk.nl/'
 
 
-- GitHub variables
 
 
-- A file containing the structure of the folders and files inside of the ComputerCraft data storage repository.
local gitHubStructureUrl = 'https://github.com/MyNameIsTrez/ComputerCraft-Data-Storage/blob/master/structure.txt'
 
-- Delimiter for getting every line of valuable content inside of a GitHub file.
local gitHubDelimiter = '-line">' .. '(.-)' .. '</td>\n      </tr>'
 
 
-- Google Drive variables
 
 
-- An index of all the names and links to the files are stored inside of this folder.
local fileIndexUrl = 'https://docs.google.com/document/d/1BW4sea-6ML_9lgWdTsoNBYKKAHe9LVXTptyRunSJnHM/edit?usp=sharing'
 
-- Global variable, the user needs to set it with setGoogleDriveStructure().
-- When set, it holds a table containing every folder name, file name and URL of every file.
local googleDriveStructure = nil
 
-- Delimiter for getting every line of valuable content inside of a Google Docs file.
local googleDriveDelimiter = '"s":"' .. '(.-)' .. '"'
 
 
-- Mega.nz variables
 
 
-- Not sure what this is, see the Mega.nz tutorial linked below.
local sequenceNumber = math.random(1000000)
local sessionId = nil -- Not sure what this is, see the Mega.nz tutorial linked below.
 
 
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
 
 
-- General ----------
 
 
function getStartIndexContent(str, search, start)
    local searchStartIndex = str:find(search, start)
    if searchStartIndex then
        return searchStartIndex + #search
    else
        return nil
    end
end
 
function getEndIndexContent(str, search, start)
    -- It doesn't matter if the valuable lines contain the " character,
    -- because the lines don't contain unicode characters yet.
    return str:find(search, start) - 1
end
 
-- Replaces characters in a string with their equivalent unicode character.
function unicodify(str)
    -- Replace with an empty string.
    str = str:gsub(' ', '')
    str = str:gsub('\\n', '')
    str = str:gsub('\\t', '')
   
    str = str:gsub('\\u003d', '=')
    str = str:gsub('\\u0027', "'")
   
    return str
end
 
function getFile(url, delimiter, convertToUnicode)
    local str = https.get(url)
    local fileLines = {}
    if not convertToUnicode then
        str:gsub(delimiter, function(line) fileLines[#fileLines + 1] = textutils.unserialize(line) end)
    else
        str:gsub(delimiter, function(line) fileLines[#fileLines + 1] = textutils.unserialize(unicodify(line)) end)
    end
    return fileLines
end
 
 
-- GitHub ----------
 
 
function getGitHubDelimiter()
    return gitHubDelimiter
end
 
 
-- Google Drive ----------
 
 
function getGoogleDriveDelimiter()
    return googleDriveDelimiter
end
 
-- Reads the file index.
function setGoogleDriveStructure()
    googleDriveStructure = getFile(fileIndexUrl, googleDriveDelimiter, true)
end
 
function getGoogleDriveStructure()
    return googleDriveStructure
end
 
 
-- Mega.nz ----------
 
 
-- This function is rewritten PHP that came from this Mega.nz tutorial:
-- http://julien-marchand.fr/blog/using-the-mega-api-with-php-examples/
function getMegaFile(req)
    -- No clue what req is, I just know it's a table.
    local urlSession
    if sessionId then
        urlSession = '&sid=' .. tostring(sessionId)
    else
        urlSession = ''
    end
    local url = "https://g.api.mega.co.nz/cs?id=" .. tostring(sequenceNumber) .. urlSession
    sequenceNumber = sequenceNumber + 1
    print(url)
    local data = json.encode(req)
    return post(url, data)
end
 
 
--------------------------------------------------