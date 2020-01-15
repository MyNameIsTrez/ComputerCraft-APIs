--------------------------------------------------
-- README
 
 
--[[
 
API that holds a giant 2D table, that can get drawn to the screen with one write() call.
Intended to prevent programs slowing down by drawing a bunch of characters with the same coordinates in a single frame.
 
REQUIREMENTS
    * None
 
]]--
 
 
--------------------------------------------------
-- CLASSES
 
 
FrameBuffer = {
 
    new = function(self, canvasWidth, canvasHeight)
        local startingValues = {
            canvasWidth = canvasWidth,
            canvasHeight = canvasHeight,
            buffer,
        }
       
        setmetatable(startingValues, {__index = self})
        return startingValues
    end,
   
    createBuffer = function(self)
        local buffer = {}
        for y = 1, self.canvasHeight do
            buffer[y] = {}
            for x = 1, self.canvasWidth do
                buffer[y][x] = ' '
            end
        end
        self.buffer = buffer
    end,
   
    draw = function(self)      
        -- Draw the current frame.
        strTab = {}
        for y = 1, self.canvasHeight do
            strTab[#strTab + 1] = table.concat(self.buffer[y])
            strTab[#strTab + 1] = '\n'
        end
        term.setCursorPos(cfg.playArea.X, cfg.playArea.Y)
        write(table.concat(strTab))
 
        -- Clear the buffer.
        -- Maybe faster to copy an empty table instead, but I think that needs recursion.
        self:createBuffer()
    end,
 
}