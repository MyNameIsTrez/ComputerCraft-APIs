-- Based on my Simple Graph P5.js program:
-- https://editor.p5js.org/MyNameIsTrez/sketches/nmEaU0Dn

Graph = {

	new = function(self, settings)
		local s = settings

		local self = {
			-- Assign passed settings.
			cols   = s.cols,
			offset = s.offset,
			size   = s.size,

    		-- Moving the origin point to the bottom left makes programming the graph easier.
			xBottomLeft = s.offset.x,
			yBottomLeft = s.offset.y + s.size.height,
			xTopRight   = s.offset.x + s.size.width,
			yTopRight   = s.offset.y,

			-- (xTopRight - xBottomLeft) / cols
			colWidth = math.floor(s.size.width / s.cols),

			-- yTopRight - yBottomLeft
			maxHeight = s.offset.y - (s.offset.y + s.size.height),

			char = s.char,

			-- Extra.
			data = {},
		}
		
		setmetatable(self, {__index = Graph})
		
		return self
	end,

	add = function(self, number)
		table.insert(self.data, number) -- Pushes the number.
		
    	-- If there's more data than there are columns, start removing old data.
		if #self.data > self.cols then
			table.remove(self.data, 1) --  Removes index 1, so it removes the oldest number.
		end
	end,

	show = function(self)
		for col = 1, #self.data do
			local number = self.data[col]

			local w = self.colWidth
			local h = number * self.maxHeight

			for sub = 0, self.colWidth - 1 do
				local x1 = self.xBottomLeft + (col - 1) * self.colWidth + sub
				local y1 = self.yBottomLeft

				local pos1 = vector.new(x1, y1)
				local pos2 = vector.new(x1 + 1, y1 + h)

				shape.line(pos1, pos2, self.char, true)
			end
		end
	end,

}