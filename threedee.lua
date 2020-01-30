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
			
			projectedCorners = {},
			
			cubesCorners = {},
        }
        
        setmetatable(self, {__index = ThreeDee})
		
		self:setCubesCorners(cubesCoords)
		
        return self
    end,
	
	setCubesCorners = function(self, cubesCoords)
		for i = 1, #cubesCoords do
			local cc = cubesCoords[i]
			self.cubesCorners[i] = {}
			
			self.cubesCorners[i][1] = vector.new(-0.5+cc.x, -0.5+cc.y, -0.5+cc.z)
			self.cubesCorners[i][2] = vector.new( 0.5+cc.x, -0.5+cc.y, -0.5+cc.z)
			self.cubesCorners[i][3] = vector.new( 0.5+cc.x,  0.5+cc.y, -0.5+cc.z)
			self.cubesCorners[i][4] = vector.new(-0.5+cc.x,  0.5+cc.y, -0.5+cc.z)
			
			self.cubesCorners[i][5] = vector.new(-0.5+cc.x, -0.5+cc.y, 0.5+cc.z)
			self.cubesCorners[i][6] = vector.new( 0.5+cc.x, -0.5+cc.y, 0.5+cc.z)
			self.cubesCorners[i][7] = vector.new( 0.5+cc.x,  0.5+cc.y, 0.5+cc.z)
			self.cubesCorners[i][8] = vector.new(-0.5+cc.x,  0.5+cc.y, 0.5+cc.z)
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
				local rotated = matrix.matMul(rotationX, m)
				rotated = matrix.matMul(rotationY, rotated)
				rotated = matrix.matMul(rotationZ, rotated)
				
				local z = 1 / (self.distance - rotated[3][1])
				local projection = {
					{z, 0, 0},
					{0, z, 0},
					{0, 0, z}
				}
				
				local projectedMatrix = matrix.matMul(projection, rotated)
				local projectedVector = matrix.matToVec(projectedMatrix)
				
				-- Stretch x by 50%, because characters are 6:9 pixels on the screen.				
				projectedVector.x = self.centerX + projectedVector.x * 100 * 1.5
				projectedVector.y = self.centerY + projectedVector.y * 100
				
				self.projectedCorners[i][j] = projectedVector
			end
		end
	end,
	
	drawCorners = function(self)
		for _, cube in ipairs(self.projectedCorners) do
			for _, v in ipairs(cube) do
				self.framebuffer:writeChar(v.x, v.y, self.cornerChar)
			end
		end
	end,

	connectCorners = function(self, cube, i, j)
		local c1, c2 = cube[i], cube[j] -- Get two corners.
		self.framebuffer:writeLine(c1.x, c1.y, c2.x, c2.y, self.connectionChar)
	end,
	
	-- Draw lines between corners.
	drawConnections = function(self)
		for _, cube in ipairs(self.projectedCorners) do
			for j = 1, 4 do
				self:connectCorners(cube, j, j % 4 + 1) -- Four front edges.
				self:connectCorners(cube, j, j + 4) -- Four middle edges.
				self:connectCorners(cube, j + 4, j % 4 + 5) -- Four back edges.
			end
		end
	end,
	
	drawFill = function(self)
		-- FillConnections below here holds three corners for each side of the cube.
		-- The first and third point have to be next to each other, because stepX and stepY can't be diagonal.
		local fillConnections = {
			{1, 2, 4}, -- ABD. -- Front face.
			{1, 2, 5}, -- ABE. -- Top face.
			{2, 3, 6}, -- BCF. -- Right face.
			{3, 4, 7}, -- CDG. -- Bottom face.
			{1, 4, 5}, -- ADE. -- Left face.
			{6, 5, 7}  -- FEG. -- Back face. -- There's a reason it's not EFG - don't remember why. :(
		}
		
		local offsets = self.offsets
        for _, cc in ipairs(self.cubesCorners) do -- cc is cubeCorners.
			for i = 1, 6 do -- For all faces of the cube.
				local side = fillConnections[i] -- Can't use an ipairs() loop, because i is needed at the end.
				local a, b, c = side[1], side[2], side[3] -- Get the three corners.
				
				-- Get the coordinates of the three corners. Add offsets[1] and offsets[2] if it's one of the four back corners.
				local x1, y1 = cc[a][1] + (a > 4 and offsets[1] or 0), cc[a][2] + (a > 4 and offsets[2] or 0)
				local x2, y2 = cc[b][1] + (b > 4 and offsets[1] or 0), cc[b][2] + (b > 4 and offsets[2] or 0)
				local x3, y3 = cc[c][1] + (c > 4 and offsets[1] or 0), cc[c][2] + (c > 4 and offsets[2] or 0)
				
				-- self.chars[6 + i] just means each face gets a different char. Use for debugging only.
				self:fill(x1, y1, x2, y2, x3, y3, self.chars[6 + i])
				
   				--self.framebuffer:draw() -- TEMPORARY!!!!!
				--sleep(1) -- TEMPORARY!!!!!
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
	
	fill = function(self, x1, y1, x2, y2, x3, y3, char)
  		local x_diff = x3 - x1
  		local y_diff = y3 - y1
		
  		local distance = math.sqrt(x_diff^2 + y_diff^2)
  		local step_x = x_diff / distance
  		local step_y = y_diff / distance
		
		-- i = 1, distance - 1 doesn't seem to always work
  		for i = 0, distance do
			local _x = i * step_x
			local _y = i * step_y
    		local _x1 = x1 + _x
    		local _y1 = y1 + _y
    		local _x2 = x2 + _x
    		local _y2 = y2 + _y
			self.framebuffer:writeLine(
				_x1 + self.canvasCenterX,
				_y1 + self.canvasCenterY,
				_x2 + self.canvasCenterX,
				_y2 + self.canvasCenterY,
				char
			)
  		end
	end,

}