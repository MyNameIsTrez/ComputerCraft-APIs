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

	new = function(canvasWidth, canvasHeight, boundaryChar, rayChar, framebuffer)
        local self = {
			canvasWidth = canvasWidth,
			canvasHeight = canvasHeight,
			boundaryChar = boundaryChar,
			rayChar = rayChar,
			framebuffer = framebuffer,
			
			boundaries = {},
			rays = {},
		}
		
		setmetatable(self, {__index = RayCasting})
		
		self:createBoundaries()
		self:createRays()
		
		return self
    end,
	
	createBoundaries = function(self)
		local x1, y1, x2, y2 = self.canvasWidth/4*3, self.canvasHeight/10, self.canvasWidth/4*3, self.canvasHeight/10*9
		self.boundaries[#self.boundaries + 1] = Boundary.new(x1, y1, x2, y2, self.boundaryChar, self.framebuffer)
	end,
	
	createRays = function(self)
		self.rays[#self.rays + 1] = Ray.new(self.canvasWidth/4, self.canvasHeight/2, self.rayChar, self.framebuffer)
	end,
	
	castRays = function(self)
		for _, ray in ipairs(self.rays) do
			for _, boundary in ipairs(self.boundaries) do
				ray:cast(boundary)
			end
		end
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
			framebuffer = framebuffer,
			
			dir = vector.new(1, 0),
		}
		
		setmetatable(self, {__index = Ray})
		
		return self
    end,
	
	draw = function(self)
		self.framebuffer:writeLine(self.x, self.y, self.x + self.dir.x * 10, self.y + self.dir.y * 10, self.char)
	end,
	
	cast = function(self, boundary)
		print(1)
	end,

}