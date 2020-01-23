--------------------------------------------------
-- README


--[[

API to draw 3D objects.

REQUIREMENTS
	* None

]]--


--------------------------------------------------
-- CLASSES


ThreeDee = {

	new = function(framebuffer, canvasWidth, canvasHeight, cubesCoords, blockDiameter, offsets, connectionChar, pointChar)
        -- Constructor to create Object
        local self = {
            framebuffer = framebuffer,
            canvasWidth = canvasWidth,
            canvasHeight = canvasHeight,
            cubesCoords = cubesCoords,
            blockDiameter = blockDiameter,
            offsets = offsets,
			connectionChar = connectionChar,
			pointChar = pointChar,
           	
            canvasCenterX = canvasWidth/2,
            canvasCenterY = canvasHeight/2,
            chars = {'@', '#', '0', 'A', '5', '2', '$', '3', 'C', '1', '%', '=', '(', '/', '!', '-', ':', "'", '.'},
            
			cubesCorners = {},
        }
        
        setmetatable(self, {__index = ThreeDee})
		
        self:getCubesCorners(cubesCoords, blockDiameter)
		
        return self
    end,
	
	drawConnections = function(self)
		-- Not using the z-axis yet!
		for _, cubeCorners in ipairs(self.cubesCorners) do
			connectionsTab = {
				-- Each key is the index of a corner,
				-- and it connects to each of the 3 values that are the indices of each corner.
				{2, 4, 5}, -- A: B, D, E
				{1, 3, 6}, -- B: A, C, F
				{2, 4, 7}, -- C: B, D, G
				{1, 3, 8}, -- D: A, C, H
				{6, 8}, -- E: F, H
				{5, 7}, -- F: E, G
				{6, 8}, -- G: F, H
				{5, 7}  -- H: E, G
			}
			
			local offsets = self.offsets
			for i = 1, 4 do
				local origin = cubeCorners[i]
				for j = 1, 3 do
					local destIndex = connectionsTab[i][j] -- Destination index.
					local destination = cubeCorners[destIndex]
					self.framebuffer:writeLine(
						origin[1] + self.canvasCenterX,
						origin[2] + self.canvasCenterY,
						destination[1] + (destIndex > 4 and offsets[1] or 0) + self.canvasCenterX,
						destination[2] + (destIndex > 4 and offsets[2] or 0) + self.canvasCenterY,
						self.connectionChar
					)
				end
			end
			for i = 5, 8 do
				local origin = cubeCorners[i]
				for j = 1, 2 do
					local destIndex = connectionsTab[i][j] -- Destination index.
					local destination = cubeCorners[destIndex]
					self.framebuffer:writeLine(
						origin[1] + offsets[1] + self.canvasCenterX,
						origin[2] + offsets[2] + self.canvasCenterY,
						destination[1] + (destIndex > 4 and offsets[1] or 0) + self.canvasCenterX,
						destination[2] + (destIndex > 4 and offsets[2] or 0) + self.canvasCenterY,
						self.connectionChar
					)
				end
			end
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
	
	drawPoints = function(self)
		-- Not using the z-axis yet!
		for _, cubeCorners in ipairs(self.cubesCorners) do
			-- Corners A, B, C, D in the front. See getCubesCorners() documentation.
			for i = 1, 4 do
				local cubeCorner = cubeCorners[i]
				self.framebuffer:writeChar(cubeCorner[1] + self.canvasCenterX, cubeCorner[2] + self.canvasCenterY, self.pointChar)
			end
			-- Corners E, F, G, H in the back.
			local offsets = self.offsets
			for i = 5, 8 do
				local cubeCorner = cubeCorners[i]
				self.framebuffer:writeChar(cubeCorner[1] + offsets[1] + self.canvasCenterX, cubeCorner[2] + offsets[2] + self.canvasCenterY, self.pointChar)
			end
		end
	end,
	
	drawCircle = function(self)
		self:circle(self.canvasWidth/3, self.canvasHeight/2)
	end,
	
	getCubesCorners = function(self, cubesCoords, blockDiameter)
		for i, cubeCoords in ipairs(cubesCoords) do
			local bX, bY, bZ = cubeCoords[1], cubeCoords[2], cubeCoords[3]
			local bD = blockDiameter
			local hBD = 0.5 * bD -- Half block diameter.
			local hBDX = 1.5 * hBD -- Half block diameter for x, to compensate for 6:9 pixels characters.
			local bXD, bYD, bZD = bX*bD, bY*bD, bZ*bD
			
			--[[
			A to H are the eight returned corners inside cubesCorners,
			and b is the center of the block, being {bX, bY, bZ}.
        	  E----------F
			 /|         /|
			A----------B |
			| |   b    | |
			| H--------|-G
			|/         |/
			D----------C
			]]--
			
			self.cubesCorners[i] = {
				-- {x, y, z}, ...
				{bXD-hBDX, bYD+hBD, bZD-hBD}, -- A.
				{bXD+hBDX, bYD+hBD, bZD-hBD}, -- B.
				{bXD+hBDX, bYD-hBD, bZD-hBD}, -- C.
				{bXD-hBDX, bYD-hBD, bZD-hBD}, -- D.
				{bXD-hBDX, bYD+hBD, bZD+hBD}, -- E.
				{bXD+hBDX, bYD+hBD, bZD+hBD}, -- F.
				{bXD+hBDX, bYD-hBD, bZD+hBD}, -- G.
				{bXD-hBDX, bYD-hBD, bZD+hBD}, -- H.
			}
		end
	end,
	
	circle = function(self, centerX, centerY, radius)
  		local xMult = 1.5 -- Characters are 6x9 pixels in size.
		for rad = 0, 2 * math.pi, math.pi / 180 do
    	    local x = math.cos(rad) * radius * xMult
    	    local y = math.sin(rad) * radius
    	    self.framebuffer:writeChar(centerX + x + self.canvasCenterX, centerY + y + self.canvasCenterY)
  		end
	end,
	
	moveCamera = function(self, key)
    	if (key == 'w' or key == 'up') then
        	self.offsets[2] = self.offsets[2] - 1
    	elseif (key == 's' or key == 'down') then
        	self.offsets[2] = self.offsets[2] + 1
		elseif (key == 'a' or key == 'left') then
        	self.offsets[1] = self.offsets[1] - 1
    	elseif (key == 'd' or key == 'right') then
        	self.offsets[1] = self.offsets[1] + 1
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


--------------------------------------------------