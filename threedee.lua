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

	new = function(framebuffer, canvasX1, canvasY1, canvasX2, canvasY2, distance, rotation, corners, connectionChar, cornerChar)
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
			
			corners = corners,
			
			connectionChar = connectionChar,
			cornerChar = cornerChar,
           	
            chars = {'@', '#', '0', 'A', '5', '2', '$', '3', 'C', '1', '%', '=', '(', '/', '!', '-', ':', "'", '.'},
			
			projectedCorners = {},
        }
        
        setmetatable(self, {__index = ThreeDee})
		
        return self
    end,
	
	getProjectedCorners = function(self)
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
		
		for i = 1, #self.corners do
			local v = self.corners[i]
			local m = matrix.vecToMat(v)
			local rotated = matrix.matMul(rotationX, m)
			rotated = matrix.matMul(rotationY, rotated)
			rotated = matrix.matMul(rotationZ, rotated)
			
			local z = 1 / (self.distance - rotated[3][1])
			local projection = {
				{z, 0, 0},
				{0, z, 0}
			}
			
			local projected2d = matrix.matMul(projection, rotated)
			projected2d[1][1] = projected2d[1][1] * 100
			projected2d[2][1] = projected2d[2][1] * 100
			self.projectedCorners[i] = projected2d
		end
	end,

	connect = function(self, i, j)
		local a, b = self.projectedCorners[i], self.projectedCorners[j]

		-- Translate to the middle of the screen and stretch x by 50%.
		local _x1, _y1 = a[1][1], a[2][1]
		local x1, y1 = self.centerX + _x1 * 1.5, self.centerY + _y1
		local _x2, _y2 = b[1][1], b[2][1]
		local x2, y2 = self.centerX + _x2 * 1.5, self.centerY + _y2

		self.framebuffer:writeLine(x1, y1, x2, y2, self.connectionChar)
	end,
	
	-- Draw lines between corners.
	drawConnections = function(self)
		for i = 1, 4 do
			self:connect(i, i % 4 + 1) -- Front.
			self:connect(i, i + 4) -- Middle.
			self:connect(i + 4, i % 4 + 5) -- Back.
		end
	end,
	
	drawFill = function(self)
		-- Three corners per face are taken, where the first and third point have to
		-- be next to each other, so no diagonal stepX or stepY can take place.
		local tab = {
			{1, 2, 4}, -- ABD.
			{1, 2, 5}, -- ABE.
			{2, 3, 6}, -- BCF.
			{3, 4, 7}, -- CDG.
			{1, 4, 5}, -- ADE.
			{6, 5, 7}  -- FEG.
		}
		
		local offsets = self.offsets
		-- cc is cubeCorners
        for _, cc in ipairs(self.cubesCorners) do
			for i = 1, 6 do
				local a, b, c = tab[i][1], tab[i][2], tab[i][3]
				local x1, y1 = cc[a][1] + (a > 4 and offsets[1] or 0), cc[a][2] + (a > 4 and offsets[2] or 0)
				local x2, y2 = cc[b][1] + (b > 4 and offsets[1] or 0), cc[b][2] + (b > 4 and offsets[2] or 0)
				local x3, y3 = cc[c][1] + (c > 4 and offsets[1] or 0), cc[c][2] + (c > 4 and offsets[2] or 0)
				self:fill(x1, y1, x2, y2, x3, y3, self.chars[6 + i])
				
   				--self.framebuffer:draw() -- TEMPORARY!!!!!
				--sleep(1) -- TEMPORARY!!!!!
			end
        end
	end,
	
	drawCorners = function(self)
		for _, m in ipairs(self.projectedCorners) do
			local _x, _y = m[1][1], m[2][1]
			local x, y = self.centerX + _x * 1.5, self.centerY + _y
			self.framebuffer:writeChar(x, y, self.cornerChar)
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