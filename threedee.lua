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
 
    new = function(self, framebuffer, canvasWidth, canvasHeight, cubesCoords, blockDiameter, offsets)
        local startingValues = {
            framebuffer = framebuffer,
            canvasWidth = canvasWidth,
            canvasHeight = canvasHeight,
            cubesCoords = cubesCoords,
            blockDiameter = blockDiameter,
            offsets = offsets,
           
            canvasCenterX = math.floor(canvasWidth/2),
            canvasCenterY = math.floor(canvasHeight/2),
            chars = {'@', '#', '0', 'A', '5', '2', '$', '3', 'C', '1', '%', '=', '(', '/', '!', '-', ':', "'", '.'},
           
            cubesCorners = self:getCubesCorners(cubesCoords, blockDiameter),
        }
       
        setmetatable(startingValues, {__index = self})
        return startingValues
    end,
   
    draw = function(self)
        --[[
        -- Draw connections.
        for originKey, destinations in ipairs(self.cubes[1].connections) do
            local origin = self.cubes[1].points[originKey]
            for _, destinationKey in ipairs(destinations) do
                local destination = self.cubes[1].points[destinationKey]
                self:line(origin[1], origin[2], destination[1], destination[2], '#')
            end
        end
        ]]--
       
        -- Draw fill.
        --for _, fillPoints in ipairs(self.cubes[1].fillPoints) do
        --  local ps = self.cubes[1].points
        --  self:fill(ps[fillPoints[1]], ps[fillPoints[2]], ps[fillPoints[3]])
        --end
       
        -- Draw points.
        -- Not using the z-axis yet!
        for _, cubeCorners in ipairs(self.cubesCorners) do
            -- Corners A, B, C, D in the front. See getCubesCorners() documentation.
            for i = 1, 4 do
                local cubeCorner = cubeCorners[i]
                self:writeChar(math.floor(cubeCorner[1] + 0.5), math.floor(cubeCorner[2] + 0.5), '#')
            end
            -- Corners E, F, G, H in the back.
            local offsets = self.offsets
            for i = 5, 8 do
                local cubeCorner = cubeCorners[i]
                self:writeChar(math.floor(cubeCorner[1] + offsets[1] + 0.5), math.floor(cubeCorner[2] + offsets[2] + 0.5), '#')
            end
        end
       
        --[[
        -- Draw filled circle.
        self:circle(self.canvasWidth/3, self.canvasHeight/2)
        ]]--
       
        --[[
        for y = 1, self.canvasHeight do
            for x = 1, self.canvasWidth do
                self:writeChar(x, y)
            end
        end
        ]]--
    end,
   
    getCubesCorners = function(self, cubesCoords, blockDiameter)
        local cubesCorners = {}
        for i, cubeCoords in ipairs(cubesCoords) do
            local bX, bY, bZ = cubeCoords[1], cubeCoords[2], cubeCoords[3]
            local bD = blockDiameter
            local hBD = 0.5 * bD -- Half block diameter.
            local bXD, bYD, bZD = bX*bD, bY*bD, bZ*bD
           
            --[[
            A to H are the eight returned corners,
            and b is the center of the block, being {bX, bY, bZ}.
              E----------F
             /|         /|
            A----------B |
            | |   b    | |
            | H--------|-G
            |/         |/
            D----------C
            ]]--
           
            cubesCorners[i] = {
                -- {x, y, z}, ...
                {bXD-hBD,bYD+hBD,bZD-hBD}, -- A.
                {bXD+hBD,bYD+hBD,bZD-hBD}, -- B.
                {bXD+hBD,bYD-hBD,bZD-hBD}, -- C.
                {bXD-hBD,bYD-hBD,bZD-hBD}, -- D.
                {bXD-hBD,bYD+hBD,bZD+hBD}, -- E.
                {bXD+hBD,bYD+hBD,bZD+hBD}, -- F.
                {bXD+hBD,bYD-hBD,bZD+hBD}, -- G.
                {bXD-hBD,bYD-hBD,bZD+hBD}, -- H.
            }
        end
        return cubesCorners
    end,
   
    line = function(self, x1, y1, x2, y2, char)
        local x_diff = x2 - x1
        local y_diff = y2 - y1
       
        local distance = math.sqrt(x_diff^2 + y_diff^2)
        local step_x = x_diff / distance
        local step_y = y_diff / distance
       
        for i = 0, distance do
            local x = i * step_x
            local y = i * step_y
            self:writeChar(math.floor(x1 + x + 0.5), math.floor(y1 + y + 0.5), char)
        end
    end,
 
    writeChar = function(self, x, y, char)
        -- Might need < instead of <=.
        local inCanvas = self.canvasCenterY + y > 0 and self.canvasCenterY + y <= self.canvasHeight and self.canvasCenterX + x > 0 and self.canvasCenterX + x <= self.canvasWidth
        if inCanvas then
            --[[
            print(self.canvasCenterY + y)
            print(self.canvasCenterX + x)
            print(char)
            ]]--
            self.framebuffer.buffer[self.canvasCenterY + y][self.canvasCenterX + x] = char
        end
    end,
   
    circle = function(self, centerX, centerY, radius)
          local xMult = 1.5 -- Characters are 6x9 pixels in size.
          for rad = 0, 2 * math.pi, math.pi / 180 do
              local x = math.cos(rad) * radius * xMult
              local y = math.sin(rad) * radius
              writeChar(centerX + x, centerY + y)
          end
    end,
   
    moveCamera = function(self, key)
        --[[
        if (key == 'w' or key == 'up') then
            self.cameraProximity = self.cameraProximity / 1.5
        elseif (key == 's' or key == 'down') then
            self.cameraProximity = self.cameraProximity * 1.5
        end
        ]]--
    end,
   
    fill = function(self, p1, p2, p3, char)    
        local x_diff = p3[1] - p1[1]
        local y_diff = p3[2] - p1[2]
       
        local distance = math.sqrt(x_diff^2 + y_diff^2)
        local step_x = x_diff / distance
        local step_y = y_diff / distance
       
        -- i = 1, distance - 1 doesn't seem to always work
        for i = 0, distance do
            local x = i * step_x
            local y = i * step_y
            local x1 = p1[1] + x
            local y1 = p1[2] + y
            local x2 = p2[1] + x
            local y2 = p2[2] + y
            self:line(x1, y1, x2, y2, '@')
        end
    end,
 
}
 
 
--------------------------------------------------