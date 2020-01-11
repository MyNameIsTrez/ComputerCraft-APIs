-- README --------------------------------------------------------
 
--[[
-- Program used to create and preview dithered animations/images.
 
REQUIREMENTS
    * Common Functions (cf): https://pastebin.com/p9tSSWcB -- Provides cf.tryYield().
    * JSON (json): https://pastebin.com/4nRg9CHU - Provides converting a Lua table into a JavaScript object for the HTTPS API.
    * HTTPS (https): https://pastebin.com/iyBc3BWj - Gets the animation files from a GitHub storage repository.
 
The default terminal ratio is 25:9.
To get the terminal to fill your entire monitor and to get a custom text color:
1. Open AppData/Roaming/.technic/modpacks/tekkit/config/mod_ComputerCraft.cfg
2. Divide your monitor's width by 6 and your monitor's height by 9.
3. Set terminal_width to the calculated width and do the same for terminal_height.
4. Set the terminal_textColour_r, terminal_textColour_g and terminal_textColour_b
   to values between 0 and 255 to get a custom text color.
 
]]--
 
-- ANIMATION CLASS --------------------------------------------------------
 
Animation = {
 
    new = function(self, shell)
        local startingValues = {
            passedShell = shell,
            frameCount,
            compressed,
            unpackedOptimizedFrames = {}
        }
       
        setmetatable(startingValues, {__index = self})
        return startingValues
    end,
 
    setShell = function(self, sl)
        self.passedShell = sl
    end,
 
    -- FUNCTIONS --------------------------------------------------------
 
    unpackOptimizedFrames = function(self, optimizedFrames)
        print('Unpacking optimized frames...')
       
        startTime = os.clock()
        local cursorX, cursorY = term.getCursorPos()
        for f = 1, self.frameCount do
            -- Print speed statistics.
            if f % 10 == 0 then
                -- Progress.
                progress = 'Creating frame ' .. tostring(f) .. '/' .. tostring(self.frameCount)
 
                -- Speed.
                elapsed = (os.clock() - startTime) / 10
                processedFps = 1 / elapsed
                speed = string.format('%d frames/s', processedFps)
               
                -- ETA.
                framesLeft = self.frameCount - f
                etaMinutes = math.floor(elapsed * framesLeft / 60)
                etaSeconds = math.floor(elapsed * framesLeft) % 60
                eta = string.format('%dm, %ds left', etaMinutes, etaSeconds)
               
                -- Clear.
                clear = '       '
 
                term.setCursorPos(cursorX, cursorY) -- Used so the next 'Creating frame' print statement can overwrite itself in its for loop.
                print(progress .. ', ' .. speed .. ', ' .. eta .. clear)
                startTime = os.clock()
            end
 
            local unoptimizedString = ''
            local optimizedFrame = optimizedFrames[f]
           
            local openBracketIndex = nil -- Probably not necessary to assign this with 'nil'.
 
            -- This can probably be done faster using table.concat:
            -- https://stackoverflow.com/a/1407187
 
            for currentIndex = 1, #optimizedFrame do
                local char = optimizedFrame:sub(currentIndex, currentIndex) -- can't use pairs or ipairs, I think
               
                if char == '[' then
                    openBracketIndex = currentIndex
                end
               
                if openBracketIndex == nil then
                    unoptimizedString = unoptimizedString .. char
                end
               
                if char == ']' then
                    -- More efficient to look at 'optimizedFrame' once like this, because we 'sub:' it twice later.
                    local closedBrackedIndex = currentIndex
                    local searchedString = optimizedFrame:sub(openBracketIndex, closedBrackedIndex)
 
                    local delimiterIndex
                    for i = 1, #searchedString do
                        local char = searchedString:sub(i, i)
                        if char == ';' then
                            delimiterIndex = i
                            break
                        end
                    end
 
                    local searchedDelimiterIndex = delimiterIndex + 2 - openBracketIndex
                    local searchedClosedBracketIndex = closedBrackedIndex - openBracketIndex
                    local repeatedChars = searchedString:sub(delimiterIndex + 1, searchedClosedBracketIndex)
                   
                    -- Add the repeated characters.
                    local repetition = tonumber(searchedString:sub(2, delimiterIndex - 1))
 
                    unoptimizedString = unoptimizedString .. repeatedChars:rep(repetition)
                   
                    openBracketIndex = nil
                end
            end
 
            table.insert(self.unpackedOptimizedFrames, unoptimizedString)
 
            cf.tryYield()
        end
    end,
 
    getSelectedAnimationFileTabFromGitHub = function(self, fileName)
        print('Getting the data from GitHub...')
        local gitUrl = 'https://github.com/MyNameIsTrez/ComputerCraft-Data-Storage/blob/master/Animations/size_30x30/' .. fileName .. '.txt'
        local args = { url=gitUrl, delimiter=https.getGitHubDelimiter(), convertToUtf8=true }
        return https.getFile(args)
    end,
   
    writeSelectedAnimationFileTabFromGitHub = function(self, fileName, fileTab)
        print('Writing the data from GitHub to a file...')
        local handle = io.open(cfg.computerType .. ' inputs/' .. fileName .. '.txt', 'w')
        for key, line in pairs(fileTab) do
            if key > 1 then
                handle:write('\n' .. line)
            else
                handle:write(line)
            end
        end
        handle:close()
    end,
 
    getSelectedAnimationData = function(self, fileName, fileTab)       
        local fileInfo
        local fileExists = fs.exists(cfg.computerType .. ' inputs/' .. fileName .. '.txt')
        if not fileExists then
            local fileTab = self:getSelectedAnimationFileTabFromGitHub(fileName)
            -- Get the file info, if the file was loaded from GitHub.
            fileInfo = fileTab[#fileTab]
            self:writeSelectedAnimationFileTabFromGitHub(fileName, fileTab)
        end
       
        local file = fs.open(cfg.computerType .. ' inputs/' .. fileName .. '.txt', 'r')
       
        if not file then
            error('There was an attempt to load a file name that doesn\'t exist locally AND in the GitHub storage; check if the chosen file name and the file name in the input folder match.')
        end
 
        print('Opening the data file...')
 
        if not fileName then
            error('There was an attempt to load a file name that doesn\'t exist; check if the chosen file name and the file name in the input folder match.')
        end
 
        cf.tryYield()
       
        local cursorX, cursorY = term.getCursorPos()
        local stringTab = {}
        local i = 1
        for lineStr in file.readLine do
            table.insert(stringTab, lineStr)
 
            if i % 100 == 0 then
                term.setCursorPos(cursorX, cursorY)
                print('Gotten ~'..tostring(i)..' data lines...')
            end
            i = i + 1
 
            cf.yield()
        end
       
        file:close()
        cf.tryYield()
       
        -- Get the file info, if the file was loaded from a local save.
        if not fileInfo then fileInfo = stringTab[#stringTab] end
       
        local frameSearch = 'frame_count=(.-),'
        fileInfo:gsub(frameSearch, function(count) self.frameCount = tonumber(count) end)
        cf.tryYield()
 
        local compressedIndex = fileInfo:find('compressed') + 11
        local compressedIndexComma = fileInfo:find(',', compressedIndex) - 1
        self.compressed = fileInfo:sub(compressedIndex, compressedIndexComma) == 'true'
        cf.tryYield()
 
        -- The general information data can be removed, so only the frames are left.
        table.remove(stringTab, #stringTab)
        local optimizedFrames = stringTab
        cf.tryYield()
       
        if self.compressed then
            self:unpackOptimizedFrames(optimizedFrames)
        else
            self.unpackedOptimizedFrames = optimizedFrames
        end
    end,
 
    createGeneratedCodeFolder = function(self)
        if fs.exists('.generatedCodeFiles') then
            local names = fs.list('.generatedCodeFiles')
 
            for _, name in pairs(names) do
                fs.delete('.generatedCodeFiles/'..tostring(name))
            end
        else
            fs.makeDir('.generatedCodeFiles')
        end
    end,
 
    dataToGeneratedCode = function(self)
        whileLoop = self.frameCount > 1 and cfg.loop
       
        local numberOfNeededFiles = math.ceil(self.frameCount / cfg.maxFramesPerGeneratedCodeFile)
 
        local cursorX, cursorY = term.getCursorPos()
        local i = 1
 
        local framesToSleep = {}
        for v = cfg.frameSleepSkipping, self.frameCount, cfg.frameSleepSkipping do
            table.insert(framesToSleep, cf.round(v))
        end
        local frameSleepSkippingIndex = 1
 
        for generatedCodeFileIndex = 1, numberOfNeededFiles do
            local handle = io.open('.generatedCodeFiles/'..generatedCodeFileIndex, 'w')
 
            local frameOffset = (generatedCodeFileIndex - 1) * cfg.maxFramesPerGeneratedCodeFile
 
            local frameCountToFile = math.min(self.frameCount - frameOffset, cfg.maxFramesPerGeneratedCodeFile)
 
            local minFrames = frameOffset + 1
            local maxFrames = frameOffset + frameCountToFile
 
            for f = minFrames, maxFrames do
                local string = '\ncf.frameWrite("' .. self.unpackedOptimizedFrames[f] .. '")'..
                '\nos.queueEvent("r")'..
                '\nos.pullEvent("r")'
 
                -- framesToSleep[frameSleepSkippingIndex] might cause errors when trying to access stuff outside of the table's scope
                if cfg.frameSleeping and cfg.frameSleep ~= -1 and f == framesToSleep[frameSleepSkippingIndex] then
                    string = string..
                    '\nsleep(' .. tostring(cfg.frameSleep) .. ')'
                    frameSleepSkippingIndex = frameSleepSkippingIndex + 1
                end
               
                handle:write(string)
               
                if i % 100 == 0 or i == self.frameCount then
                    term.setCursorPos(cursorX, cursorY)
                    print('Generated '..tostring(i)..'/'..tostring(self.frameCount)..' frames...')
                end
                i = i + 1
               
                cf.tryYield()
            end
           
            handle:close()
           
            cf.tryYield()
        end
    end,
 
    -- CODE EXECUTION --------------------------------------------------------
 
    loadAnimation = function(self, fileName)
        if cfg.computerType ~= 'laptop' and cfg.computerType ~= 'desktop' then
            error('You didn\'t enter a valid \'computerType\' name in the cfg file!')
        end
       
        self:getSelectedAnimationData(fileName, fileTab)
        cf.tryYield()
       
        self:createGeneratedCodeFolder()
        self:dataToGeneratedCode()
        cf.tryYield()
    end,
 
    _playAnimation = function(self, len)
        for i = 1, len do
            if cfg.playAnimationBool then
                self.passedShell.run('/.generatedCodeFiles/'..tostring(i))
            end
        end
        cf.tryYield()
    end,
 
    playAnimation = function(self, loop)
        print('Playing animation...')
        local len = #fs.list('.generatedCodeFiles')
 
        if loop then
            while true do
                if cfg.playAnimationBool then
                    self:_playAnimation(len)
                else
                    sleep(1)
                end
            end
        else
            self:_playAnimation(len)
        end
    end
 
}