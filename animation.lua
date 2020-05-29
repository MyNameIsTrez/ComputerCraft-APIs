-- Readme
--[[
This is a project for viewing regular video and image files in ASCII within Minecraft's ComputerCraft mod.

REQUIREMENTS
    * Common Functions (cf): https://pastebin.com/p9tSSWcB -- Provides cf.tryYield().
	* JSON (json): https://pastebin.com/4nRg9CHU - Provides converting a Lua table into a JavaScript object for the HTTPS API.
	* HTTPS (https): https://pastebin.com/iyBc3BWj - Gets the animation files from a server's storage.
	(Optional) BruteOS: <<<ADD PASTEBIN LINK HERE>>> -- Will use the BruteOS to print progress while loading animations.

The default terminal ratio is 25:9.
To get the terminal to fill your entire monitor and to get a custom text color:
1. Open AppData/Roaming/.technic/modpacks/tekkit/config/mod_ComputerCraft.cfg
2. Divide your monitor's width by 6 and your monitor's height by 9. 
3. Set terminal_width to the calculated width and do the same for terminal_height.
4. Set the terminal_textColour_r, terminal_textColour_g and terminal_textColour_b to values between 0 and 255 to get a custom text color.
]]--

-- Class table
Animation = {}

-- Constructor
function Animation:new(settings)
	setmetatable({}, Animation)

	-- Passed settings.
	self.passedShell                    = settings.shell
	self.frameSleeping                  = settings.frameSleeping
	self.frameSleep                     = settings.frameSleep
	self.frameSleepSkipping             = settings.frameSleepSkipping
	self.countdownTime                  = settings.countdownTime
	self.playAnimationBool              = settings.playAnimationBool
	self.maxFramesPerTimedAnimationFile = settings.maxFramesPerTimedAnimationFile
	self.progressBool                   = settings.progressBool
	-- self.useMonitor                     = settings.useMonitor
	self.loop                           = settings.loop
	self.folder                         = settings.folder
	self.offset                         = settings.offset
	self.animationSize                  = settings.animationSize -- If not provided, set by self.askFolder().
	self.fileName                       = settings.fileName -- If not provided, set by self.askFile().
	self.useCloud						= settings.useCloud

	self:initStructure()
	self:getScreenWidthHeight()
	
	return self
end

-- Methods
function Animation:initStructure()
	self.structure = {}

	-- Add local structure.
	local pathLocalAnimations = "BackwardsOS/programs/Animation/Animations/"
	if fs.exists(pathLocalAnimations) then
		for _, charType in ipairs(fs.list(pathLocalAnimations)) do
			local pathLocalCharType = pathLocalAnimations .. charType .. "/"
			if not self.structure[charType] then self.structure[charType] = {} end
			if fs.exists(pathLocalCharType) then
				for _, size in ipairs(fs.list(pathLocalCharType)) do
					local pathLocalFiles = pathLocalCharType .. size
					if not self.structure[charType][size] then self.structure[charType][size] = {} end
					local localFiles = fs.list(pathLocalFiles)
					for _, file in ipairs(localFiles) do table.insert(self.structure[charType][size], file) end
				end
			end
		end
	end

	-- Add cloud structure.
	if self.useCloud and http then
		local cloudStructure = https.getStorageStructure()
		if cloudStructure then
			for charType, _ in pairs(cloudStructure) do
				if not self.structure[charType] then self.structure[charType] = {} end
				for size, _ in pairs(cloudStructure[charType]) do
					if not self.structure[charType][size] then self.structure[charType][size] = {} end
					for _, file in ipairs(cloudStructure[size]) do table.insert(self.structure[charType][size], file) end
				end
			end
		end
	end

	if #cf.getKeys(self.structure) == 0 then error("No local or online structure could was found!") end
end

function Animation:getScreenWidthHeight()
	self.screenWidth, self.screenHeight = term.getSize()
end

function Animation:setShell(shl)
	self.passedShell = shl
end

function Animation:getLocalStructure()
	if not self.localStructure then
		self.localStructure = {}
		local pathLocalAnimations = "BackwardsOS/programs/Animation/Animations/"
		if fs.exists(pathLocalAnimations) then
			for _, charType in ipairs(fs.list(pathLocalAnimations)) do
				local pathLocalCharType = pathLocalAnimations .. charType .. "/"
				if not self.localStructure[charType] then self.localStructure[charType] = {} end
				if fs.exists(pathLocalCharType) then
					for _, size in ipairs(fs.list(pathLocalCharType)) do
						local pathLocalFiles = pathLocalCharType .. size
						if not self.localStructure[charType][size] then self.localStructure[charType][size] = {} end
						local localFiles = fs.list(pathLocalFiles)
						for _, file in ipairs(localFiles) do table.insert(self.localStructure[charType][size], file) end
					end
				end
			end
		end
	end
	return self.localStructure
end

-- Lists options the user can choose from.
-- If keysStrings is set to 'true', the table is looped with 'pairs()'.
function Animation:listOptions(askType)
	local localStructure = self:getLocalStructure()
	print()

	if askType == "charType" then
		for charType, _ in pairs(self.structure) do
			if localStructure[charType] ~= nil then
				term.write('  ')
			else
				term.write('! ')
			end
			print(charType)
		end
		
		print('\nEnter one of the above char types:')
		
		while true do
			local answerLowerCase = read():lower()
			for charType, _ in pairs(self.structure) do
				if charType:lower() == answerLowerCase then
					return charType
				end
			end
			print('Invalid program name.') -- Only reached when we haven't returned.
		end
	elseif askType == "size" then
		for size, _ in pairs(self.structure[self.charType]) do
			if localStructure[self.charType][size] ~= nil then
				term.write('  ')
			else
				term.write('! ')
			end
			local short = size:gsub('size_', '')
			print(short)
		end
		
		print('\nEnter one of the above folder names:')
		
		while true do
			local answerLowerCase = read():lower()
			for size, _ in pairs(self.structure[self.charType]) do
				if size:gsub('size_', ''):lower() == answerLowerCase then
					return size
				end
			end
			print('Invalid program name.') -- Only reached when we haven't returned.
		end
	elseif askType == "file" then
		for _, name in pairs(self.structure[self.charType][self.sizeFolder]) do
			if localStructure[self.charType][self.sizeFolder] ~= nil and cf.valueInTable(localStructure[self.charType][self.sizeFolder], name) then
				term.write('  ')
			else
				term.write('! ')
			end
			print(name)
		end
		
		print('\nEnter one of the above file names:')
		
		while true do
			local answerLowerCase = read():lower()
			for _, name in pairs(self.structure[self.charType][self.sizeFolder]) do
				if name:lower() == answerLowerCase then
					return name
				end
			end
			print('Invalid program name.') -- Only reached when we haven't returned.
		end
	end
end

function Animation:askCharType()
	local pathCharType = 'BackwardsOS/programs/Animation/Animations'
	if not fs.exists(pathCharType) then fs.makeDir(pathCharType) end
	self.charType = self:listOptions("charType")
	cf.clearTerm()
end

function Animation:askFolder()
	local pathAnimations = 'BackwardsOS/programs/Animation/Animations/' .. self.charType
	if not fs.exists(pathAnimations) then fs.makeDir(pathAnimations) end
	self.sizeFolder = self:listOptions("size")
	local _animationSize = cf.split(self.sizeFolder:gsub('size_', ''), 'x')
	self.animationSize = { width = _animationSize[1], height = _animationSize[2] }
	cf.clearTerm()
end

function Animation:askFile()
	local pathSize = 'BackwardsOS/programs/Animation/Animations/' .. self.charType .. '/' .. self.sizeFolder
	if not fs.exists(pathSize) then fs.makeDir(pathSize) end
	self.fileName = self:listOptions("file")
	cf.clearTerm()
end

function Animation:printProgress(str, x, y)
	-- If the BruteOS API is used, print the message at a different location.
	if _BRUTEOS then
		os.setMessage(str, 'NotUsingMenu');
	else
		if x and y then
			term.setCursorPos(x, y)
		end
		print(str)
	end
end

function Animation:downloadAnimationInfo(pathFile)
	local url = 'size_' .. self.animationSize.width .. 'x' .. self.animationSize.height .. '/' .. self.fileName .. '/info.txt'
	local str = https.getStorageData(url)

	if not fs.exists(pathFile) then fs.makeDir(pathFile) end

	local handle = io.open(self.folder .. 'Animations/' .. url, 'w')
	handle:write(str)
	handle:close()
	
	self.info = textutils.unserialize(str)
end

function Animation:downloadAnimationFile(pathFile)
	local cursorX, cursorY = term.getCursorPos()

	if self.progressBool then
		local str = 'Fetching animation file 1/' .. tostring(self.info.data_files) .. ' from server. Calculating ETA...'
		self:printProgress(str, cursorX, cursorY)
	end

	for i = 1, self.info.data_files do
		local timeStart = os.clock()

		local url    = 'size_' .. self.animationSize.width .. 'x' .. self.animationSize.height .. '/' .. self.fileName .. '/data/' .. tostring(i) .. '.txt'
		local folder = pathFile .. '/data'
		local name   = i
		https.downloadStorageFile(url, folder, name)

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

		if self.progressBool then
			local str = 'Fetching animation file ' .. tostring(i) .. '/' .. tostring(self.info.data_files) .. ' from server.' .. eta .. '           '
			self:printProgress(str, cursorX, cursorY)
		end
	end
end

function Animation:getInfo()
	local pathFile = self.folder .. 'Animations/' .. self.charType .. '/size_' .. self.animationSize.width .. 'x' .. self.animationSize.height .. '/' .. self.fileName .. '/'
	local str = fs.open(pathFile .. 'info.txt', 'r').readAll()
	self.info = textutils.unserialize(str)
end

function Animation:getSelectedAnimationData()
	-- Create Timed Animations folder.
	local pathTimedAnimations = self.folder .. 'Timed Animations/'
	if not fs.exists(pathTimedAnimations) then fs.makeDir(pathTimedAnimations) end

	-- Create charType folder.
	local pathTimedAnimationsCharType = pathTimedAnimations .. self.charType .. '/'
	if not fs.exists(pathTimedAnimationsCharType) then fs.makeDir(pathTimedAnimationsCharType) end
	
	-- Create size folder.
	local pathTimedAnimationsSize = pathTimedAnimationsCharType .. 'size_' .. self.animationSize.width .. 'x' .. self.animationSize.height .. '/'
	if not fs.exists(pathTimedAnimationsSize) then fs.makeDir(pathTimedAnimationsSize) end

	-- Create fileName folder.
	local pathTimedAnimationsFile = pathTimedAnimationsSize .. self.fileName .. '/'
	if not fs.exists(pathTimedAnimationsFile) then fs.makeDir(pathTimedAnimationsFile) end

	local pathAnimationsFile = self.folder .. 'Animations/' .. self.charType .. '/size_' .. self.animationSize.width .. 'x' .. self.animationSize.height .. '/' .. self.fileName
	local pathAnimationsInfo = pathAnimationsFile .. '/info.txt'

	if not fs.exists(pathAnimationsFile) then			
		self:downloadAnimationInfo(pathAnimationsFile)
		self:downloadAnimationFile(pathAnimationsFile)
	else
		local str = fs.open(pathAnimationsInfo, 'r').readAll()
		self.info = textutils.unserialize(str)
	end

	local frameCount = self.info.frame_count
	
	-- Create table of frame indices to sleep at.
	local framesToSleep = {}
	for v = 1, frameCount, self.frameSleepSkipping do
		table.insert(framesToSleep, math.floor(v + 0.5))
	end
	local frameSleepSkippingIndex = 1

	if self.progressBool then
		self:printProgress('Opening data files...')
	end

	cf.tryYield()
	
	local cursorX, cursorY = term.getCursorPos()
	local i = 1

	-- self.frameStrings = {}

	for dataFileIndex = 1, self.info.data_files do
		local pathData = pathTimedAnimationsFile .. dataFileIndex
		local dataWriteHandle = io.open(pathData, 'w')

		local frameOffset = (dataFileIndex - 1) * self.maxFramesPerTimedAnimationFile

		local frameCountToFile = math.min(frameCount - frameOffset, self.maxFramesPerTimedAnimationFile)

		local minFrames = frameOffset + 1
		local maxFrames = frameOffset + frameCountToFile

		-- I expect dataWriteHandle:write() to be an expensive operation, so that's why I chose to only write to it every 1000 frames.
		local strTable = {}
		local k = 1

		local pathDataFile = pathAnimationsFile .. '/data/' .. tostring(dataFileIndex) .. '.txt'
		local dataReadHandle = fs.open(pathDataFile, 'r')

		local f = minFrames
		-- for f = minFrames, maxFrames do
		for lineStr in dataReadHandle.readLine do
			-- 'k > 1' Prevents the first line of each generated code file being empty.
			if k > 1 then
				strTable[k] = '\n'
				k = k + 1
			end
			
			strTable[k] = 'cf.frameWrite("'
			k = k + 1
			-- strTable[k] = self.frameStrings[f]
			strTable[k] = lineStr
			k = k + 1
			strTable[k] = '",nil,nil'
			k = k + 1

			-- If this isn't the last frame, when the animation doesn't loop.
			if not (f == frameCount and self.loop == false) then
				strTable[k] = ','
				k = k + 1

				-- framesToSleep[frameSleepSkippingIndex] might cause errors when trying to access stuff outside of the table's scope
				if self.frameSleeping and self.frameSleep ~= -1 and f == framesToSleep[frameSleepSkippingIndex] then
					frameSleepSkippingIndex = frameSleepSkippingIndex + 1

					strTable[k] = tostring(self.frameSleep) -- May not need tostring().
					k = k + 1
				else
					strTable[k] = "'tryYield'"
					k = k + 1
				end
			end

			strTable[k] = ')'
			k = k + 1
			
			if i % self.maxFramesPerTimedAnimationFile == 0 or i == frameCount then
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
				
				dataWriteHandle:write(str)
				os.queueEvent('yield')
				os.pullEvent('yield')

				strTable = {}
				k = 1

				if self.progressBool then
					local str = 'Generated '..tostring(i)..'/'..tostring(frameCount)..' frames...'
					self:printProgress(str, cursorX, cursorY)
				end
			end

			i = i + 1
			f = f + 1
		end
		
		dataWriteHandle:close()
		dataReadHandle:close()

		cf.tryYield()
		









		-- local pathDataFile = pathAnimationsFile .. '/data/' .. tostring(dataFileIndex) .. '.txt'
		-- local dataReadHandle = fs.open(pathDataFile, 'r')

		-- for lineStr in dataReadHandle.readLine do














			-- self.frameStrings[i] = lineStr

			-- if i % 1000 == 0 then
			-- 	cf.yield()
			-- 	if self.progressBool then
			-- 		self:printProgress('Gotten ' .. tostring(i) .. '/' .. tostring(self.info.frame_count) .. ' data frames...', cursorX, cursorY)
			-- 	end
			-- end

			-- i = i + 1
		-- end
		
		-- dataReadHandle:close()
		-- cf.tryYield()
	end
	
	if self.progressBool then
		-- For the final frame.
		self:printProgress('Gotten ' .. tostring(self.info.frame_count) .. '/' .. tostring(self.info.frame_count) .. ' data frames...', cursorX, cursorY)
	end
end

function Animation:countdown()
	local cursorX, cursorY = term.getCursorPos()

	for i = 1, self.countdownTime do
		self:printProgress('Playing animation in ' .. tostring(self.countdownTime - i + 1) .. '...', cursorX, cursorY)
		sleep(1)
	end
end

function Animation:createTimedAnimation()
	local pathFile = self.folder .. 'Timed Animations/size_' .. self.animationSize.width .. 'x' .. self.animationSize.height .. '/' .. self.fileName
	if not fs.exists(pathFile) then -- Don't want to recreate a timed animation.
		self:getSelectedAnimationData()
		cf.tryYield()
		
		-- self:dataToTimedAnimation()
		-- cf.tryYield()
	end
end

function Animation:_playAnimation(path, len)
	for i = 1, len do
		if self.playAnimationBool then
			self.passedShell.run(path .. tostring(i))
		end
	end
	cf.tryYield()
end

function Animation:playAnimation()
	if self.progressBool then
		if self.countdownTime > 0 then
			self:countdown()
		else
			self:printProgress('Playing animation...')
		end
	end

	local pathFile = self.folder .. 'Timed Animations/' .. self.charType .. '/size_' .. self.animationSize.width .. 'x' .. self.animationSize.height .. '/' .. self.fileName .. '/'
	local len = #fs.list(pathFile)

	term.setCursorPos(self.offset.x, self.offset.y)

	-- Called because it's necessary to know self.info.frame_count.
	self:getInfo() -- TODO: Should be possible to call this method less often.

	if self.loop and self.info.frame_count > 1 then
		while true do
			if self.playAnimationBool then
				self:_playAnimation(pathFile, len)
			else
				sleep(1)
			end
		end
	else
		self:_playAnimation(pathFile, len)
	end
end

function Animation:setOffset(x, y)
	self.offset = { x = x, y = y }
end

function Animation:addOffset(x, y)
	self:setOffset(self.offset.x + x, self.offset.y + y)
end

function Animation:setCharCodeOffset(x_8, y_8)
	self:setOffset(1 + x_8 * 8, 1 + y_8 * 8)
end

function Animation:addCharCodeOffset(x_8, y_8)
	self:addOffset(x_8 * 8, y_8 * 8)
end

function Animation:writeCharCode(charCode, xCharOff, yCharOff)
	local validCharCode = charCode >= 1 and charCode <= 256

	local x = self.offset.x
	local y = self.offset.y

	local xCharOffNew = xCharOff or 1
	local yCharOffNew = yCharOff or 0
	local xNew = x + xCharOffNew * 8
	local yNew = y + yCharOffNew * 8

	local inCanvasNew = xNew >= 1 and yNew >= 1 and xNew <= self.screenWidth and yNew <= self.screenHeight
	
	if validCharCode and inCanvasNew then
		self:addCharCodeOffset(xCharOffNew, yCharOffNew)

		self.fileName = 'char_' .. tostring(charCode)

		self:createTimedAnimation()
		self:playAnimation()
	end
end