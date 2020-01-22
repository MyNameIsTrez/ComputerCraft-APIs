--------------------------------------------------
-- README


--[[

API that holds a giant 2D table, that can get drawn to the screen with one write() call.
Intended to prevent programs slowing down by drawing a bunch of characters with the same coordinates in a single frame.

REQUIREMENTS
	* None

]]--


--------------------------------------------------
-- CLASSES


FrameBuffer = {

	new = function(startX, startY, canvasWidth, canvasHeight)
        local self = {
			startX = startX,
			startY = startY,
			canvasWidth = canvasWidth,
			canvasHeight = canvasHeight,
			buffer = {},
		}
		
		setmetatable(self, {__index = FrameBuffer})
		
		self:createBuffer(canvasWidth, canvasHeight)
		
		return self
    end,
	
	createBuffer = function(self, canvasWidth, canvasHeight)
		for y = 1, canvasHeight do
			self.buffer[y] = {}
			for x = 1, canvasWidth do
				self.buffer[y][x] = ' '
			end
		end
	end,
	
	resetBuffer = function(self)
		local bufferCopy = self.buffer
		for y = 1, self.canvasHeight do
			for x = 1, self.canvasWidth do
				if bufferCopy[y][x] ~= ' ' then
					bufferCopy[y][x] = ' '
				end
			end
		end
		self.buffer = bufferCopy
	end,
	
	writeChar = function(self, x, y, char)
        -- Might need < instead of <= .
        if y > self.startY and y <= self.canvasHeight + self.startY and x > self.startX and x <= self.canvasWidth + self.startX then
            self.buffer[y][x] = char
        end
    end,
	
	writeLine = function(self, x1, y1, x2, y2, char)
  		local x_diff = x2 - x1
  		local y_diff = y2 - y1
		
  		local distance = math.sqrt(x_diff^2 + y_diff^2)
  		local step_x = x_diff / distance
  		local step_y = y_diff / distance
		
  		for i = 0, distance do
    		local x = i * step_x
    		local y = i * step_y
			self:writeChar(math.floor(x1 + x + 0.5), math.floor(y1 + y + 0.5), char)
  		end
	end,
	
	draw = function(self)		
		-- Draw the current frame.
		strTab = {}
		for y = 1, self.canvasHeight do
			strTab[#strTab + 1] = table.concat(self.buffer[y])
			strTab[#strTab + 1] = '\n' -- Maybe concating above instead is faster?
		end
		term.setCursorPos(self.startX, self.startY)
		write(table.concat(strTab))

		-- Clear the buffer.
		-- Maybe faster to copy an empty table instead, but I think that needs recursion.
		self:resetBuffer()
	end,

}