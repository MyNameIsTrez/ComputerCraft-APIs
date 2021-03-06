--[[
API that holds a giant 2D table, that can get drawn to the screen with one write() call.
Intended to prevent programs slowing down by drawing a bunch of characters with the same coordinates in a single frame.
]]--


-- Class table
FrameBuffer = {}

-- Constructor
function FrameBuffer:new(settings)
	setmetatable({}, FrameBuffer)

	-- Passed settings.
	self.startX       = settings.startX
	self.startY       = settings.startY
	self.canvasWidth  = settings.canvasWidth
	self.canvasHeight = settings.canvasHeight

	self.buffer = {}

	self:createBuffer(settings.canvasWidth, settings.canvasHeight)
	
	return self
end

function FrameBuffer:createBuffer(canvasWidth, canvasHeight)
	for y = 1, canvasHeight do
		self.buffer[y] = {}
		for x = 1, canvasWidth do
			self.buffer[y][x] = ' '
		end
	end
end

function FrameBuffer:resetBuffer()
	local bufferCopy = self.buffer
	for y = 1, self.canvasHeight do
		for x = 1, self.canvasWidth do
			if bufferCopy[y][x] ~= ' ' then
				bufferCopy[y][x] = ' '
			end
		end
	end
	self.buffer = bufferCopy
end

function FrameBuffer:writeChar(x, y, char)
	local x, y = math.floor(x + 0.5), math.floor(y + 0.5)

	-- Might need <= instead of <
	if y >= self.startY and y < self.canvasHeight + self.startY and x >= self.startX and x < self.canvasWidth + self.startX then
		self.buffer[y][x] = char
	end
end

function FrameBuffer:writeLine(x1, y1, x2, y2, char, exact)
	local x_diff = x2 - x1
	local y_diff = y2 - y1
	
	local distance = math.sqrt(x_diff^2 + y_diff^2)
	local step_x = x_diff / distance
	local step_y = y_diff / distance
	
	for i = 0, distance do
		local _x = i * step_x
		local _y = i * step_y
		local x = x1 + _x
		local y = y1 + _y
		self:writeChar(x, y, char)
	end

	if not exact then
		self:writeChar(x2, y2, char)
	end
end

function FrameBuffer:writeRect(x1, y1, x2, y2, char, fill)
	local fill = fill or true and false -- false by default.
	local x_diff = x2 - x1
	if fill then
		for i = 0, x_diff do
			local x = x1 + i
			self:writeLine(x, y1, x, y2, char)
		end
	else
		error('writeRect() misses code for filling the rectangle')
	end
end

function FrameBuffer:draw()
	-- Draw the current frame.
	strTab = {}
	for y = 1, self.canvasHeight do
		strTab[#strTab + 1] = table.concat(self.buffer[y])
		if y ~= self.canvasHeight then
			strTab[#strTab + 1] = '\n' -- Maybe concating above instead is faster?
		end
	end
	term.setCursorPos(self.startX, self.startY)
	write(table.concat(strTab))

	-- Clear the buffer.
	-- Maybe faster to copy an empty table instead, but I think that needs recursion.
	self:resetBuffer()
end