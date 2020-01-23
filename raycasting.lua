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
		self.rays[#self.rays + 1] = Ray.new(self.canvasWidth/4, self.canvasHeight/2, 1, 1, self.rayChar, self.framebuffer)
	end,
	
	castRays = function(self)
		for _, ray in ipairs(self.rays) do
			for _, boundary in ipairs(self.boundaries) do
				local pt = ray:cast(boundary)
				term.setCursorPos(50, 50)
				write(tostring(pt))
				--if pt then
				--	self.framebuffer:writeChar(pt.x, pt.y, 'H')
				--end
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

	new = function(x, y, dirX, dirY, char, framebuffer)
        local self = {
			x = x,
			y = y,
			char = char,
			framebuffer = framebuffer,
			
			dirX = dirX,
			dirY = dirY,
		}
		
		setmetatable(self, {__index = Ray})
		
		return self
    end,
	
	draw = function(self)
		self.framebuffer:writeLine(self.x, self.y, self.x + self.dirX * 10, self.y + self.dirY * 10, self.char)
	end,
	
	cast = function(self, boundary)
		-- https://en.wikipedia.org/wiki/Line%E2%80%93line_intersection
		local x1, y1, x2, y2 = boundary.x1, boundary.y1, boundary.x2, boundary.y2
		local x3, y3, x4, y4 = self.x, self.y, self.x + self.dirX, self.y + self.dirY
		
		local den = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4)
		if den == 0 then return end -- ray and boundary are parallel
		
		local t = ((x1 - x3) * (y3 - y4) - (y1 - y3) * (x3 - x4)) / den
		local u = -((x1 - x2) * (y1 - y3) - (y1 - y2) * (x1 - x3)) / den
		
		if t > 0 and t < 1 and u > 0 then
			return true
		else
			return
		end
	end,

}