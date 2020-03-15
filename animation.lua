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
			unpackedOptimizedFrames = {},
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

	downloadAnimationInfo = function(self, folder, fileName)
		local url = 'https://raw.githubusercontent.com/MyNameIsTrez/ComputerCraft-Data-Storage/master/' .. folder .. '/' .. fileName .. '/info.txt'
		local str = https.get(url)

		local path = folder .. '/' .. fileName

		if not fs.exists(path) then
			fs.makeDir(path)
		end

		local handle = io.open(path .. '/info.txt', 'w')
		handle:write(str)
		handle:close()
		
		self.info = self:stringToTable(str)
	end,

	downloadAnimationFile = function(self, folder, fileName, fileDimensions)
		self:printProgress('Fetching animation file from GitHub...')

		local path = folder .. '/' .. fileName .. '/data'
		
		for i = 1, self.info.data_files do
			local url = 'https://raw.githubusercontent.com/MyNameIsTrez/ComputerCraft-Data-Storage/master/' .. path .. '/' .. i .. '.txt'
			
			https.downloadFile(url, path, i)
		end
	end,

	getSelectedAnimationData = function(self, fileName, fileDimensions, folder)
		local fileExists = fs.exists(folder .. '/' .. fileName)

		if not fileExists then
			self:downloadAnimationInfo(folder, fileName)
			self:downloadAnimationFile(folder, fileName, fileDimensions)
		end
		
		local file = fs.open(folder .. '/' .. fileName .. '.txt', 'r')
		
		if not file then
			error('There was an attempt to load a file name that doesn\'t exist locally AND in the GitHub storage; check if the chosen file name and the file name in the input folder match.')
		end

		self:printProgress('Opening animation file...')

		cf.tryYield()
		
		local cursorX, cursorY = term.getCursorPos()
		local stringTab = {}
		local i = 1

		for lineStr in file.readLine do
			table.insert(stringTab, lineStr)

			if i % 1000 == 0 then
				self:printProgress('Gotten '..tostring(i)..' frames...', cursorX, cursorY)
			end
			i = i + 1

			cf.yield()
		end
		
		-- For the final frame.
		self:printProgress('Gotten '..tostring(i - 2)..' frames...', cursorX, cursorY)
		
		file:close()
		cf.tryYield()

		-- The general information data can be removed, so only the frames are left.
		table.remove(stringTab, #stringTab)
		local optimizedFrames = stringTab
		cf.tryYield()
		
		self.unpackedOptimizedFrames = optimizedFrames
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
		whileLoop = self.info.frame_count > 1 and cfg.loop
		
		local numberOfNeededFiles = math.ceil(self.info.frame_count / cfg.maxFramesPerGeneratedCodeFile)

		local cursorX, cursorY = term.getCursorPos()
		local i = 1

		local framesToSleep = {}
		for v = cfg.frameSleepSkipping, self.info.frame_count, cfg.frameSleepSkipping do
			table.insert(framesToSleep, cf.round(v))
		end
		local frameSleepSkippingIndex = 1

		for generatedCodeFileIndex = 1, numberOfNeededFiles do
			local handle = io.open('.generatedCodeFiles/'..generatedCodeFileIndex, 'w')

			local frameOffset = (generatedCodeFileIndex - 1) * cfg.maxFramesPerGeneratedCodeFile

			local frameCountToFile = math.min(self.info.frame_count - frameOffset, cfg.maxFramesPerGeneratedCodeFile)

			local minFrames = frameOffset + 1
			local maxFrames = frameOffset + frameCountToFile

			for f = minFrames, maxFrames do
				local str = '\ncf.frameWrite("' .. self.unpackedOptimizedFrames[f] .. '")'

				-- framesToSleep[frameSleepSkippingIndex] might cause errors when trying to access stuff outside of the table's scope
				if cfg.frameSleeping and cfg.frameSleep ~= -1 and f == framesToSleep[frameSleepSkippingIndex] then
					str = str .. '\nsleep(' .. tostring(cfg.frameSleep) .. ')'
					frameSleepSkippingIndex = frameSleepSkippingIndex + 1
				else
					str = str .. '\nos.queueEvent("r")' .. '\nos.pullEvent("r")'
				end
				
				handle:write(str)
				
				if i % 1000 == 0 or i == self.info.frame_count then
					local str = 'Generated '..tostring(i)..'/'..tostring(self.info.frame_count)..' frames...'
					self:printProgress(str, cursorX, cursorY)
				end
				i = i + 1
				
				cf.tryYield()
			end
			
			handle:close()
			
			cf.tryYield()
		end
	end,

	-- CODE EXECUTION --------------------------------------------------------

	loadAnimation = function(self, fileName, fileDimensions, folder)
		if not fileName then error('fileName is nil, you need to enter the file name that you want to load.') end
		self:getSelectedAnimationData(fileName, fileDimensions, folder)
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
		self:printProgress('Playing animation...')
		
		local len = #fs.list('.generatedCodeFiles')

		if loop and self.info.frame_count > 1 then
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
	end,

}