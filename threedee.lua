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
 
    new = function(framebuffer, canvasWidth, canvasHeight, cubesCoords, blockDiameter, offsets)
        -- Constructor to create Object
        local self = {
            framebuffer = framebuffer,
            canvasWidth = canvasWidth,
            canvasHeight = canvasHeight,
            cubesCoords = cubesCoords,
            blockDiameter = blockDiameter,
            offsets = offsets,
           
            canvasCenterX = canvasWidth/2,
            canvasCenterY = canvasHeight/2,
            chars = {'@', '#', '0', 'A', '5', '2', '$', '3', 'C', '1', '%', '=', '(', '/', '!', '-', ':', "'", '.'},
           
            cubesCorners = ThreeDee.getCubesCorners({}, cubesCoords, blockDiameter),
        }
       
        setmetatable(self, {__index = ThreeDee})
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
                    self:line(
                        origin[1],
                        origin[2],
                        destination[1] + (destIndex > 4 and offsets[1] or 0),
                        destination[2] + (destIndex > 4 and offsets[2] or 0),
                        '@'
                    )
                end
            end
            for i = 5, 8 do
                local origin = cubeCorners[i]
                for j = 1, 2 do
                    local destIndex = connectionsTab[i][j] -- Destination index.
                    local destination = cubeCorners[destIndex]
                    self:line(
                        origin[1] + (i > 4 and offsets[1] or 0),
                        origin[2] + (i > 4 and offsets[2] or 0),
                        destination[1] + (destIndex > 4 and offsets[1] or 0),
                        destination[2] + (destIndex > 4 and offsets[2] or 0),
                        '@'
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
            {6, 5, 7} -- FEG.
        }
       
        for _, cubeCorners in ipairs(self.cubesCorners) do
            for i = 1, 6 do
                self:fill(cubeCorners[tab[i][1]], cubeCorners[tab[i][2]], cubeCorners[tab[i][3]])
               
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
                self:writeChar(cubeCorner[1], cubeCorner[2], '#')
            end
            -- Corners E, F, G, H in the back.
            local offsets = self.offsets
            for i = 5, 8 do
                local cubeCorner = cubeCorners[i]
                self:writeChar(cubeCorner[1] + offsets[1], cubeCorner[2] + offsets[2], '#')
            end
        end
    end,
   
    drawCircle = function(self)
        self:circle(self.canvasWidth/3, self.canvasHeight/2)
    end,
   
    getCubesCorners = function(self, cubesCoords, blockDiameter)
        local cubesCorners = {}
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
           
            cubesCorners[i] = {
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
            self:writeChar(x1 + x, y1 + y, char)
        end
    end,
 
    writeChar = function(self, x1, y1, char)
        -- Might need < instead of <=.
        local inCanvas = self.canvasCenterY + y1 > 0 and self.canvasCenterY + y1 <= self.canvasHeight and self.canvasCenterX + x1 > 0 and self.canvasCenterX + x1 <= self.canvasWidth
        if inCanvas then
            local y = math.floor(self.canvasCenterY + y1 + 0.5)
            local x = math.floor(self.canvasCenterX + x1 + 0.5)
            self.framebuffer.buffer[y][x] = char
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