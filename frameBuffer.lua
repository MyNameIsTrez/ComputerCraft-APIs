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
 
    new = function(canvasWidth, canvasHeight)
        local self = {
            canvasWidth = canvasWidth,
            canvasHeight = canvasHeight,
            buffer = {},
        }
       
        setmetatable(self, {__index = FrameBuffer})
       
        buffer = self:createBuffer(canvasWidth, canvasHeight)
       
        return self
    end,
   
    createBuffer = function(self, canvasWidth, canvasHeight)
        for y = 1, canvasHeight do
            self.buffer[y] = {}
            for x = 1, canvasWidth do
                self.buffer[y][x] = ' '
            end
        end
    end,
   
    resetBuffer = function(self)
        local bufferCopy = self.buffer
        for y = 1, self.canvasHeight do
            for x = 1, self.canvasWidth do
                if bufferCopy[y][x] ~= ' ' then
                    bufferCopy[y][x] = ' '
                end
            end
        end
        self.buffer = bufferCopy
    end,
   
    draw = function(self)      
        -- Draw the current frame.
        strTab = {}
        for y = 1, self.canvasHeight do
            strTab[#strTab + 1] = table.concat(self.buffer[y])
            strTab[#strTab + 1] = '\n' -- Maybe concating above instead is faster?
        end
        term.setCursorPos(cfg.playArea.X, cfg.playArea.Y)
        write(table.concat(strTab))
 
        -- Clear the buffer.
        -- Maybe faster to copy an empty table instead, but I think that needs recursion.
        self:resetBuffer()
    end,
 
}