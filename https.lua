--[[
This API needs the json API to convert a Lua table to a JavaScript object:
https://pastebin.com/4nRg9CHU
]]--
 
-- Website that transforms http requests from ComputerCraft into https requests.
-- The website responds back to ComputerCraft's http message with the https response.
local httpToHttpsUrl = 'http://request.mariusvanwijk.nl/'
 
-- Google Drive variables.
-- All animations (videos, images) are stored in this Google Drive folder.
local animationsFolderUrl = 'https://drive.google.com/drive/folders/1bcnkm896y2LeQyKabwVHtcAGjvtRQpvb?usp=sharing'
local animationsFolderIndexUrl = 'https://docs.google.com/document/d/1BW4sea-6ML_9lgWdTsoNBYKKAHe9LVXTptyRunSJnHM/edit?usp=sharing'
local animationStructure = nil -- Global variable, set by setAnimationStructure().
local startIndexContentStr = '"s":"'
 
-- Mega.nz variables.
local sequenceNumber = math.random(1000000) -- Not sure what this is, see the Mega.nz tutorial linked below.
local sessionId = nil -- Not sure what this is, see the Mega.nz tutorial linked below.
 
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
   
    --local endIndexContentStr = '"},{'
   
    return str:find('"', start) - 1
end
 
-- indexTable specifies whether this is the file
-- that holds names and URLs of all the other files.
function getGoogleDriveFile(url, indexTable)
    local str = https.get(url)
   
    --[[
    -- This block of code is temporary.
    local handle = io.open(tostring(math.random(1000000)), 'w')
    handle:write(str)
    handle:close()
   
    print('#str: '..tostring(#str))
    ]]--
   
    local startIndexContent = getStartIndexContent(str, 1)
    local endIndexContent = getEndIndexContent(str, startIndexContent)
   
    local fileLines = {}
   
    while true do
        print(tostring(startIndexContent))
        print(tostring(endIndexContent))
        print()
       
        local noUnicodeStr = str:sub(startIndexContent, endIndexContent)
       
        if not indexTable then
            fileLines[#fileLines + 1] = noUnicodeStr
        else
            fileLines[#fileLines + 1] = unicodify(noUnicodeStr)
        end
       
        startIndexContent = getStartIndexContent(str, endIndexContent)
        if startIndexContent then
            endIndexContent = getEndIndexContent(str, startIndexContent)
        else
            return fileLines
        end
       
        sleep(3)
    end
end
 
-- Reads the index file inside of the Google Drive's Animation folder.
function setAnimationStructure()
    local str = getGoogleDriveFile(animationsFolderIndexUrl, true)
    animationStructure = textutils.unserialize(str)
end
 
function getAnimationStructure()
    return animationStructure
end
 
--[[
Gets the names of the folders inside of the Google Drive Animations folder.
It can't get the names of folders surrounding the Animations folder.
Uses > and < signs to indicate folder names inside of the Animations folder.
\u003e is the unicode character >.
\u003c is the unicode character <.
]]--
function getGoogleDriveFolderNames()
    --[[
    local str = https.get(animationsFolderUrl)
    local folderNames = {}
    string.gsub(str, '\u003e ' .. '(.-)' .. ' \\\\u003c', function(folderName) folderNames[#folderNames + 1] = folderName end)
    return folderNames
    ]]--
   
   
end
 
-- MEGA.NZ ----------
 
-- This function is rewritten PHP that came from this Mega.nz tutorial:
-- http://julien-marchand.fr/blog/using-the-mega-api-with-php-examples/
function getMega(req)
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