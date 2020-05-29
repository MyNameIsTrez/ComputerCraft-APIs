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
	self.animationSize                  = settings.animationSize -- If not provided, set by self.askAnimationFolder().
	self.fileName                       = settings.fileName -- If not provided, set by self.askAnimationFile().

	if http and not settings.useHardcodedStorageStructure then
		self.structure = https.getStorageStructure()
	elseif settings.useHardcodedStorageStructure then
		self.structure = settings.hardcodedStorageStructure
	else
		error("The settings/lack of HTTP connection didn't allow loading of the structure locally/from HTTP.")
	end
	
	self:getScreenWidthHeight()
	
	return self
end

-- Methods
function Animation:setShell(shl)
	self.passedShell = shl
end

function Animation:getScreenWidthHeight()
	self.screenWidth, self.screenHeight = term.getSize()
end

-- Lists options the user can choose from.
-- If keysStrings is set to 'true', the table is looped with 'pairs()'.
function Animation:listOptions(cloudOptions, keysStrings, localOptions)
	cloudOptionsShort = {}
	if keysStrings then
		-- Folders.
		for name, _ in pairs(cloudOptions) do
			-- a is necessary, because gsub() also returns a second value being the number of substitutions made.
			local a = name:gsub('size_', '')
			table.insert(cloudOptionsShort, a)
		end
	else
		-- Files.
		for _, name in ipairs(cloudOptions) do
			local a = name:gsub('size_', '')
			table.insert(cloudOptionsShort, a)
		end
	end

	localOptionsShort = {}
	for _, name in ipairs(localOptions) do
		local a = name:gsub('size_', '')
		table.insert(localOptionsShort, a)
	end

	for _, name in ipairs(cloudOptionsShort) do
		if cf.valueInTable(localOptionsShort, name) then
			term.write('  ')
		else
			term.write('! ')
		end
		print(name)
	end
	
	print()
	print('Enter one of the above names:')
	
	while true do
		local answer = read()
		local answerLowerCase = answer:lower()

		for _, option in ipairs(cloudOptionsShort) do
			if option:lower() == answerLowerCase then
				if keysStrings then
					return 'size_' .. answer
				else
					return answer
				end
			end
		end
		
		print('Invalid program name.') -- Only reached if we haven't returned.
	end
end

-- Asks the user for an animation folder to load.
function Animation:askAnimationFolder()
	-- Get the size options.
	local pathAnimations = 'BackwardsOS/programs/Animation/Animations'
	if not fs.exists(pathAnimations) then
		fs.makeDir(pathAnimations)
	end
	local localStructure = fs.list(pathAnimations)

	-- Ask the size folder name.
	self.sizeFolder = self:listOptions(self.structure, true, localStructure)
	
	-- Skips the beginning 'size_' part.
	local sizeStr = cf.split(self.sizeFolder, '_')[2]
	
	-- Splits the width and height.
	local _animationSize = cf.split(sizeStr, 'x')
	
	self.animationSize = { width = _animationSize[1], height = _animationSize[2] }
	
	term.clear()
	term.setCursorPos(1, 1)
end

-- Asks the user for an animation file to load.
function Animation:askAnimationFile()
	local pathSize = 'BackwardsOS/programs/Animation/Animations/' .. self.sizeFolder

	if not fs.exists(pathSize) then
		fs.makeDir(pathSize)
	end

	local localPrograms = fs.list(pathSize)
	local programOptions = self.structure[self.sizeFolder]

	-- Ask the animation file name.
	self.fileName = self:listOptions(programOptions, false, localPrograms)
	
	term.clear()
	term.setCursorPos(1, 1)
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

	if not fs.exists(pathFile) then
		fs.makeDir(pathFile)
	end

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
	local pathFile = self.folder .. 'Animations/size_' .. self.animationSize.width .. 'x' .. self.animationSize.height .. '/' .. self.fileName .. '/'
	local str = fs.open(pathFile .. 'info.txt', 'r').readAll()
	self.info = textutils.unserialize(str)
end

function Animation:getSelectedAnimationData()
	local pathFile = self.folder .. 'Animations/size_' .. self.animationSize.width .. 'x' .. self.animationSize.height .. '/' .. self.fileName
	local fileExists = fs.exists(pathFile)

	if not fileExists then			
		self:downloadAnimationInfo(pathFile)
		self:downloadAnimationFile(pathFile)
	else
		local str = fs.open(pathFile .. '/info.txt', 'r').readAll()
		self.info = textutils.unserialize(str)
	end

	if self.progressBool then
		self:printProgress('Opening data files...')
	end

	cf.tryYield()
	
	local cursorX, cursorY = term.getCursorPos()
	local i = 1

	self.frameStrings = {}

	for j = 1, self.info.data_files do
		local pathDataFile = pathFile .. '/data/' .. tostring(j) .. '.txt'
		local file = fs.open(pathDataFile, 'r')

		for lineStr in file.readLine do
			self.frameStrings[i] = lineStr

			if i % 1000 == 0 then
				cf.yield()
				if self.progressBool then
					self:printProgress('Gotten ' .. tostring(i) .. '/' .. tostring(self.info.frame_count) .. ' data frames...', cursorX, cursorY)
				end
			end

			i = i + 1
		end
		
		file:close()
		cf.tryYield()
	end
	
	if self.progressBool then
		-- For the final frame.
		self:printProgress('Gotten ' .. tostring(self.info.frame_count) .. '/' .. tostring(self.info.frame_count) .. ' data frames...', cursorX, cursorY)
	end
end

function Animation:dataToTimedAnimation()
	local frameCount = self.info.frame_count

	local cursorX, cursorY = term.getCursorPos()
	local i = 1

	local framesToSleep = {}
	for v = 1, frameCount, self.frameSleepSkipping do
		table.insert(framesToSleep, math.floor(v + 0.5))
	end
	local frameSleepSkippingIndex = 1

	-- Create Timed Animations folder.
	local path1 = self.folder .. 'Timed Animations/'
	if not fs.exists(path1) then
		fs.makeDir(path1)
	end
	
	-- Create size folder.
	local pathSize = path1 .. 'size_' .. self.animationSize.width .. 'x' .. self.animationSize.height .. '/'
	if not fs.exists(pathSize) then
		fs.makeDir(pathSize)
	end

	-- Create fileName folder.
	local path3 = pathSize .. self.fileName .. '/'
	if not fs.exists(path3) then
		fs.makeDir(path3)
	end

	for subfile = 1, self.info.data_files do
		local path4 = path3 .. subfile
		local handle = io.open(path4, 'w')

		local frameOffset = (subfile - 1) * self.maxFramesPerTimedAnimationFile

		local frameCountToFile = math.min(frameCount - frameOffset, self.maxFramesPerTimedAnimationFile)

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
				
				handle:write(str)
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
		end
		
		handle:close()
		
		cf.tryYield()
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
	local path1 = self.folder .. 'Timed Animations/size_' .. self.animationSize.width .. 'x' .. self.animationSize.height .. '/' .. self.fileName
	if fs.exists(path1) then -- We don't need to recreate the timed animation.
		return
	end

	self:getSelectedAnimationData()
	cf.tryYield()
	
	self:dataToTimedAnimation()
	cf.tryYield()
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

	local pathFile = self.folder .. 'Timed Animations/size_' .. self.animationSize.width .. 'x' .. self.animationSize.height .. '/' .. self.fileName .. '/'
	local len = #fs.list(pathFile)

	term.setCursorPos(self.offset.x, self.offset.y)

	-- Called because it's necessary to know self.info.frame_count.
	self:getInfo() -- Seems like it should be possible to call this method less often !!!

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