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
			structure = https.getStructure()
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

	downloadAnimationFileFromGitHub = function(self, fileName, fileDimensions, outputFolder)
		self:printProgress('Fetching animation file from GitHub...')
		
		local url = 'https://raw.githubusercontent.com/MyNameIsTrez/ComputerCraft-Data-Storage/master/' .. outputFolder .. '/' .. fileName .. '.txt'
		
   		https.downloadFile(url, outputFolder, fileName)
	end,

	getSelectedAnimationData = function(self, fileName, fileDimensions, outputFolder)
		local fileExists = fs.exists(outputFolder .. '/' .. fileName .. '.txt')
		if not fileExists then
			self:downloadAnimationFileFromGitHub(fileName, fileDimensions, outputFolder)
		end
		
		local file = fs.open(outputFolder .. '/' .. fileName .. '.txt', 'r')
		
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
		
		-- Get the file info, if the file was loaded from a local save.
		if not fileInfo then fileInfo = stringTab[#stringTab] end
		
		local frameSearch = 'frame_count=(.-),'
		fileInfo:gsub(frameSearch, function(count) self.frameCount = tonumber(count) end)
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
				local string = '\ncf.frameWrite("' .. self.unpackedOptimizedFrames[f] .. '")'

				-- framesToSleep[frameSleepSkippingIndex] might cause errors when trying to access stuff outside of the table's scope
				if cfg.frameSleeping and cfg.frameSleep ~= -1 and f == framesToSleep[frameSleepSkippingIndex] then
					string = string .. '\nsleep(' .. tostring(cfg.frameSleep) .. ')'
					frameSleepSkippingIndex = frameSleepSkippingIndex + 1
				else
					string = string .. '\nos.queueEvent("r")' .. '\nos.pullEvent("r")'
				end
				
				handle:write(string)
				
				if i % 1000 == 0 or i == self.frameCount then
					local str = 'Generated '..tostring(i)..'/'..tostring(self.frameCount)..' frames...'
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

	loadAnimation = function(self, fileName, fileDimensions, outputFolder)
		if not fileName then error('fileName is nil, you need to enter the file name that you want to load.') end
		self:getSelectedAnimationData(fileName, fileDimensions, outputFolder)
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

		if loop and self.frameCount > 1 then
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