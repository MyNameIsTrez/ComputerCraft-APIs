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

Animation = {}
function Animation:new(settings)
	setmetatable({}, Animation)

	self.path = settings.path

	self:_init_paths()
	self:_get_metadata()
	
	return self
end

function Animation:_init_paths()
	self.ascii_path       = cf.pathJoin(self.path, "ascii-content")
	self.timed_ascii_path = cf.pathJoin(self.path, "timed-ascii-content")
end

function Animation:_get_metadata()
	self.metadata = online_storage.get_metadata()
end

function Animation:print_ascii_names()
	for _, document in ipairs(self.metadata) do
		cf.printTable(document)
	end
end

function Animation:choose_document()
	print('\nEnter a "displayed_name":')
	while true do
		local answer_lowercase = read():lower()
		for _, document in pairs(self.metadata) do
			if document.displayed_name:lower() == answer_lowercase then
				self.document = document
				return
			end
		end
		print('\nInvalid "displayed_name", try again:')
	end
end

function Animation:download_subfiles()
	local document_path = cf.pathJoin(self.ascii_path, self.document._id)
	fs.makeDir(document_path)
	for subfile_id = 1, self.document.frame_files_count do
		local handle = fs.open(cf.pathJoin(document_path, subfile_id), "w")
		handle.write(online_storage.get_ascii_subfile(self.document._id, subfile_id))
		handle.close()
	end
end

-- function Animation:initStructure()
-- 	-- self.metadata = 


-- 	-- self.structure = {}

-- 	-- -- Add local structure.
-- 	-- if fs.exists(self.ascii_path) then
-- 	-- 	for _, charType in ipairs(fs.list(self.ascii_path)) do
-- 	-- 		local pathLocalCharType = cf.pathJoin(self.ascii_path, charType)
-- 	-- 		if not self.structure[charType] then self.structure[charType] = {} end
-- 	-- 		if fs.exists(pathLocalCharType) then
-- 	-- 			for _, size in ipairs(fs.list(pathLocalCharType)) do
-- 	-- 				local pathLocalFiles = cf.pathJoin(pathLocalCharType, size)
-- 	-- 				if not self.structure[charType][size] then self.structure[charType][size] = {} end
-- 	-- 				local localFiles = fs.list(pathLocalFiles)
-- 	-- 				for _, file in ipairs(localFiles) do table.insert(self.structure[charType][size], file) end
-- 	-- 			end
-- 	-- 		end
-- 	-- 	end
-- 	-- end

-- 	-- -- Add server structure.
-- 	-- if self.useCloud and http then
-- 	-- 	local cloudStructure = https.getAsciiInfo()
-- 	-- 	if cloudStructure then
-- 	-- 		for charType, _ in pairs(cloudStructure) do
-- 	-- 			if not self.structure[charType] then self.structure[charType] = {} end
-- 	-- 			for size, _ in pairs(cloudStructure[charType]) do
-- 	-- 				if not self.structure[charType][size] then self.structure[charType][size] = {} end
-- 	-- 				for _, file in ipairs(cloudStructure[charType][size]) do
-- 	-- 					if not cf.valueInTable(self.structure[charType][size], file) then
-- 	-- 						table.insert(self.structure[charType][size], file)
-- 	-- 					end
-- 	-- 				end
-- 	-- 			end
-- 	-- 		end
-- 	-- 	end
-- 	-- end

-- 	-- if #cf.getKeys(self.structure) == 0 then error("No local or server structure found!") end
-- end

-- function Animation:getLocalStructure()
-- 	if not self.localStructure then
-- 		self.localStructure = {}
-- 		if fs.exists(self.ascii_path) then
-- 			for _, charType in ipairs(fs.list(self.ascii_path)) do
-- 				local pathLocalCharType = cf.pathJoin(self.ascii_path, charType)
-- 				if not self.localStructure[charType] then self.localStructure[charType] = {} end
-- 				if fs.exists(pathLocalCharType) then
-- 					for _, size in ipairs(fs.list(pathLocalCharType)) do
-- 						if not self.localStructure[charType][size] then self.localStructure[charType][size] = {} end
-- 						local pathLocalFiles = cf.pathJoin(pathLocalCharType, size)
-- 						local localFiles = fs.list(pathLocalFiles)
-- 						for _, file in ipairs(localFiles) do table.insert(self.localStructure[charType][size], file) end
-- 					end
-- 				end
-- 			end
-- 		end
-- 	end
-- 	return self.localStructure
-- end

-- -- Lists options the user can choose from.
-- -- If keysStrings is set to 'true', the table is looped with 'pairs()'.
-- function Animation:listOptions(askType)
-- 	local localStructure = self:getLocalStructure()
-- 	print()

-- 	if askType == "charType" then
-- 		for charType, _ in pairs(self.structure) do
-- 			if localStructure[charType] ~= nil then
-- 				term.write('  ')
-- 			else
-- 				term.write('! ')
-- 			end
-- 			print(charType)
-- 		end
		
-- 		print('\nEnter one of the above char types:')
		
-- 		while true do
-- 			local answer_lowercase = read():lower()
-- 			for charType, _ in pairs(self.structure) do
-- 				if charType:lower() == answer_lowercase then
-- 					return charType
-- 				end
-- 			end
-- 			print('Invalid program name.') -- Only reached when we haven't returned.
-- 		end
-- 	elseif askType == "size" then
-- 		for size, _ in pairs(self.structure[self.charType]) do
-- 			if localStructure[self.charType] ~= nil and localStructure[self.charType][size] ~= nil then
-- 				term.write('  ')
-- 			else
-- 				term.write('! ')
-- 			end
-- 			local short = size:gsub('size_', '')
-- 			print(short)
-- 		end
		
-- 		print('\nEnter one of the above folder names:')
		
-- 		while true do
-- 			local answer_lowercase = read():lower()
-- 			for size, _ in pairs(self.structure[self.charType]) do
-- 				if size:gsub('size_', ''):lower() == answer_lowercase then
-- 					return size
-- 				end
-- 			end
-- 			print('Invalid program name.') -- Only reached when we haven't returned.
-- 		end
-- 	elseif askType == "file" then
-- 		for _, name in pairs(self.structure[self.charType][self.sizeFolder]) do
-- 			if localStructure[self.charType] ~= nil and localStructure[self.charType][self.sizeFolder] ~= nil and cf.valueInTable(localStructure[self.charType][self.sizeFolder], name) then
-- 				term.write('  ')
-- 			else
-- 				term.write('! ')
-- 			end
-- 			print(name)
-- 		end
		
-- 		print('\nEnter one of the above file names:')
		
-- 		while true do
-- 			local answer_lowercase = read():lower()
-- 			for _, name in pairs(self.structure[self.charType][self.sizeFolder]) do
-- 				if name:lower() == answer_lowercase then
-- 					return name
-- 				end
-- 			end
-- 			print('Invalid program name.') -- Only reached when we haven't returned.
-- 		end
-- 	end
-- end

-- function Animation:askCharType()
-- 	fs.makeDir(self.ascii_path)
-- 	self.charType = self:listOptions("charType")
-- 	cf.clearTerm()
-- end

-- function Animation:askFolder()
-- 	local pathCharType = cf.pathJoin(self.ascii_path, self.charType)
-- 	fs.makeDir(pathCharType)
-- 	self.sizeFolder = self:listOptions("size")
-- 	local _animationSize = cf.split(self.sizeFolder:gsub('size_', ''), 'x')
-- 	self.animationSize = { width = _animationSize[1], height = _animationSize[2] }
-- 	cf.clearTerm()
-- end

-- function Animation:askFile()
-- 	local pathSize = cf.pathJoin(self.ascii_path, self.charType, self.sizeFolder)
-- 	fs.makeDir(pathSize)
-- 	self.fileName = self:listOptions("file")
-- 	cf.clearTerm()
-- end

-- function Animation:printProgress(str, x, y)
-- 	-- If the BruteOS API is used, print the message at a different location.
-- 	if _BRUTEOS then
-- 		os.setMessage(str, 'NotUsingMenu');
-- 	else
-- 		if x and y then term.setCursorPos(x, y) end
-- 		print(str)
-- 	end
-- end

-- function Animation:downloadAnimationInfo(pathFile)
-- 	local size = 'size_' .. self.animationSize.width .. 'x' .. self.animationSize.height
-- 	local path = cf.pathJoin(self.charType, size, self.fileName, 'metadata.txt')
-- 	local str  = https.downloadAsciiSubfile(path)

-- 	fs.makeDir(pathFile)

-- 	local handle = io.open(cf.pathJoin(self.ascii_path, path), 'w')
-- 	handle:write(str)
-- 	handle:close()
	
-- 	self.metadata = textutils.unserialize(str)
-- end

-- function Animation:downloadAnimationFile(pathFile)
-- 	local cursorX, cursorY = term.getCursorPos()

-- 	if self.progressBool then
-- 		local str = 'Fetching animation file 1/' .. tostring(self.metadata.frame_files_count) .. ' from server. Calculating ETA...'
-- 		self:printProgress(str, cursorX, cursorY)
-- 	end

-- 	for i = 1, self.metadata.frame_files_count do
-- 		local timeStart = os.clock()

-- 		local pathData = cf.pathJoin(pathFile, 'data')
-- 		local fileName = tostring(i) .. '.txt'
-- 		local size     = 'size_' .. self.animationSize.width .. 'x' .. self.animationSize.height
-- 		local path     = cf.pathJoin(self.charType, size, self.fileName, 'data', fileName)

-- 		-- https.downloadAsciiSubfile(path, pathData, fileName)

-- 		local timeEnd = os.clock()

-- 		-- Print the ETA.
-- 		local filesLeft   = self.metadata.frame_files_count - i
-- 		local secondsLeft = (timeEnd - timeStart) * filesLeft
-- 		local seconds     = math.floor(secondsLeft % 60)
-- 		local minutes     = math.floor(secondsLeft / 60 % 60)
-- 		local hours       = math.floor(secondsLeft / 3600 % 60)

-- 		local eta = ' ( ' ..
-- 		(hours   < 10 and '0' or '') .. tostring(hours)   .. ':' ..
-- 		(minutes < 10 and '0' or '') .. tostring(minutes) .. ':' ..
-- 		(seconds < 10 and '0' or '') .. tostring(seconds) .. ' )'

-- 		if self.progressBool then
-- 			local str = 'Fetching animation file ' .. tostring(i < self.metadata.frame_files_count and i + 1 or i) .. '/' .. tostring(self.metadata.frame_files_count) .. ' from server.' .. eta .. '           '
-- 			self:printProgress(str, cursorX, cursorY)
-- 		end
-- 	end
-- end

-- function Animation:getInfo()
-- 	local size = 'size_' .. self.animationSize.width .. 'x' .. self.animationSize.height
-- 	local pathInfo = cf.pathJoin(self.ascii_path, self.charType, size, self.fileName, 'metadata.txt')
-- 	local str = fs.open(pathInfo, 'r').readAll()
-- 	self.metadata = textutils.unserialize(str)
-- end

-- function Animation:getSelectedAnimationData()
-- 	-- -- Create Timed Animations folder.
-- 	-- fs.makeDir(self.timed_ascii_path)

-- 	-- -- Create charType folder.
-- 	-- local pathTimedAnimationsCharType = cf.pathJoin(self.timed_ascii_path, self.charType)
-- 	-- fs.makeDir(pathTimedAnimationsCharType)
	
-- 	-- -- Create size folder.
-- 	-- local size = 'size_' .. self.animationSize.width .. 'x' .. self.animationSize.height
-- 	-- local pathTimedAnimationsSize = cf.pathJoin(pathTimedAnimationsCharType, size)
-- 	-- fs.makeDir(pathTimedAnimationsSize)

-- 	-- -- Create fileName folder.
-- 	-- local pathTimedAnimationsFile = cf.pathJoin(pathTimedAnimationsSize, self.fileName)
-- 	-- fs.makeDir(pathTimedAnimationsFile)

-- 	-- local pathAnimationsFile = cf.pathJoin(self.ascii_path, self.charType, size, self.fileName)

-- 	if not fs.exists(pathAnimationsFile) then			
-- 		-- self:downloadAnimationInfo(pathAnimationsFile)
-- 		self:downloadAnimationFile(pathAnimationsFile)
-- 	else
-- 		local str = fs.open(cf.pathJoin(pathAnimationsFile, 'metadata.txt'), 'r').readAll()
-- 		self.metadata = textutils.unserialize(str)
-- 	end

-- 	-- Create table of frame indices to sleep at.
-- 	local framesToSleep = {}
-- 	for v = 1, self.metadata.frame_count, self.frameSleepSkipping do
-- 		table.insert(framesToSleep, math.floor(v + 0.5))
-- 	end
-- 	local frameSleepSkippingIndex = 1

-- 	if self.progressBool then
-- 		self:printProgress('Opening data files...')
-- 	end

-- 	cf.tryYield() -- TODO: Try to remove.
	
-- 	local cursorX, cursorY = term.getCursorPos()
-- 	local i = 1

-- 	for dataFileIndex = 1, self.metadata.frame_files_count do
-- 		local dataWriteHandle = io.open(cf.pathJoin(pathTimedAnimationsFile, dataFileIndex), 'w')

-- 		local frameOffset = (dataFileIndex - 1) * self.maxFramesPerTimedAnimationFile

-- 		local frameCountToFile = math.min(self.metadata.frame_count - frameOffset, self.maxFramesPerTimedAnimationFile)

-- 		local strTable = {}
-- 		local k = 1

-- 		local dataReadHandle = fs.open(cf.pathJoin(pathAnimationsFile, 'data', dataFileIndex .. '.txt'), 'r')

-- 		local f = frameOffset + 1
-- 		for lineStr in dataReadHandle.readLine do
-- 			-- 'k > 1' prevents the first line of each generated code file being empty.
-- 			if k > 1 then
-- 				strTable[k] = '\n'
-- 				k = k + 1
-- 			end
			
-- 			strTable[k] = 'cf.frameWrite("'
-- 			k = k + 1
-- 			strTable[k] = lineStr
-- 			k = k + 1
-- 			strTable[k] = '",nil,nil'
-- 			k = k + 1

-- 			if f ~= self.metadata.frame_count and self.loop then
-- 				strTable[k] = ','
-- 				k = k + 1

-- 				-- TODO: framesToSleep[frameSleepSkippingIndex] might cause errors when trying to access stuff outside of the table's scope
-- 				if self.frameSleeping and self.frameSleep ~= -1 and f == framesToSleep[frameSleepSkippingIndex] then
-- 					frameSleepSkippingIndex = frameSleepSkippingIndex + 1

-- 					strTable[k] = tostring(self.frameSleep) -- TODO: May not need tostring().
-- 					k = k + 1
-- 				else
-- 					strTable[k] = "'tryYield'"
-- 					k = k + 1
-- 				end
-- 			end

-- 			strTable[k] = ')'
-- 			k = k + 1
			
-- 			if i % self.maxFramesPerTimedAnimationFile == 0 or i == self.metadata.frame_count then
-- 				cf.tryYield() -- TODO: Try to remove.
				
-- 				-- TODO: I don't remember why it's necessary to check this. Try removing this later.
-- 				local allAreStrings = true
-- 				for str in ipairs(strTable) do
-- 					if type(str) ~= 'string' then
-- 						allAreStrings = false
-- 					end
-- 				end
-- 				os.queueEvent('yield')
-- 				os.pullEvent('yield')

-- 				local str = table.concat(strTable)
-- 				os.queueEvent('yield')
-- 				os.pullEvent('yield')
				
-- 				-- I expect dataWriteHandle:write() to be an expensive operation,
-- 				-- so that's why I choose to only use it every N frames.
-- 				dataWriteHandle:write(str)
-- 				os.queueEvent('yield')
-- 				os.pullEvent('yield')

-- 				strTable = {}
-- 				k = 1

-- 				if self.progressBool then
-- 					local str = 'Generated '..tostring(i)..'/'..tostring(self.metadata.frame_count)..' frames...'
-- 					self:printProgress(str, cursorX, cursorY)
-- 				end
-- 			end
-- 			i = i + 1
-- 			f = f + 1
-- 		end
-- 		dataWriteHandle:close()
-- 		dataReadHandle:close()
-- 		cf.tryYield() -- TODO: Try to remove.
-- 	end
	
-- 	-- TODO: For the final frame. Refactor this away.
-- 	if self.progressBool then
-- 		self:printProgress('Generated ' .. tostring(self.metadata.frame_count) .. '/' .. tostring(self.metadata.frame_count) .. ' frames...', cursorX, cursorY)
-- 	end
-- end

-- function Animation:countdown()
-- 	local cursorX, cursorY = term.getCursorPos()

-- 	for i = 1, self.countdownTime do
-- 		self:printProgress('Playing animation in ' .. tostring(self.countdownTime - i + 1) .. '...', cursorX, cursorY)
-- 		sleep(1)
-- 	end
-- end

-- function Animation:createTimedAnimation()
-- 	local size = 'size_' .. self.animationSize.width .. 'x' .. self.animationSize.height
-- 	if not fs.exists(cf.pathJoin(self.timed_ascii_path, size, self.fileName)) then
-- 		self:getSelectedAnimationData()
-- 		cf.tryYield() -- TODO: Try to remove.
-- 	end
-- end

-- function Animation:_playAnimation(pathFile, len)
-- 	for i = 1, len do
-- 		if self.playAnimationBool then
-- 			self.shell.run(cf.pathJoin(pathFile, i))
-- 		end
-- 	end
-- 	cf.tryYield() -- TODO: Try to remove.
-- end

-- function Animation:playAnimation()
-- 	if self.progressBool then
-- 		if self.countdownTime > 0 then
-- 			self:countdown()
-- 		else
-- 			self:printProgress('Playing animation...')
-- 		end
-- 	end

-- 	local size = 'size_' .. self.animationSize.width .. 'x' .. self.animationSize.height
-- 	local pathFile = cf.pathJoin(self.timed_ascii_path, self.charType, size, self.fileName)
-- 	local len = #fs.list(pathFile)

-- 	term.setCursorPos(self.offset.x, self.offset.y)

-- 	-- Inits self.metadata.frame_count.
-- 	self:getInfo() -- TODO: Should be possible to call this method less often.

-- 	if self.loop and self.metadata.frame_count > 1 then
-- 		while true do
-- 			if self.playAnimationBool then
-- 				self:_playAnimation(pathFile, len)
-- 			else
-- 				sleep(1)
-- 			end
-- 		end
-- 	else
-- 		self:_playAnimation(pathFile, len)
-- 	end
-- end

-- function Animation:setOffset(x, y)
-- 	self.offset = { x = x, y = y }
-- end

-- function Animation:addOffset(x, y)
-- 	self:setOffset(self.offset.x + x, self.offset.y + y)
-- end

-- function Animation:setCharCodeOffset(x_8, y_8)
-- 	self:setOffset(1 + x_8 * 8, 1 + y_8 * 8)
-- end

-- function Animation:addCharCodeOffset(x_8, y_8)
-- 	self:addOffset(x_8 * 8, y_8 * 8)
-- end

-- function Animation:writeCharCode(charCode, xCharOff, yCharOff)
-- 	-- TODO: Fix these comparisons, because only 94 characters are available (in Tekkit Classic).
-- 	local validCharCode = charCode >= 1 and charCode <= 256

-- 	local x = self.offset.x
-- 	local y = self.offset.y

-- 	local xCharOffNew = xCharOff or 1
-- 	local yCharOffNew = yCharOff or 0
-- 	local xNew = x + xCharOffNew * 8
-- 	local yNew = y + yCharOffNew * 8

-- 	local inCanvasNew = xNew >= 1 and yNew >= 1 and xNew <= self.screen_width and yNew <= self.screen_height
	
-- 	if validCharCode and inCanvasNew then
-- 		self:addCharCodeOffset(xCharOffNew, yCharOffNew)

-- 		self.fileName = 'char_' .. tostring(charCode)

-- 		self:createTimedAnimation()
-- 		self:playAnimation()
-- 	end
-- end