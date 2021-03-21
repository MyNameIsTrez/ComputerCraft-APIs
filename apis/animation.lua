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

	self.path                           = settings.path
	self.shell                          = settings.shell
	self.frameSleeping                  = settings.frameSleeping
	self.frameSleep                     = settings.frameSleep
	self.frameSleepSkipping             = settings.frameSleepSkipping
	self.maxFramesPerTimedAnimationFile = settings.maxFramesPerTimedAnimationFile
	self.progressBool                   = settings.progressBool
	self.loop                           = settings.loop
	self.countdownTime                  = settings.countdownTime
	self.offset                         = settings.offset
	self.playAnimationBool = settings.playAnimationBool
	-- self. = settings.

	self:_init_paths()
	self:_init_database()
	self:_get_metadata()
	
	return self
end

function Animation:_init_paths()
	self.ascii_path       = cf.pathJoin(self.path, "ascii-content")
	self.timed_ascii_path = cf.pathJoin(self.path, "timed-ascii-content")
end

function Animation:_init_database()
	self.database = database.Database:new({path=self.path, name="metadata"}) 
end

function Animation:_get_metadata()
	self.metadata = {}

	local local_metadata = self.database:find()

	for _, document in ipairs(local_metadata) do
		document.downloaded = true
		table.insert(self.metadata, document)
	end

	for _, document in ipairs(online_storage.get_metadata()) do
		local already_downloaded = false
		for _, local_document in ipairs(local_metadata) do
			if document._id == local_document._id then
				already_downloaded = true
			end
		end
		if not already_downloaded then
			document.downloaded = false
			table.insert(self.metadata, document)
		end
	end
end

function Animation:choose_document()
	for _, document in ipairs(self.metadata) do
		print(string.format("%s | %s", document.downloaded and " " or "!", document.displayed_name))
	end
	print("\nEnter a 'displayed_name':")
	while true do
		local answer_lowercase = read():lower()
		for _, document in pairs(self.metadata) do
			if document.displayed_name:lower() == answer_lowercase then
				self.document = document
				self.document_path = cf.pathJoin(self.ascii_path, self.document._id)
				self.timed_document_path = cf.pathJoin(self.timed_ascii_path, self.document._id)

				if not fs.exists(self.document_path) then self:_download_subfiles() end
				self:_create_timed_subfiles()

				return
			end
		end
		print("\nInvalid 'displayed_name', try again:")
	end
end

function Animation:_download_subfiles()
	local cursorX, cursorY = term.getCursorPos()
	if self.progressBool then
		local str = "Fetching animation file 1/" .. tostring(self.document.frame_files_count) .. " from server. Calculating ETA..."
		self:_print_status(str, cursorX, cursorY)
	end

	fs.makeDir(self.document_path)

	for subfile_id = 1, self.document.frame_files_count do
		local time_start = os.clock()
		local handle = fs.open(cf.pathJoin(self.document_path, subfile_id), "w")
		handle.write(online_storage.get_ascii_subfile(self.document._id, subfile_id))
		handle.close()
		local time_end = os.clock()

		local files_left   = self.document.frame_files_count - subfile_id
		local seconds_left = (time_end - time_start) * files_left
		local seconds     = math.floor(seconds_left % 60)
		local minutes     = math.floor(seconds_left / 60 % 60)
		local hours       = math.floor(seconds_left / 3600 % 60)

		local eta = " ( " ..
		(hours   < 10 and "0" or "") .. tostring(hours)   .. ":" ..
		(minutes < 10 and "0" or "") .. tostring(minutes) .. ":" ..
		(seconds < 10 and "0" or "") .. tostring(seconds) .. " )"

		if self.progressBool then
			local str = "Fetching animation file " .. tostring(subfile_id < self.document.frame_files_count and subfile_id + 1 or subfile_id) .. "/" .. tostring(self.document.frame_files_count) .. " from server." .. eta .. "           "
			self:_print_status(str, cursorX, cursorY)
		end
	end

	self.database:insert(self.document)
end

function Animation:_create_timed_subfiles()
	fs.makeDir(self.timed_document_path)

	-- Create table of frame indices to sleep at.
	local framesToSleep = {}
	for v = 1, self.document.frame_count, self.frameSleepSkipping do
		table.insert(framesToSleep, math.floor(v + 0.5))
	end
	local frameSleepSkippingIndex = 1

	if self.progressBool then
		self:_print_status("Opening data files...")
	end

	cf.tryYield() -- TODO: Try to remove.
	
	local cursorX, cursorY = term.getCursorPos()
	local i = 1

	for subfile_id = 1, self.document.frame_files_count do
		local dataWriteHandle = fs.open(cf.pathJoin(self.timed_document_path, subfile_id), "w")

		local frameOffset = (subfile_id - 1) * self.maxFramesPerTimedAnimationFile

		local frameCountToFile = math.min(self.document.frame_count - frameOffset, self.maxFramesPerTimedAnimationFile)

		local strTable = {}
		local k = 1

		local dataReadHandle = fs.open(cf.pathJoin(self.document_path, subfile_id), "r")

		local f = frameOffset + 1
		for line_str in dataReadHandle.readLine do
			-- "k > 1" prevents the first line of each generated code file being empty.
			if k > 1 then
				strTable[k] = "\n"
				k = k + 1
			end
			
			-- line_str can contain a ' character
			strTable[k] = 'cf.frameWrite("'
			k = k + 1
			strTable[k] = line_str
			k = k + 1
			strTable[k] = '",nil,nil'
			k = k + 1

			if f ~= self.document.frame_count and self.loop then
				strTable[k] = ","
				k = k + 1

				-- TODO: framesToSleep[frameSleepSkippingIndex] might cause errors when trying to access stuff outside of the table's scope
				if self.frameSleeping and self.frameSleep ~= -1 and f == framesToSleep[frameSleepSkippingIndex] then
					frameSleepSkippingIndex = frameSleepSkippingIndex + 1

					strTable[k] = tostring(self.frameSleep) -- TODO: May not need tostring().
					k = k + 1
				else
					strTable[k] = "'tryYield'"
					k = k + 1
				end
			end

			strTable[k] = ")"
			k = k + 1

			if i % self.maxFramesPerTimedAnimationFile == 0 or i == self.document.frame_count then
				cf.tryYield() -- TODO: Try to remove.
				
				-- TODO: I don't remember why it's necessary to check this. Try removing this later.
				local allAreStrings = true
				for str in ipairs(strTable) do
					if type(str) ~= "string" then
						allAreStrings = false
					end
				end
				os.queueEvent("yield")
				os.pullEvent("yield")

				local str = table.concat(strTable)
				os.queueEvent("yield")
				os.pullEvent("yield")
				
				-- I expect dataWriteHandle.write() to be an expensive operation,
				-- so that's why I choose to only call it every N frames.
				dataWriteHandle.write(str)
				os.queueEvent("yield")
				os.pullEvent("yield")

				strTable = {}
				k = 1

				if self.progressBool then
					local str = "Generated "..tostring(i).."/"..tostring(self.document.frame_count).." frames..."
					self:_print_status(str, cursorX, cursorY)
				end
			end
			i = i + 1
			f = f + 1
		end
		dataWriteHandle.close()
		dataReadHandle.close()
		cf.tryYield() -- TODO: Try to remove.
	end
	
	-- TODO: For the final frame. Refactor this away.
	if self.progressBool then
		self:_print_status("Generated " .. tostring(self.document.frame_count) .. "/" .. tostring(self.document.frame_count) .. " frames...", cursorX, cursorY)
	end
end

function Animation:_print_status(str, x, y)
	if x and y then term.setCursorPos(x, y) end
	print(str)
end

function Animation:play_animation()
	if self.progressBool then
		if self.countdownTime > 0 then
			self:_countdown()
		else
			self:_print_status("Playing animation...")
		end
	end

	term.setCursorPos(self.offset.x, self.offset.y)
	local len = #fs.list(self.timed_document_path)
	if self.loop and self.document.frame_count > 1 then
		while true do
			if self.playAnimationBool then
				self:_playAnimation(len)
			else
				sleep(1)
			end
		end
	else
		self:_playAnimation(len)
	end
end

function Animation:_countdown()
	local cursorX, cursorY = term.getCursorPos()
	for i = 1, self.countdownTime do
		self:_print_status("Playing animation in " .. tostring(self.countdownTime - i + 1) .. "...", cursorX, cursorY)
		sleep(1)
	end
end

function Animation:_playAnimation(len)
	for subfile_id = 1, len do
		if self.playAnimationBool then
			self.shell.run(cf.pathJoin(self.timed_document_path, subfile_id))
		end
	end
	cf.tryYield() -- TODO: Try to remove.
end

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

-- 		self.fileName = "char_" .. tostring(charCode)

-- 		self:_create_timed_subfiles()
-- 		self:play_animation()
-- 	end
-- end
