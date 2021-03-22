-- Class table
Voronoi = {}


-- Constructor
function Voronoi:new(pointCount)
	setmetatable({}, Voronoi)
	self.pointCount = pointCount
	self.width, self.height = term.getSize()
	self.width = self.width - 1 -- Compensates for adding the invisible '\n' char at the end of every row.
	self.chars = { ".", "'", ":", "-", "!", "/", "(", "=", "%", "1", "C", "3", "$", "2", "5", "A", "0", "#", "@" }
	return self
end


-- Methods
function Voronoi:createPoints()
	self.points = {}
	for i = 1, self.pointCount do
		local point = {
			pos = vector.new(math.random(self.width), math.random(self.height)),
			char = self.chars[(i - 1) % #self.chars + 1] -- Cycles through and reuses the available chars.
		}
		table.insert(self.points, point)
	end
end

function Voronoi:drawPixels()
	local yieldCounter = 0
	local yieldFreq = 1 / self.pointCount * 100000
	local charTable = {}
	for y = 1, self.height do
		for x = 1, self.width do
			local smallestDist = 1/0 -- 1/0 is 'inf'; used because 'inf' directly is not recognized.
			local char
			for i = 1, self.pointCount do
				local point = self.points[i]
				local xDiff = x - point.pos.x
				local yDiff = y - point.pos.y
				local distSq = xDiff^2 + yDiff^2 -- Don't need sqrt when comparing.
				if distSq < smallestDist then
					smallestDist = distSq
					char = point.char
				end
			end
			term.setCursorPos(x, y)
			table.insert(charTable, char)
			yieldCounter = yieldCounter + 1
			-- Circumvents default crash after 5s.
			if yieldCounter % yieldFreq == 0 then cf.tryYield() end
		end
		if y ~= self.height then table.insert(charTable, "\n") end
	end
	term.setCursorPos(1, 1)
	local str = table.concat(charTable) -- Concatenates all characters into a single string.
	write(str)
	term.setCursorPos(1, 1) -- Can be edited if the user wants to end elsewhere.
end