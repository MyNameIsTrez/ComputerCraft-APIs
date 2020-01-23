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

	new = function(canvasWidth, canvasHeight, firstPersonWidth, boundaryCount, rayCount, boundaryChar, rayChar, raycasterChar, framebuffer)
        local self = {
			canvasWidth = canvasWidth,
			canvasHeight = canvasHeight,
			firstPersonWidth = firstPersonWidth,
			boundaryCount = boundaryCount,
			rayCount = rayCount,
			boundaryChar = boundaryChar,
			rayChar = rayChar,
			raycasterChar = raycasterChar,
			framebuffer = framebuffer,
			
			boundaries = {},
			rayCasters = {},
			noiseX = 0,
			noiseY = 10000,
			scene = {},
            chars = {'@', '#', '0', 'A', '5', '2', '$', '3', 'C', '1', '%', '=', '(', '/', '!', '-', ':', "'", '.'},
			maxRayLength = math.sqrt(canvasWidth^2 + canvasHeight^2),
		}
		
		setmetatable(self, {__index = RayCasting})
		
		self:createBoundaries()
		self:createRayCasters()
		
		return self
    end,
	
	createBoundaries = function(self)
		for i = 1, self.boundaryCount do
			local pos1 = vector.new(math.random(self.canvasWidth), math.random(self.canvasHeight))
			local pos2 = vector.new(math.random(self.canvasWidth), math.random(self.canvasHeight))
			self.boundaries[#self.boundaries + 1] = Boundary.new(pos1, pos2, self.boundaryChar, self.framebuffer)
		end
		
		pos1 = vector.new(1, 1)
		pos2 = vector.new(self.canvasWidth, 1)
		self.boundaries[#self.boundaries + 1] = Boundary.new(pos1, pos2, self.boundaryChar, self.framebuffer)
		pos1 = vector.new(self.canvasWidth, 1)
		pos2 = vector.new(self.canvasWidth, self.canvasHeight)
		self.boundaries[#self.boundaries + 1] = Boundary.new(pos1, pos2, self.boundaryChar, self.framebuffer)
		pos1 = vector.new(self.canvasWidth, self.canvasHeight)
		pos2 = vector.new(1, self.canvasHeight)
		self.boundaries[#self.boundaries + 1] = Boundary.new(pos1, pos2, self.boundaryChar, self.framebuffer)
		pos1 = vector.new(1, self.canvasHeight)
		pos2 = vector.new(1, 1)
		self.boundaries[#self.boundaries + 1] = Boundary.new(pos1, pos2, self.boundaryChar, self.framebuffer)
	end,
	
	createRayCasters = function(self)
		local pos = vector.new(math.random(self.canvasWidth), math.random(self.canvasHeight))
		self.rayCasters[#self.rayCasters + 1] = RayCaster.new(pos, self.rayCount, self.raycasterChar, self.framebuffer)
	end,
	
	castRays = function(self)
		for _, rayCaster in ipairs(self.rayCasters) do
			for i = 1, #rayCaster.rays do
				local ray = rayCaster.rays[i]
				local shortestDist = math.huge
				local closestPt
				for _, boundary in ipairs(self.boundaries) do
					local pt = ray:cast(boundary)
					if pt then
						local dist = math.sqrt((rayCaster.pos.x - pt.x)^2 + (rayCaster.pos.y - pt.y)^2)
						if dist < shortestDist then
							shortestDist = dist
							closestPt = pt
						end
					end
				end
				if closestPt then
					self.framebuffer:writeLine(rayCaster.pos.x, rayCaster.pos.y, closestPt.x, closestPt.y, self.rayChar)
				end
				self.scene[i] = shortestDist
			end
		end
	end,
	
	moveRayCasters = function(self)
		self.noiseX = self.noiseX + 0.05
		self.noiseY = self.noiseY + 0.05
		local x = (pn.perlin:noise(self.noiseX)+1)/2 * self.canvasWidth
		local y = (pn.perlin:noise(self.noiseY)+1)/2 * self.canvasHeight
		local newPos = vector.new(x, y)
		self.rayCasters[1].pos = newPos
		self.rayCasters[1]:moveRays(newPos)
	end,
	
	drawFirstPerson = function(self)
		local w = self.firstPersonWidth / #self.scene
		for i = 1, #self.scene do
			local x1 = self.canvasWidth+i*w-w+2
			local y1 = 1
			local x2 = self.canvasWidth+i*w+2
			local y2 = self.canvasHeight
			local char = self.chars[math.floor(self.scene[i]/self.maxRayLength*#self.chars + 0.5)]
			self.framebuffer:writeRect(x1, y1, x2, y2, char, true)
		end
	end,
	
}

Boundary = {

	new = function(pos1, pos2, char, framebuffer)
        local self = {
			pos1 = pos1,
			pos2 = pos2,
			char = char,
			framebuffer = framebuffer,
		}
		
		setmetatable(self, {__index = Boundary})
		
		return self
    end,
	
	draw = function(self)
		self.framebuffer:writeLine(self.pos1.x, self.pos1.y, self.pos2.x, self.pos2.y, self.char)
	end,

}

Ray = {

	new = function(pos, dir)
        local self = {
			pos = pos,
			dir = dir,
		}
		
		setmetatable(self, {__index = Ray})
		
		return self
    end,
	
	cast = function(self, boundary)
		-- https://en.wikipedia.org/wiki/Line%E2%80%93line_intersection
		local x1, y1, x2, y2 = boundary.pos1.x, boundary.pos1.y, boundary.pos2.x, boundary.pos2.y
		local x3, y3, x4, y4 = self.pos.x, self.pos.y, self.pos.x + self.dir.x, self.pos.y + self.dir.y
		
		local den = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4)
		if den == 0 then return end -- ray and boundary are parallel
		
		local t = ((x1 - x3) * (y3 - y4) - (y1 - y3) * (x3 - x4)) / den
		local u = -((x1 - x2) * (y1 - y3) - (y1 - y2) * (x1 - x3)) / den
		
		if t > 0 and t < 1 and u > 0 then
			local x = x1 + t * (x2 - x1)
			local y = y1 + t * (y2 - y1)
			return vector.new(x, y)
		else
			return
		end
	end,
	
	lookAt = function(self, pos)
		self.dir = pos:sub(self.pos):normalize()
	end,

}

RayCaster = {

	new = function(pos, rayCount, char, framebuffer)
        local self = {
			pos = pos,
			rayCount = rayCount,
			char = char,
			framebuffer = framebuffer,
			
			pi2 = math.pi * 2,
			rays = {},
		}
		
		setmetatable(self, {__index = RayCaster})
		
		self:createRays()
		
		return self
    end,
	
	createRays = function(self)
		for angle = 0, self.pi2 / 9, (self.pi2 / 9) / self.rayCount do
			local dir = vector.new(math.cos(angle), math.sin(angle))
			self.rays[#self.rays + 1] = Ray.new(self.pos, dir)
		end
	end,
	
	moveRays = function(self, pos)
		for _, ray in ipairs(self.rays) do
			ray.pos = pos
		end
	end,
	
	draw = function(self)
		self.framebuffer:writeChar(self.pos.x, self.pos.y, self.char)
	end,

}