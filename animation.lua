-- README --------------------------------------------------------

-- Program used to create and preview dithered animations/images.

-- Other APIs required:
--     * Common Functions (cf) (https://pastebin.com/p9tSSWcB)

-- The default terminal ratio is 25:9.
-- To get the terminal to fill your entire monitor and to get a custom text color:
-- 1. Open AppData/Roaming/.technic/modpacks/tekkit/config/mod_ComputerCraft.cfg
-- 2. Divide your monitor's width by 6 and your monitor's height by 9. 
-- 3. Set terminal_width to the calculated width and do the same for terminal_height.
-- 4. Set the terminal_textColour_r, terminal_textColour_g and terminal_textColour_b
--    to values between 0 and 255 to get a custom text color.

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

	-- IMPORTING --------------------------------------------------------

	-- Request animation using http calls.
	-- importAnimationData = function(self)
	-- end,

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
				clear = '		'

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

	getSelectedAnimationData = function(self, fileName)
		if cfg.computerType ~= 'laptop' and cfg.computerType ~= 'desktop' then
			error('You didn\'t enter a valid \'computerType\' name in the cfg file!')
		end

		print('1/4 - Opening chosen data file...')

		if not fileName then
			error('There was an attempt to load a file name that doesn\'t exist; check if the chosen file name and the file name in the input folder match.')
		end

		local file = fs.open(cfg.computerType .. ' inputs/' .. fileName .. '.txt', 'r')

		if not file then
			error('There was an attempt to load a file name that doesn\'t exist; check if the chosen file name and the file name in the input folder match.')
		end

		cf.tryYield()

		local startIndex = cf.find(fileName, '[') + 1
		local endIndex = cf.find(fileName, ']') - 1
		self.frameCount = tonumber(fileName:sub(startIndex, endIndex))
		cf.tryYield()

		local cursorX, cursorY = term.getCursorPos()
		local stringTab = {}
		local i = 1
		for lineStr in file.readLine do
			table.insert(stringTab, lineStr)

			if i % 100 == 0 or i == self.frameCount then
				term.setCursorPos(cursorX, cursorY)
				print('2/4 - Got '..tostring(i)..'/'..tostring(self.frameCount)..' data lines...')
			end
			i = i + 1

			cf.yield()
		end
		
		file:close()
		cf.tryYield()

		local finalLine = stringTab[#stringTab]
		local compressedIndex = finalLine:find('compressed') + 11
		local compressedIndexComma = finalLine:find(',', compressedIndex) - 1
		self.compressed = finalLine:sub(compressedIndex, compressedIndexComma) == 'true'
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
					print('3/4 - Generated '..tostring(i)..'/'..tostring(self.frameCount)..' frames...')
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
		-- self:importAnimationData() -- Request an animation using a http call.
		self:getSelectedAnimationData(fileName)
		cf.tryYield()

		self:createGeneratedCodeFolder()
		self:dataToGeneratedCode()
		cf.tryYield()
	end,

	_playAnimation = function(self, len)
		if cfg.playAnimationBool then
			for i = 1, len do
				if cfg.playAnimationBool then
					self.passedShell.run('/.generatedCodeFiles/'..tostring(i))
				end
			end
		else
			sleep(1)
		end
		cf.tryYield()
	end,

	playAnimation = function(self, loop)
		local len = #fs.list('.generatedCodeFiles')

		if loop then
			while true do
				self:_playAnimation(len)
			end
		else
			self:_playAnimation(len)
		end
	end

}