-- Based on my 'Connections' P5.js program:
-- https://editor.p5js.org/MyNameIsTrez/sketches/MqnvoTzC

Connections = {

	new = function(self, settings)
		local s = settings

		local self = {
			-- Assign passed settings.
			offset = s.offset,
			size   = s.size,

			pointCountMult            = s.pointCountMult,
			maxConnectionDistMult     = s.maxConnectionDistMult,
			distMult                  = s.distMult,
			connectionWeightAlphaMult = s.connectionWeightAlphaMult,
			colorChangeMult           = s.colorChangeMult,
			debugInfo                 = s.debugInfo,
			maxFPS                    = s.maxFPS,
			pointMinVel               = s.pointMinVel,
			pointMaxVel               = s.pointMaxVel,

			-- Extra.
			screenPixelCountSqrt = math.sqrt(s.size.width, s.size.height),
			pointCount           = math.floor(screenPixelCountSqrt * pointCountMult),
			maxConnectionDist    = math.floor(s.maxConnectionDistMult * math.pow(screenPixelCountSqrt, 0.25)),

			points = {},
			moodCol, -- Not necessary?
		}
		
		setmetatable(self, {__index = Connections})

		self:generatePoints()
		
		return self
	end,

	generatePoints = function(self)

	end,

	show = function(self)

	end,

}