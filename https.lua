-- README.
 
 
--[[
Because ComputerCraft can only send HTTP requests, and most websites block HTTP requests, most websites are unaccessible!
This API allows you to send 'HTTPS' requests: POST, GET and REQUEST.
 
It does so, by sending the HTTP request to a server that converts it into a HTTPS request, and sends that to any website.
That website sends a HTTPS response back to the server, which converts it into a HTTP reply and sends that back to
The original HTTP request sent from ComputerCraft!
 
This API needs the json API to convert a Lua table to a JavaScript object:
https://pastebin.com/4nRg9CHU
]]--
 
 
-- General variables.
 
 
-- Website that transforms http requests from ComputerCraft into https requests.
-- The website responds back to ComputerCraft's http message with the https response.
local httpToHttpsUrl = 'http://request.mariusvanwijk.nl/'
 
 
-- GitHub variables.
 
 
-- A file containing the structure of the folders and files inside of the ComputerCraft data storage repository.
local gitHubStructureUrl = 'https://github.com/MyNameIsTrez/ComputerCraft-Data-Storage/blob/master/structure.txt'
 
-- Every line with valuable content in a file is announced with this string.
local startContentStr = 'js-file-line">'
-- Every line with valuable content in a file is ended with this string.
local endContentStr = '</td>\n      </tr>'
 
 
-- Google Drive variables.
 
 
-- An index of all the names and links to the files are stored inside of this folder.
local fileIndexUrl = 'https://docs.google.com/document/d/1BW4sea-6ML_9lgWdTsoNBYKKAHe9LVXTptyRunSJnHM/edit?usp=sharing'
 
-- Global variable, the user needs to set it with setGoogleDriveFolderStructure().
-- When set, it holds a table containing every folder name, file name and URL of every file.
local googleDriveFolderStructure = nil
 
-- Every line with valuable content in a file is announced with this string.
local startIndexContentStr = '"s":"'
 
 
-- Mega.nz variables.
 
 
-- Not sure what this is, see the Mega.nz tutorial linked below.
local sequenceNumber = math.random(1000000)
local sessionId = nil -- Not sure what this is, see the Mega.nz tutorial linked below.
 
 
-- HTTPS FUNCTIONS ----------
 
 
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
 
 
-- GITHUB ----------
 
 
function getGitHubFile(url)
    local str = https.get(url)
   
    local startIndexContent = getStartIndexContent(str, 1)
    local endIndexContent = getEndIndexContent(str, startIndexContent)
   
    local fileLines = {}
   
    -- Gets every line of the file, and returns when all lines have been found.
    while true do
        local noUnicodeStr = str:sub(startIndexContent, endIndexContent)
       
        fileLines[#fileLines + 1] = textutils.unserialize(unicodify(noUnicodeStr))
       
        startIndexContent = getStartIndexContent(str, endIndexContent)
        if startIndexContent then
            endIndexContent = getEndIndexContent(str, startIndexContent)
        else
            return fileLines
        end
    end
end
 
 
-- GOOGLE DRIVE ----------
 
 
function unicodify(str)
    -- Replace with an empty string.
    str = str:gsub(' ', '')
    str = str:gsub('\\n', '')
    str = str:gsub('\\t', '')
   
    str = str:gsub('\\u003d', '=')
    str = str:gsub('\\u0027', "'")
   
    return str
end
 
function getStartIndexContent(str, start)
    -- + #startIndexContentStr is hardcoded.
    local temp = str:find(startIndexContentStr, start)
    if temp then
        return temp + 5
    else
        return nil
    end
end
 
function getEndIndexContent(str, start)
    -- Search for the endOfContentStr after the startIndexContent.
    -- It doesn't matter if the frames contain the " character,
    -- because the frames don't contain unicode characters.
    return str:find('"', start) - 1
end
 
function getGoogleDriveFile(url)
    local str = https.get(url)
   
    local startIndexContent = getStartIndexContent(str, 1)
    local endIndexContent = getEndIndexContent(str, startIndexContent)
   
    local fileLines = {}
   
    -- Gets every line of the file, and returns when all lines have been found.
    while true do
        local noUnicodeStr = str:sub(startIndexContent, endIndexContent)
       
        fileLines[#fileLines + 1] = textutils.unserialize(unicodify(noUnicodeStr))
       
        startIndexContent = getStartIndexContent(str, endIndexContent)
        if startIndexContent then
            endIndexContent = getEndIndexContent(str, startIndexContent)
        else
            return fileLines
        end
    end
end
 
-- Reads the file index.
function setGoogleDriveFolderStructure()
    googleDriveFolderStructure = getGoogleDriveFile(fileIndexUrl)
end
 
function getGoogleDriveFolderStructure()
    return googleDriveFolderStructure
end
 
 
-- MEGA.NZ ----------
 
 
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
    sleep(5)
    local data = json.encode(req)
    return post(url, data)
end