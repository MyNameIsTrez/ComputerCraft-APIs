-- Based on my 'Connections' P5.js program:
-- https://editor.p5js.org/MyNameIsTrez/sketches/MqnvoTzC

Connections = {

	new = function(self, settings)
		local s = settings

		local screenPixelCountSqrt = math.sqrt(s.size.width, s.size.height)

		local self = {
			-- Assign passed settings.
			offset = s.offset,
			size   = s.size,

			pointCountMult            = s.pointCountMult,
			maxConnectionDistMult     = s.maxConnectionDistMult,
			distMult                  = s.distMult,
			connectionWeightAlphaMult = s.connectionWeightAlphaMult,
			maxFPS                    = s.maxFPS,
			pointMinVel               = s.pointMinVel,
			pointMaxVel               = s.pointMaxVel,

			-- Extra.
			screenPixelCountSqrt = screenPixelCountSqrt,
			pointCount           = math.floor(screenPixelCountSqrt * s.pointCountMult),
			maxConnectionDist    = math.floor(s.maxConnectionDistMult * math.pow(screenPixelCountSqrt, 0.25)),

			points = {},
		}

		setmetatable(self, {__index = Connections})

		self:generatePoints()
		
		return self
	end,

	generatePoints = function(self)
		for index = 1, self.pointCount do
			local x = math.random(self.size.width)
			local y = math.random(self.size.height)
			table.insert(self.points, Point:new(index, x, y, self.pointMinVel, self.pointMaxVel))
		end
	end,

	show = function(self)
		for _, point in ipairs(self.points) do
			point:move(self.maxConnectionDist, self.size.width, self.size.height)
			point.connections = {}
		end

		for _, point in ipairs(self.points) do
			point:generateConnections(self.pointCount, self.points, self.maxConnectionDist)
			point:showConnections(self.points, self.maxConnectionDist, self.connectionWeightAlphaMult)
		end
	end,

}

Point = {

	new = function(self, index, x, y, pointMinVel, pointMaxVel)
		local self = {
			index       = index,
			pos         = vector.new(x, y),
			vel         = cf.vectorRandom2D():mul(math.random(pointMinVel, pointMaxVel)),
			connections = {}
		}
		
		setmetatable(self, {__index = Point})

		return self
	end,

	move = function(self, maxConnectionDist, width, height)
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
	end,

	generateConnections = function(self, pointCount, points, maxConnectionDist)
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
	end,

	showConnections = function(self, points, maxConnectionDist, connectionWeightAlphaMult)
		for _, otherIndex in ipairs(self.connections) do
			local other = points[otherIndex]

			local dist = cf.pythagoras(self.pos.x, self.pos.y, other.pos.x, other.pos.y)

			-- Don't connect if the line wouldn't be visible.
			if dist < maxConnectionDist then
				local alpha = maxConnectionDist - dist

				local char = dithering.getClosestChar(cf.clamp(alpha * connectionWeightAlphaMult, 0, 1))

				shape.line(self.pos, other.pos, char)
			end
		end
	end,

}