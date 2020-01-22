--------------------------------------------------
-- README


--[[

Raycasting API.

REQUIREMENTS
	* None

]]--


--------------------------------------------------
-- CLASSES


RayCasting = {

	new = function(canvasWidth, canvasHeight)
        local self = {
			canvasWidth = canvasWidth,
			canvasHeight = canvasHeight,
		}
		
		setmetatable(self, {__index = RayCasting})
		
		return self
    end,
	
	createRays = function(self)
		print(1)
	end,

}

Boundary = {

	new = function(x1, y1, x2, y2, char, framebuffer)
        local self = {
			x1 = x1,
			y1 = y1,
			x2 = x2,
			y2 = y2,
			char = char,
			framebuffer = framebuffer,
		}
		
		setmetatable(self, {__index = Boundary})
		
		return self
    end,
	
	draw = function(self)
		self.framebuffer:writeLine(self.x1, self.y1, self.x2, self.y2, self.char)
	end,

}

Ray = {

	new = function(x, y, char, framebuffer)
        local self = {
			x = x,
			y = y,
			char = char,
			dir = vector.new(1, 0),
			framebuffer = framebuffer,
		}
		
		setmetatable(self, {__index = Ray})
		
		return self
    end,
	
	draw = function(self)
		self.framebuffer:writeLine(self.x, self.y, self.x + self.dir.x * 10, self.y + self.dir.y * 10, self.char)
	end,

}