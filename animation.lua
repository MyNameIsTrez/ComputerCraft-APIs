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

	downloadAnimationInfo = function(self, path)
		local url = 'https://raw.githubusercontent.com/MyNameIsTrez/ComputerCraft-Data-Storage/master/' .. path .. '/info.txt'
		local str = https.get(url)

		local handle = io.open(path .. '/info.txt', 'w')
		handle:write(str)
		handle:close()
		
		self.info = self:stringToTable(str)
	end,

	downloadAnimationFile = function(self, path, fileDimensions)
		local cursorX, cursorY = term.getCursorPos()
		local path = path .. '/data'
		
		for i = 1, self.info.data_files do
			self:printProgress('Fetching animation file ' .. tostring(i) .. '/' .. tostring(self.info.data_files) .. ' from GitHub...', cursorX, cursorY)

			local url = 'https://raw.githubusercontent.com/MyNameIsTrez/ComputerCraft-Data-Storage/master/' .. path .. '/' .. i .. '.txt'
			
			https.downloadFile(url, path, i)
		end
	end,

	getSelectedAnimationData = function(self, path, fileDimensions, folder)
		local fileExists = fs.exists(path)

		if not fileExists then
			if not fs.exists(path) then
				fs.makeDir(path)
			end
			
			self:downloadAnimationInfo(path)
			self:downloadAnimationFile(path, fileDimensions)
		else
			local str = fs.open(path .. '/info.txt', 'r').readAll()
			self.info = self:stringToTable(str)
		end

		-- local file = fs.open(path .. '.txt', 'r')
		
		-- if not file then
		-- 	error('There was an attempt to load a file name that doesn\'t exist locally AND in the GitHub storage; check if the chosen file name and the file name in the input folder match.')
		-- end

		self:printProgress('Opening data files...')

		cf.tryYield()
		
		local cursorX, cursorY = term.getCursorPos()
		local i = 1

		frameStrings = {}

		for j = 1, self.info.data_files do
			local path2 = path .. '/data/' .. tostring(j) .. '.txt'
			local file = fs.open(path2, 'r')

			-- self.frameStrings = {}

			for lineStr in file.readLine do
				frameStrings[i] = lineStr

				if i % 1000 == 0 then
					cf.tryYield()
					self:printProgress('Gotten ' .. tostring(i) .. '/' .. tostring(self.info.frame_count) .. ' data frames...', cursorX, cursorY)
				end

				i = i + 1
			end
			
			file:close()
			cf.tryYield()
		end

		self.frameStrings = frameStrings
		
		-- For the final frame.
		self:printProgress('Gotten ' .. tostring(self.info.frame_count) .. '/' .. tostring(self.info.frame_count) .. ' data frames...', cursorX, cursorY)
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
			local handle = io.open('.generatedCodeFiles/'..generatedCodeFileIndex, 'w')

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
				
				if i % 1000 == 0 or i == self.info.frame_count then
					cf.tryYield()
					
					handle:write(table.concat(strTable))
					strTable = {}
					k = 1

					local str = 'Generated '..tostring(i)..'/'..tostring(self.info.frame_count)..' frames...'
					self:printProgress(str, cursorX, cursorY)
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

	-- CODE EXECUTION --------------------------------------------------------

	loadAnimation = function(self, fileName, fileDimensions, folder)
		if not fileName then error('fileName is nil, you need to enter the file name that you want to load.') end

		local path = folder .. '/' .. fileName

		self:getSelectedAnimationData(path, fileDimensions, folder)
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
		local countDown = cfg.countDown
		if countDown > 0 then
			self:countDown(countDown)
		else
			self:printProgress('Playing animation...')
		end

		local len = #fs.list('.generatedCodeFiles')

		if loop and self.info.frame_count > 1 then
			while true do
				if cfg.playAnimationBool then
					self:_playAnimation(len, countDown)
				else
					sleep(1)
				end
			end
		else
			self:_playAnimation(len)
		end
	end,

}