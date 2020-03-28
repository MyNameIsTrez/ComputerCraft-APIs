-- README --------------------------------------------------------

--[[
-- Program used to create and preview dithered animations/images.

REQUIREMENTS
    * Common Functions (cf): https://pastebin.com/p9tSSWcB -- Provides cf.tryYield().
	* JSON (json): https://pastebin.com/4nRg9CHU - Provides converting a Lua table into a JavaScript object for the HTTPS API.
	* HTTPS (https): https://pastebin.com/iyBc3BWj - Gets the animation files from a GitHub storage repository.
	(Optional) BruteOS: <<<ADD PASTEBIN LINK HERE>>> -- Will use the BruteOS to print progress in loading animations.

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
			frameStrings = {},
			structure = https.getStructure(),
			info,
		}
		
		setmetatable(startingValues, {__index = self})
		return startingValues
	end,

	setShell = function(self, sl)
	    self.passedShell = sl
	end,

	-- FUNCTIONS --------------------------------------------------------
	
	printProgress = function(self, str, x, y)
		-- If the BruteOS API is used, print the message at a different location.
		if _BRUTEOS then
 			os.setMessage(str, 'NotUsingMenu');
		else
			if x and y then
				term.setCursorPos(x, y)
			end
 			print(str)
		end
	end,

	stringToTable = function(self, str)
		local i = 0
		local keys = {}
		local keySearch = '[{,](.-)='
		str:gsub(keySearch, function(key)
			i = i + 1
			keys[i] = key
		end)
		
		local j = 1
		local values = {}
		local valueSearch = '=(.-)[,}]'
		str:gsub(valueSearch, function(value)
			values[j] = tonumber(value)
			j = j + 1
		end)
		
		local combined = {}
		for k = 1, i do
			local key = keys[k]
			local value = values[k]
			combined[key] = value
		end

		return combined
	end,

	downloadAnimationInfo = function(self, gitHubPath, folder)
		local url = 'https://raw.githubusercontent.com/MyNameIsTrez/ComputerCraft-Data-Storage/master/' .. gitHubPath .. '/info.txt'
		local str = https.get(url)

		local handle = io.open(folder .. gitHubPath .. '/info.txt', 'w')
		handle:write(str)
		handle:close()
		
		self.info = self:stringToTable(str)
	end,

	downloadAnimationFile = function(self, gitHubPath, fileDimensions, folder)
		local cursorX, cursorY = term.getCursorPos()
		local gitHubDataPath = gitHubPath .. '/data'

		local str = 'Fetching animation file 1/' .. tostring(self.info.data_files) .. ' from GitHub. Calculating ETA...'
		self:printProgress(str, cursorX, cursorY)

		for i = 1, self.info.data_files do
			local timeStart = os.clock()

			local url = 'https://raw.githubusercontent.com/MyNameIsTrez/ComputerCraft-Data-Storage/master/' .. gitHubDataPath .. '/' .. i .. '.txt'
			https.downloadFile(url, folder .. gitHubDataPath, i)

			local timeEnd = os.clock()

			-- Print the ETA.
			local filesLeft = self.info.data_files - i
			local secondsLeft = (timeEnd - timeStart) * filesLeft
			local seconds = math.floor(secondsLeft % 60)
			local minutes = math.floor(secondsLeft / 60 % 60)
			local hours   = math.floor(secondsLeft / 3600 % 60)

			local eta = ' ( ' ..
			(hours   < 10 and '0' or '') .. tostring(hours)   .. ':' ..
			(minutes < 10 and '0' or '') .. tostring(minutes) .. ':' ..
			(seconds < 10 and '0' or '') .. tostring(seconds) .. ' )'

			-- Prevents printing '8/7' for the last frame.
			if i < self.info.data_files then
				i = i + 1
			end

			local str = 'Fetching animation file ' .. tostring(i) .. '/' .. tostring(self.info.data_files) .. ' from GitHub.' .. eta .. '           '

			self:printProgress(str, cursorX, cursorY)
		end
	end,

	getSelectedAnimationData = function(self, fileDimensions, gitHubPath, folder, progressBool)
		local fileExists = fs.exists(folder .. gitHubPath)

		if not fileExists then
			if not fs.exists(folder .. gitHubPath) then
				fs.makeDir(folder .. gitHubPath)
			end
			
			self:downloadAnimationInfo(gitHubPath, folder)
			self:downloadAnimationFile(gitHubPath, fileDimensions, folder)
		else
			local str = fs.open(folder .. gitHubPath .. '/info.txt', 'r').readAll()
			self.info = self:stringToTable(str)
		end

		-- local file = fs.open(gitHubPath .. '.txt', 'r')
		
		-- if not file then
		-- 	error('There was an attempt to load a file name that doesn\'t exist locally AND in the GitHub storage; check if the chosen file name and the file name in the input folder match.')
		-- end

		if progressBool then
			self:printProgress('Opening data files...')
		end

		cf.tryYield()
		
		local cursorX, cursorY = term.getCursorPos()
		local i = 1

		frameStrings = {}

		for j = 1, self.info.data_files do
			local path2 = folder .. gitHubPath .. '/data/' .. tostring(j) .. '.txt'
			local file = fs.open(path2, 'r')

			-- self.frameStrings = {}

			for lineStr in file.readLine do
				frameStrings[i] = lineStr

				if i % 1000 == 0 then
					cf.yield()
					if progressBool then
						self:printProgress('Gotten ' .. tostring(i) .. '/' .. tostring(self.info.frame_count) .. ' data frames...', cursorX, cursorY)
					end
				end

				i = i + 1
			end
			
			file:close()
			cf.tryYield()
		end

		self.frameStrings = frameStrings
		
		if progressBool then
			-- For the final frame.
			self:printProgress('Gotten ' .. tostring(self.info.frame_count) .. '/' .. tostring(self.info.frame_count) .. ' data frames...', cursorX, cursorY)
		end
	end,

	createGeneratedCodeFolder = function(self, folder)
		if fs.exists(folder .. '.generatedCodeFiles') then
			local names = fs.list(folder .. '.generatedCodeFiles')

			for _, name in pairs(names) do
				fs.delete(folder .. '.generatedCodeFiles/'..tostring(name))
			end
		else
			fs.makeDir(folder .. '.generatedCodeFiles')
		end
	end,

	dataToGeneratedCode = function(self, folder, progressBool)
		-- local whileLoop = self.info.frame_count > 1 and cfg.loop
		
		local numberOfNeededFiles = math.ceil(self.info.frame_count / cfg.maxFramesPerGeneratedCodeFile)

		local cursorX, cursorY = term.getCursorPos()
		local i = 1

		local framesToSleep = {}
		for v = 1, self.info.frame_count, cfg.frameSleepSkipping do
			table.insert(framesToSleep, math.floor(v + 0.5))
		end
		local frameSleepSkippingIndex = 1

		for generatedCodeFileIndex = 1, numberOfNeededFiles do
			local handle = io.open(folder .. '.generatedCodeFiles/' .. generatedCodeFileIndex, 'w')

			local frameOffset = (generatedCodeFileIndex - 1) * cfg.maxFramesPerGeneratedCodeFile

			local frameCountToFile = math.min(self.info.frame_count - frameOffset, cfg.maxFramesPerGeneratedCodeFile)

			local minFrames = frameOffset + 1
			local maxFrames = frameOffset + frameCountToFile

			-- I expect handle:write() to be an expensive operation, so that's why I chose to only write to it every 1000 frames.
			local strTable = {}
			local k = 1

			for f = minFrames, maxFrames do
				-- Prevents the first line of each generated code file being empty.
				if k > 1 then
					strTable[k] = '\n'
					k = k + 1
				end
				
				strTable[k] = 'cf.frameWrite("'
				k = k + 1
				strTable[k] = self.frameStrings[f]
				k = k + 1
				strTable[k] = '")'
				k = k + 1

				-- framesToSleep[frameSleepSkippingIndex] might cause errors when trying to access stuff outside of the table's scope
				if cfg.frameSleeping and cfg.frameSleep ~= -1 and f == framesToSleep[frameSleepSkippingIndex] then
					strTable[k] = '\nsleep('
					k = k + 1
					strTable[k] = tostring(cfg.frameSleep)
					k = k + 1
					strTable[k] = ')'
					k = k + 1
					
					frameSleepSkippingIndex = frameSleepSkippingIndex + 1
				else
					strTable[k] = '\nos.queueEvent("y")'
					k = k + 1
					strTable[k] = '\nos.pullEvent("y")'
					k = k + 1
				end
				
				if i % cfg.maxFramesPerGeneratedCodeFile == 0 or i == self.info.frame_count then
					cf.tryYield()
					
					-- I don't remember why it's necessary to check this. Try removing this later.
					local allAreStrings = true
					for str in ipairs(strTable) do
						if type(str) ~= 'string' then
							allAreStrings = false
						end
					end
					os.queueEvent('yield')
					os.pullEvent('yield')

					local str = table.concat(strTable)
					os.queueEvent('yield')
					os.pullEvent('yield')
					
					handle:write(str)
					os.queueEvent('yield')
					os.pullEvent('yield')

					strTable = {}
					k = 1

					if progressBool then
						local str = 'Generated '..tostring(i)..'/'..tostring(self.info.frame_count)..' frames...'
						self:printProgress(str, cursorX, cursorY)
					end
				end

				i = i + 1
			end
			
			handle:close()
			
			cf.tryYield()
		end
	end,

	countDown = function(self, countDown)
		local cursorX, cursorY = term.getCursorPos()

		for i = 1, cfg.countDown do
			self:printProgress('Playing animation in ' .. tostring(cfg.countDown - i + 1) .. '...', cursorX, cursorY)
			sleep(1)
		end
	end,

	loadAnimation = function(self, fileName, fileDimensions, gitHubFolder, folder, progressBool)
		if not fileName then error('fileName is nil, you need to enter the file name that you want to load.') end

		local gitHubPath = gitHubFolder .. '/' .. fileName

		self:getSelectedAnimationData(fileDimensions, gitHubPath, folder, progressBool)
		cf.tryYield()
		
		self:createGeneratedCodeFolder(folder)
		self:dataToGeneratedCode(folder, progressBool)
		cf.tryYield()
	end,

	_playAnimation = function(self, len, folder)
		for i = 1, len do
			if cfg.playAnimationBool then
				self.passedShell.run(folder .. '.generatedCodeFiles/' .. tostring(i))
			end
		end

		cf.tryYield()
	end,

	playAnimation = function(self, loop, folder, progressBool)
		if progressBool then
			local countDown = cfg.countDown
			if countDown > 0 then
				self:countDown(countDown)
			else
				self:printProgress('Playing animation...')
			end
		end

		local len = #fs.list(folder .. '.generatedCodeFiles')

		if loop and self.info.frame_count > 1 then
			while true do
				if cfg.playAnimationBool then
					self:_playAnimation(len, folder)
				else
					sleep(1)
				end
			end
		else
			self:_playAnimation(len, folder)
		end
	end,

}