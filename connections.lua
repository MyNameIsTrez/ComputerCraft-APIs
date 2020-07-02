-- Based on my 'Connections' P5.js program:
-- https://editor.p5js.org/MyNameIsTrez/sketches/MqnvoTzC


-- Class table
Connections = {}

-- Constructor
function Connections:new(s) -- 's' stands for 'settings'
	setmetatable({}, Connections)

	local screenPixelCountSqrt = math.sqrt(s.size.width, s.size.height)

	-- Passed settings.
	self.offset = s.offset
	self.size   = s.size

	self.pointCountMult            = s.pointCountMult
	self.maxConnectionDistMult     = s.maxConnectionDistMult
	self.connectionWeightAlphaMult = s.connectionWeightAlphaMult
	self.maxFPS                    = s.maxFPS
	self.pointMinVel               = s.pointMinVel
	self.pointMaxVel               = s.pointMaxVel

	-- Extra.
	self.screenPixelCountSqrt = screenPixelCountSqrt
	self.pointCount           = math.floor(screenPixelCountSqrt * s.pointCountMult)
	-- '0.25' shouldn't be hardcoded here in the future.
	self.maxConnectionDist    = math.floor(s.maxConnectionDistMult * math.pow(screenPixelCountSqrt, 0.25))

	self.points = {}

	-- The '- 1' is necessary for the '\n' character at the end of each line.
	-- Not sure if this is the best place to put the '- 1', though.
	self.framebuffer = fb.FrameBuffer:new({
		startX = s.offset.x,
		startY = s.offset.y,
		canvasWidth = s.size.width - 1,
		canvasHeight = s.size.height
	})

	self:generatePoints()
	
	return self
end

function Connections:generatePoints()
	for index = 1, self.pointCount do
		local x = math.random(self.size.width)
		local y = math.random(self.size.height)
		table.insert(self.points, Point:new({
			index = index,
			x = x,
			y = y,
			pointMinVel = self.pointMinVel,
			pointMaxVel = self.pointMaxVel
		}))
	end
end

function Connections:show()
	for _, point in ipairs(self.points) do
		point:move(self.maxConnectionDist, self.size.width, self.size.height)
		point.connections = {}
	end

	for _, point in ipairs(self.points) do
		point:generateConnections(self.pointCount, self.points, self.maxConnectionDist)
		point:showConnections(self.points, self.maxConnectionDist, self.connectionWeightAlphaMult, self.framebuffer)
	end

	self.framebuffer:draw()
end


-- Class table
Point = {}

-- Constructor
function Point:new(settings)
	setmetatable({}, Point)

	-- Passed settings.
	self.index       = settings.index
	self.pos         = vector.new(settings.x, settings.y)
	self.vel         = cf.vectorRandom2D():mul(math.random(settings.pointMinVel, settings.pointMaxVel))
	self.connections = {}
	
	return self
end

function Point:move(maxConnectionDist, width, height)
	self.pos = self.pos:add(self.vel) -- Can be optimized, as it rn makes a new vector here.

	-- Keeps points inside of the canvas bounds.
	if self.pos.x < -maxConnectionDist then
		self.pos.x = width + maxConnectionDist
	elseif self.pos.x > width + maxConnectionDist then
		self.pos.x = -maxConnectionDist
	end

	if self.pos.y < -maxConnectionDist then
		self.pos.y = height + maxConnectionDist
	elseif self.pos.y > height + maxConnectionDist then
		self.pos.y = -maxConnectionDist
	end
end

function Point:generateConnections(pointCount, points, maxConnectionDist)
	for otherIndex = 1, pointCount do
		local other = points[otherIndex]

		-- Don't connect to itself.
		if other ~= self then				
			local dist = cf.pythagoras(self.pos.x, self.pos.y, other.pos.x, other.pos.y)
			
			-- Don't connect if the line wouldn't be visible.
			if dist < maxConnectionDist then
				-- Prevents 2 lines being drawn, one from each point of the line.
				-- O(n) time complexity, instead of O(1), I think.
				-- Still better in performance tests than checking if the x is higher
				-- than the other's x in my (bad) implementation, though.
				if not cf.valueInTable(other.connections, self.index) then
					table.insert(self.connections, otherIndex)
				end
			end
		end
	end
end

function Point:showConnections(points, maxConnectionDist, connectionWeightAlphaMult, framebuffer)
	for _, otherIndex in ipairs(self.connections) do
		local other = points[otherIndex]

		local dist = cf.pythagoras(self.pos.x, self.pos.y, other.pos.x, other.pos.y)

		-- Don't connect if the line wouldn't be visible.
		if dist < maxConnectionDist then
			local alpha = maxConnectionDist - dist

			local char = dithering.getClosestChar(cf.clamp(alpha * connectionWeightAlphaMult, 0, 1))

			cf.printTable(self.pos.x, self.pos.y)
			framebuffer:writeLine(self.pos.x, self.pos.y, other.pos.x, other.pos.y, char)
		end
	end
end