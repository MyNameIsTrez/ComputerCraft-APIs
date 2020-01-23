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

	new = function(canvasWidth, canvasHeight, firstPersonWidth, boundaryCount, rayCount, fov, rotationSpeed, boundaryChar, rayChar, raycasterChar, framebuffer)
        local self = {
			canvasWidth = canvasWidth,
			canvasHeight = canvasHeight,
			firstPersonWidth = firstPersonWidth,
			boundaryCount = boundaryCount,
			rayCount = rayCount,
			fov = fov, -- field of view
			rotationSpeed = rotationSpeed,
			boundaryChar = boundaryChar,
			rayChar = rayChar,
			raycasterChar = raycasterChar,
			framebuffer = framebuffer,
			
			boundaries = {},
			raycasters = {},
			noiseX = 0,
			noiseY = 10000,
			scene = {},
            chars = {'@', '#', '0', 'A', '5', '2', '$', '3', 'C', '1', '%', '=', '(', '/', '!', '-', ':', "'", '.'},
			maxRayLength = math.sqrt(canvasWidth^2 + canvasHeight^2),
		}
		
		setmetatable(self, {__index = RayCasting})
		
		self:createBoundaries()
		self:createRaycasters()
		
		return self
    end,
	
	createBoundaries = function(self)
		for i = 1, self.boundaryCount do
			local pos1 = vector.new(math.random(self.canvasWidth), math.random(self.canvasHeight))
			local pos2 = vector.new(math.random(self.canvasWidth), math.random(self.canvasHeight))
			self.boundaries[#self.boundaries + 1] = Boundary.new(pos1, pos2, self.boundaryChar, self.framebuffer)
		end
		
		----[[ optional walls on the sides of the top-down view
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
		--]]--
	end,
	
	createRaycasters = function(self)
		local pos = vector.new(math.random(self.canvasWidth), math.random(self.canvasHeight))
		self.raycasters[#self.raycasters + 1] = RayCaster.new(pos, self.rayCount, self.raycasterChar, self.fov, self.framebuffer)
	end,
	
	castRays = function(self)
		for _, rayCaster in ipairs(self.raycasters) do
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
	
	moveRaycasters = function(self, key)
		local raycaster = self.raycasters[1]
		
		local stepX, stepY = 0, 0
    	if (key == 'w' and raycaster.pos.y > 2) then
        	stepY = -1
    	elseif (key == 's' and raycaster.pos.y < self.canvasHeight - 1) then
        	stepY = 1
		elseif (key == 'a' and raycaster.pos.x > 2) then
        	stepX = -1
    	elseif (key == 'd' and raycaster.pos.x < self.canvasWidth - 1) then
        	stepX = 1
    	end
		
		local newPos = vector.new(raycaster.pos.x + stepX, raycaster.pos.y + stepY)
		raycaster.pos = newPos
		raycaster:moveRays(newPos)
	end,
	
	rotateRaycasters = function(self, key)
		local raycaster = self.raycasters[1]
    	if (key == 'left') then
        	raycaster:rotate(-self.rotationSpeed)
    	elseif (key == 'right') then
        	raycaster:rotate(self.rotationSpeed)
    	end
	end,
	
	map = function(self, value, minVar, maxVar, minResult, maxResult)
    	local a = (value - minVar) / (maxVar - minVar)
    	return (1 - a) * minResult + a * maxResult;
	end,
	
	drawFirstPerson = function(self)
		local w = self.firstPersonWidth / #self.scene
		for i = 1, #self.scene do
			local h = self:map(self.scene[i], 0, self.maxRayLength, self.canvasHeight/2, 0)
			
			local x1 = self.canvasWidth+i*w-w+2
			local y1 = self.canvasHeight/2 - h + 1
			local x2 = self.canvasWidth+i*w+2
			local y2 = self.canvasHeight/2 + h
			
			local sceneSq = self.scene[i]^2
			local firstPersonWidthSq = self.firstPersonWidth^2
			
			-- Uses inverse square law to fix the fisheye effect.
			local b = self:map(sceneSq, 0, firstPersonWidthSq, 1, 19)
			
			local char = self.chars[math.floor(b + 0.5)]
			if math.floor(b + 0.5) > #self.chars then
				char = ' '
			elseif not char then -- Maybe not necessary anymore?
				char = self.chars[1]
			end
			
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

	new = function(pos, angle)
        local self = {
			pos = pos,
			dir,
		}
		
		setmetatable(self, {__index = Ray})
		
		self:setDir(angle)
		
		return self
    end,
	
	setDir = function(self, angle)
		self.dir = vector.new(math.cos(angle), math.sin(angle))
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

	new = function(pos, rayCount, char, fov, framebuffer)
        local self = {
			pos = pos,
			rayCount = rayCount,
			char = char,
			fov = fov,
			framebuffer = framebuffer,
			
			rays = {},
			heading = 0,
		}
		
		setmetatable(self, {__index = RayCaster})
		
		self:createRays()
		
		return self
    end,
	
	createRays = function(self)
		for angle = -self.fov/2, self.fov/2, self.fov/self.rayCount do
			self.rays[#self.rays + 1] = Ray.new(self.pos, angle)
		end
	end,
	
	moveRays = function(self, pos)
		for _, ray in ipairs(self.rays) do
			ray.pos = pos
		end
	end,
	
	rotate = function(self, angle)
		self.heading = self.heading + angle
		local index = 1
		for angle = -self.fov/2, self.fov/2, self.fov/self.rayCount do
			self.rays[index]:setDir(angle + self.heading)
			index = index + 1
		end
	end,
	
	draw = function(self)
		self.framebuffer:writeChar(self.pos.x, self.pos.y, self.char)
	end,

}