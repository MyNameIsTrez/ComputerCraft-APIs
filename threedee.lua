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
 
    new = function(self, framebuffer, points, connections, fillPoints, canvasWidth, canvasHeight, cameraProximity)
        local startingValues = {
            framebuffer = framebuffer,
            points = points,
            connections = connections,
            fillPoints = fillPoints,
            canvasWidth = canvasWidth,
            canvasHeight = canvasHeight,
            cameraProximity = cameraProximity,
           
            canvasCenterX = math.floor(canvasWidth/2),
            canvasCenterY = math.floor(canvasHeight/2),
            chars = {'@', '#', '0', 'A', '5', '2', '$', '3', 'C', '1', '%', '=', '(', '/', '!', '-', ':', "'", '.'},
        }
       
        setmetatable(startingValues, {__index = self})
        return startingValues
    end,
   
    draw = function(self)
        -- Draw connections.
        for originKey, destinations in ipairs(self.connections) do
            local origin = self.points[originKey]
            for _, destinationKey in ipairs(destinations) do
                local destination = self.points[destinationKey]
                self:line(origin[1] * self.cameraProximity, origin[2] * self.cameraProximity, destination[1] * self.cameraProximity, destination[2] * self.cameraProximity)
            end
        end
       
        -- Draw fill.
        for _, fillPoints in ipairs(self.fillPoints) do
            local ps = self.points
            self:fill(ps[fillPoints[1]], ps[fillPoints[2]], ps[fillPoints[3]], ps[fillPoints[4]])
        end
       
        --[[
        -- Draw points.
        for _, point in ipairs(self.points) do
            self:writeChar(point[1], point[2])
        end
        ]]--
       
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
   
    line = function(self, x1, y1, x2, y2)
        local x_diff = x2 - x1
        local y_diff = y2 - y1
       
        local distance = math.sqrt(x_diff^2 + y_diff^2)
        local step_x = x_diff / distance
        local step_y = y_diff / distance
       
        for i = 0, distance do
            local x = i * step_x
            local y = i * step_y
            self:writeChar(math.floor(x1 + x + 0.5), math.floor(y1 + y + 0.5))
        end
    end,
 
    writeChar = function(self, x, y)
        --[[
        local distCenterX = self.canvasCenterX - x
        local distCenterY = self.canvasCenterY - y
        local dist = math.sqrt(distCenterX*distCenterX + distCenterY*distCenterY) * self.cameraProximity
        if dist <= 19 then
            local char = self.chars[math.ceil(dist < 19 and (dist > 0 and dist or 1) or 19)]
            --local char = self.chars[math.ceil(dist < 19 and dist or 19)]
            self.framebuffer.buffer[y][x] = char
        end
        ]]--
       
        -- Might need < instead of <=.
        if self.canvasCenterY + y > 0 and self.canvasCenterY + y <= self.canvasHeight and self.canvasCenterX + x > 0 and self.canvasCenterX + x <= self.canvasWidth then
            self.framebuffer.buffer[self.canvasCenterY + y][self.canvasCenterX + x] = '@'
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
        if (key == 'w' or key == 'up') then
            self.cameraProximity = self.cameraProximity / 1.5
        elseif (key == 's' or key == 'down') then
            self.cameraProximity = self.cameraProximity * 1.5
        end
    end,
   
    fill = function(self, p1, p2, p3, p4)      
        local x_diff = p4[1] * self.cameraProximity - p2[1] * self.cameraProximity
        local y_diff = p4[2] * self.cameraProximity - p2[2] * self.cameraProximity
       
        local distance = math.sqrt(x_diff^2 + y_diff^2)
        local step_x = x_diff / distance / self.cameraProximity
        local step_y = y_diff / distance / self.cameraProximity
       
        print('distance: ' .. tostring(distance))
        print('step_x: ' .. tostring(step_x))
        print('step_y: ' .. tostring(step_y))
       
        for i = 1, distance - 1 do
            local x = i * step_x
            local y = i * step_y
            local x1 = math.floor(p1[1] + x + 0.5)
            local y1 = math.floor(p1[2] + y + 0.5)
            local x2 = math.floor(p2[1] + x + 0.5)
            local y2 = math.floor(p2[2] + y + 0.5)
            self:line(x1 * self.cameraProximity, y1 * self.cameraProximity, x2 * self.cameraProximity, y2 * self.cameraProximity)
        end
    end,
 
}
 
 
--------------------------------------------------