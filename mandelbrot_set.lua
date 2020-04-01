Mandelbrot = {

    new = function(self, x1, y1, x2, y2, maxIterations, zoomX, zoom, zoomMultiplier)
        local startingValues = {
			x1 = x1,
			y1 = y1,
			x2 = x2,
			y2 = y2,
			maxIterations = maxIterations,
			zoomX = zoomX,
			zoom = zoom,
			zoomMultiplier = zoomMultiplier
        }
       
        setmetatable(startingValues, {__index = self})
        return startingValues
	end,
	
	setZoom = function(self, zoom)
		self.zoom = zoom
	end,
	
	getCurrentFrame = function(self)
		local stringTab = {}
		for y = self.y1, self.y2 do
			for x = self.x1, self.x2 do
				-- x * 1.5 compensates for the 6:9 size ratio of characters.
				local a = cf.map(x * 1.5, self.x1, self.x2, self.zoomX - self.zoom, self.zoomX + self.zoom)
				local b = cf.map(y, self.y1, self.y2, -self.zoom, self.zoom)

				local ca = a
				local cb = b

				local n = 0
				while n < self.maxIterations do
					local aa = a * a - b * b
					local bb = 2 * a * b
					a = aa + ca
					b = bb + cb
					if a * a + b * b > 16 then
						break
					end
					n = n + 1
				end

				local brightness = cf.map(n, 0, self.maxIterations, 0, 1)
				brightness = cf.map(math.sqrt(brightness), 0, 1, 0, 1)

				if n == self.maxIterations then
					brightness = 0
				end

				local char = dithering.getClosestChar(brightness)
				
				table.insert(stringTab, char)
			end
			table.insert(stringTab, '\n')
			cf.yield()
		end
		cf.yield()
		return table.concat(stringTab) -- Converts table to a string.
	end,

	getNextFrame = function(self)
		self.zoom = self.zoom * self.zoomMultiplier
		term.setCursorPos(1, 1)
		write(tostring(self.zoom)..'      ')
		return self:getCurrentFrame()
	end,

	drawFrame = function(self, frame)
		term.setCursorPos(self.x1, self.y1)
		write(frame)
		cf.yield()
	end

}