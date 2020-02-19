--------------------------------------------------
-- README


--[[

API to draw 3D objects.

REQUIREMENTS
	* matrix: https://pastebin.com/9g8zvPpX -- Matrix multiplications and vector to matrix conversion.
	* framebuffer: https://pastebin.com/83q6p4Sp -- write() replacement, by drawing the entire screen with only one write() call for every frame.

]]--


--------------------------------------------------
-- CLASSES


ThreeDee = {

	new = function(framebuffer, canvasX1, canvasY1, canvasX2, canvasY2, distance, rotation, cubesCoords, connectionChar, cornerChar)
        -- Constructor to create Object
        local self = {
            framebuffer = framebuffer,
			
			canvasX1 = canvasX1,
			canvasY1 = canvasY1,
			canvasX2 = canvasX2,
			canvasY2 = canvasY2,
			
			centerX = math.floor((canvasX2-canvasX1)/2 + 0.5),
			centerY = math.floor((canvasY2-canvasY1)/2 + 0.5),
			
			distance = distance,
			rotation = rotation,
			
			connectionChar = connectionChar,
			cornerChar = cornerChar,
           	
            chars = {'@', '#', '0', 'A', '5', '2', '$', '3', 'C', '1', '%', '=', '(', '/', '!', '-', ':', "'", '.'},
			
			cubesCorners = {},
			
			projectedCorners = {},
        }
        
        setmetatable(self, {__index = ThreeDee})
		
		self:setCubesCorners(cubesCoords)
		
        return self
    end,
	
	setCubesCorners = function(self, cubesCoords)
		for i = 1, #cubesCoords do
			local cC = cubesCoords[i] -- cC means cubeCoords.
			
			self.cubesCorners[i] = {}
			
			self.cubesCorners[i][1] = vector.new(-0.5+cC.x, -0.5+cC.y, -0.5+cC.z)
			self.cubesCorners[i][2] = vector.new( 0.5+cC.x, -0.5+cC.y, -0.5+cC.z)
			self.cubesCorners[i][3] = vector.new( 0.5+cC.x,  0.5+cC.y, -0.5+cC.z)
			self.cubesCorners[i][4] = vector.new(-0.5+cC.x,  0.5+cC.y, -0.5+cC.z)
			
			self.cubesCorners[i][5] = vector.new(-0.5+cC.x, -0.5+cC.y,  0.5+cC.z)
			self.cubesCorners[i][6] = vector.new( 0.5+cC.x, -0.5+cC.y,  0.5+cC.z)
			self.cubesCorners[i][7] = vector.new( 0.5+cC.x,  0.5+cC.y,  0.5+cC.z)
			self.cubesCorners[i][8] = vector.new(-0.5+cC.x,  0.5+cC.y,  0.5+cC.z)
		end
	end,
	
	setProjectedCorners = function(self)
		local rotation = self.rotation
		local rotationX = {
			{ 1, 0, 0 },
			{ 0, math.cos(rotation.x), -math.sin(rotation.x) },
			{ 0, math.sin(rotation.x),  math.cos(rotation.x) }
		}
		local rotationY = {
			{ math.cos(rotation.y), 0, -math.sin(rotation.y) },
			{ 0, 1, 0 },
			{ math.sin(rotation.y), 0, math.cos(rotation.y) }
		}
		local rotationZ = {
			{ math.cos(rotation.z), -math.sin(rotation.z), 0 },
			{ math.sin(rotation.z),  math.cos(rotation.z), 0 },
			{ 0, 0, 1 }
		}
		
		for i = 1, #self.cubesCorners do
			self.projectedCorners[i] = {}
			local cubeCorners = self.cubesCorners[i]
			
			for j = 1, #cubeCorners do
				local v = cubeCorners[j]
				local m = matrix.vecToMat(v)
				
				local rotated
				rotated = matrix.matMul(rotationX, m)
				rotated = matrix.matMul(rotationY, rotated)
				rotated = matrix.matMul(rotationZ, rotated)
				
				local rotatedZ = rotated[3][1]
				local z = 1 / (self.distance - rotatedZ)
				local projection = {
					{z, 0, 0},
					{0, z, 0},
					--{0, 0, z} -- Not sure if this belongs here.
				}
				
				local projectedMatrix = matrix.matMul(projection, rotated)
				local projectedVector = matrix.matToVec(projectedMatrix)
				
				-- HARD CODING MULTIPLYING BY 100 HERE IS BAD!
				-- Stretch x by 50%, because characters are 6:9 pixels on the screen.
				projectedVector.x = self.centerX + projectedVector.x * 100 * 1.5
				projectedVector.y = self.centerY + projectedVector.y * 100
				--projectedVector.z = projectedVector.z -- Not sure if this belongs here.
				
				self.projectedCorners[i][j] = projectedVector
			end
		end
	end,
	
	drawFill = function(self)
		-- FillConnections holds two times three corners for each side of the cube.
		local fillConnections = {
			{{1, 2, 4}, {2, 3, 4}}, -- Front face.
			{{1, 2, 5}, {2, 5, 6}}, -- Top face.
			{{2, 3, 6}, {3, 6, 7}}, -- Right face.
			{{3, 4, 7}, {4, 7, 8}}, -- Bottom face.
			{{1, 4, 5}, {4, 5, 8}}, -- Left face.
			{{5, 6, 7}, {5, 7, 8}}  -- Back face.
		}
		
        for _, cC in ipairs(self.projectedCorners) do -- cC is cubeCorners.
			--for _, side in ipairs(fillConnections) do
			for i = 1, #fillConnections do
				local side = fillConnections[i]
				--for _, triangle in ipairs(side) do
				for j = 1, #side do
					local triangle = side[j]
					local ai, bi, ci = triangle[1], triangle[2], triangle[3]
					local vertices = {cC[ai], cC[bi], cC[ci]}
					local char = self.chars[i * 2 + j]
					self:drawFilledTriangle(vertices, char)
				end
			end
        end
	end,
	
	drawFilledTriangle = function(self, vertices, char)
		-- Sort vertices, so v0.y <= v1.y <= v2.y.
		table.sort(vertices, function(a, b) return a.y < b.y end)
		
		local v0 = vertices[1]
		local v1 = vertices[2]
		local v2 = vertices[3]
		
		if (v0.y == v1.y) then -- Natural flat top.
			-- Sort so v0 is on the left of v1.
			if (v1.x < v0.x) then
				local _v0 = v0
				v0 = v1
				v1 = _v0
			end
			self:drawFlatTopTriangle(v0, v1, v2, char)
		elseif (v1.y == v2.y) then -- Natural flat bottom.
			-- Sort so v1 is on the left of v2.
			if (v2.x < v1.x) then
				local _v1 = v1
				v1 = v2
				v2 = _v1
			end
			self:drawFlatBottomTriangle(v0, v1, v2, char)
		else -- General triangle.
			-- Find splitting vertex.
			local alphaSplit = (v1.y - v0.y) / (v2.y - v0.y)
			-- vi = v0 + (v2 - v0) * alphaSplit
			-- local vi = vector.add(v0, vector.mul(vector.sub(v2, v0), alphaSplit))
			local vi = v2:sub(v0):mul(alphaSplit):add(v0)
			
			if (v1.x < vi.x) then -- Major right.
				self:drawFlatBottomTriangle(v0, v1, vi, char)
				self:drawFlatTopTriangle(v1, vi, v2, char)
			else -- Major left.
				self:drawFlatBottomTriangle(v0, vi, v1, char)
				self:drawFlatTopTriangle(vi, v1, v2, char)
			end
		end
	end,
	
	drawFlatTopTriangle = function(self, v0, v1, v2, char)
		-- Calculate inverse slopes of left and right lines.
  		-- Note it's dx/dy, not dy/dx, to prevent div by 0.
  		-- This works, because there are no perfectly horizontal lines for the left and right triangle edges.
		local m0 = (v2.x - v0.x) / (v2.y - v0.y)
		local m1 = (v2.x - v1.x) / (v2.y - v1.y)
		
		-- Calculate start and end scanline y values as ints.
  		-- Top part of the top-left rule.
  		-- The difference between ceil(n-0.5) and round(n) is that ceil(1.5-0.5) === 1, while round(1.5) === 2, but not sure if round() could be used instead.
		local yStart = math.ceil(v0.y - 0.5)
		local yEnd = math.ceil(v2.y - 0.5) -- The scanline AFTER the last line drawn.
		
		for y = yStart, yEnd - 1 do -- Draw up to but not including yEnd.
			-- Calculate start and end points (x-coords).
			-- Add 0.5 to y value because we're calculating based on pixel CENTERS.
			local px0 = m0 * (y + 0.5 - v0.y) + v0.x
			local px1 = m1 * (y + 0.5 - v1.y) + v1.x
			
			-- Calculate start and end pixels.
			-- Left part of the top-left rule.
			local xStart = math.ceil(px0 - 0.5)
			local xEnd = math.ceil(px1 - 0.5) -- The pixel AFTER the last pixel drawn.
			
			for x = xStart, xEnd - 1 do -- Draw up to but not including xEnd.
				self.framebuffer:writeChar(x, y, char)
			end
		end
	end,
	
	drawFlatBottomTriangle = function(self, v0, v1, v2, char)
		-- Calculate inverse slopes of left and right lines.
  		-- Note it's dx/dy, not dy/dx, to prevent div by 0.
  		-- This works, because there are no perfectly horizontal lines for the left and right triangle edges.
		local m0 = (v1.x - v0.x) / (v1.y - v0.y)
		local m1 = (v2.x - v0.x) / (v2.y - v0.y)
		
		-- Calculate start and end scanline y values as ints.
  		-- Top part of the top-left rule.
  		-- The difference between ceil(n-0.5) and round(n) is that ceil(1.5-0.5) === 1, while round(1.5) === 2, but not sure if round() could be used instead.
		local yStart = math.ceil(v0.y - 0.5)
		local yEnd = math.ceil(v2.y - 0.5) -- The scanline AFTER the last line drawn.
		
		for y = yStart, yEnd - 1 do -- Draw up to but not including yEnd.
			-- Calculate start and end points (x-coords).
			-- Add 0.5 to y value because we're calculating based on pixel CENTERS.
			local px0 = m0 * (y + 0.5 - v0.y) + v0.x
			local px1 = m1 * (y + 0.5 - v0.y) + v0.x
			
			-- Calculate start and end pixels.
			-- Left part of the top-left rule.
			local xStart = math.ceil(px0 - 0.5)
			local xEnd = math.ceil(px1 - 0.5) -- The pixel AFTER the last pixel drawn.
			
			for x = xStart, xEnd - 1 do -- Draw up to but not including xEnd.=
				self.framebuffer:writeChar(x, y, char)
			end
		end
	end,
	
	moveCamera = function(self, key)
    	if (key == 'space') then
			self.rotation.x = self.rotation.x - 0.1
    	elseif (key == 'leftShift') then
			self.rotation.x = self.rotation.x + 0.1
		elseif (key == 'a') then
			self.rotation.y = self.rotation.y - 0.1
    	elseif (key == 'd') then
			self.rotation.y = self.rotation.y + 0.1
		elseif (key == 'q') then
			self.rotation.z = self.rotation.z - 0.1
    	elseif (key == 'e') then
			self.rotation.z = self.rotation.z + 0.1
		elseif (key == 'w') then
			self.distance = self.distance - 0.1
    	elseif (key == 's') then
			self.distance = self.distance + 0.1
    	end
	end,

}