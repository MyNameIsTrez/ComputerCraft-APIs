Voronoi = {}


function Voronoi:new(pointCount)
	setmetatable({}, Voronoi)
	self.pointCount = pointCount
	self.width, self.height = term.getSize()
	return self
end


function Voronoi:createPoints()
	self.points = {}
	for i = 1, self.pointCount do
		local point = {
			pos = vector.new(math.random(self.width - 1), math.random(self.height)),
			char = dithering.getClosestChar(i / self.pointCount)
		}
		table.insert(self.points, point)
	end
end

function Voronoi:drawPixels()
	local charTable = {}
	for y = 1, self.height do
		for x = 1, self.width - 1 do
			local distancesData = {}
			for i = 1, self.pointCount do
				local point = self.points[i]
				local xDiff = x - point.pos.x
				local yDiff = y - point.pos.y
				local distSq = xDiff^2 + yDiff^2
				table.insert(distancesData, { distSq = distSq, char = point.char })
			end
			-- Sort ascending.
			table.sort(distancesData, function(a, b) return a.distSq < b.distSq end)
			term.setCursorPos(x, y)
			local char = distancesData[1].char -- Lua tables start at 1.
			table.insert(charTable, char)
		end
		if y ~= self.height then table.insert(charTable, "\n") end
		cf.tryYield() -- Circumvents default crash after 5s.
	end
	term.setCursorPos(1, 1)
	local str = table.concat(charTable)
	write(str)
end