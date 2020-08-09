Movement = {
    pos = vector.new(0, 0, 0),
    dir = "N"
}

function Movement:new(pos, dir)
    setmetatable({}, Movement)
    self.pos = pos
    self.dir = dir
    return self
end

function Movement:forward(times)
    print(self)
    times = times or 1
    for i = 1, times do
        if turtle.forward() then
            if self.dir == "N" then
                self.pos.y = self.pos.y - 1
            elseif self.dir == "S" then
                self.pos.y = self.pos.y + 1
            elseif self.dir == "E" then
                self.pos.x = self.pos.x + 1
            elseif self.dir == "W" then
                self.pos.x = self.pos.x - 1
            end
        end
    end
    print(self)
end
function Movement:attackForward(times)
    times = times or 1
    for i = 1, times do
        while not turtle.forward() do
            turtle.attack()
            sleep(1)
        end
        if self.dir == "N" then
            self.pos.y = self.pos.y - 1
        elseif self.dir == "S" then
            self.pos.y = self.pos.y + 1
        elseif self.dir == "E" then
            self.pos.x = self.pos.x + 1
        elseif self.dir == "W" then
            self.pos.x = self.pos.x - 1
        end
    end
    return true
end
function Movement:digForward(times)
    times = times or 1
    for i = 1, times do
        while not turtle.forward() do
            turtle.dig()
            sleep(1)
        end
        if self.dir == "N" then
            self.pos.y = self.pos.y - 1
        elseif self.dir == "S" then
            self.pos.y = self.pos.y + 1
        elseif self.dir == "E" then
            self.pos.x = self.pos.x + 1
        elseif self.dir == "W" then
            self.pos.x = self.pos.x - 1
        end
    end
    return true
end
function Movement:digAttackForward(times)
    times = times or 1
    for i = 1, times do
        while not turtle.forward() do
            turtle.dig()
            turtle.attack()
            turtle.attack()
            sleep(1)
        end
        if self.dir == "N" then
            self.pos.y = self.pos.y - 1
        elseif self.dir == "S" then
            self.pos.y = self.pos.y + 1
        elseif self.dir == "E" then
            self.pos.x = self.pos.x + 1
        elseif self.dir == "W" then
            self.pos.x = self.pos.x - 1
        end
    end
    return true
end

function Movement:back(times)
    times = times or 1
    for i = 1, times do
        if turtle.back() then
            if self.dir == "N" then
                self.pos.y = self.pos.y + 1
            elseif self.dir == "S" then
                self.pos.y = self.pos.y - 1
            elseif self.dir == "E" then
                self.pos.x = self.pos.x - 1
            elseif self.dir == "W" then
                self.pos.x = self.pos.x + 1
            end
        end
    end
end
function Movement:attackBack(times)
    times = times or 1
    for i = 1, times do
        while not turtle.back() do
            self:left(2)
            turtle.attack()
            turtle.attack()
            self:left(2)
            sleep(1)
        end

        if self.dir == "N" then
            self.pos.y = self.pos.y - 1
        elseif self.dir == "S" then
            self.pos.y = self.pos.y + 1
        elseif self.dir == "E" then
            self.pos.x = self.pos.x + 1
        elseif self.dir == "W" then
            self.pos.x = self.pos.x - 1
        end
    end
    return true
end

function Movement:up()
    if turtle.up() then
        self.pos.z = self.pos.z + 1
        return true
    else
        return false
    end
end
function Movement:goUp()
    while not turtle.up() do
        sleep(1)
    end
    self.pos.z = self.pos.z + 1
    return true
end
function Movement:digUp()
    while not turtle.up() do
        turtle.digUp()
    end
    self.pos.z = self.pos + 1
    return true
end

function Movement:down()
    if turtle.down() then
        self.pos.z = self.pos.z - 1
        return true
    else
        return false
    end
end
function Movement:down()
    while not turtle.down() do
        sleep(1)
    end
    self.pos.z = self.pos.z - 1
    return true
end
function Movement:digDown()
    while not turtle.down() do
        turtle.digDown()
    end
    self.pos.z = self.pos.z - 1
    return true
end

function Movement:left(times)
    times = times or 1
    for i = 1,times do 
        if turtle.turnLeft() then
            if self.dir == "N" then
                self.dir = "W"
            elseif self.dir == "W" then
                self.dir = "S"
            elseif self.dir == "S" then
                self.dir = "E"
            elseif self.dir == "E" then
                self.dir = "N"
            end
            i = i - 1
        end
    end
end
function Movement:right(times)
    times = times or 1
    for i = 1,times do
        if turtle.turnRight() then
            if self.dir == "N" then
                self.dir = "E"
            elseif self.dir == "E" then
                self.dir = "S"
            elseif self.dir == "S" then
                self.dir = "W"
            elseif self.dir == "W" then
                self.dir = "N"
            end
            i = i - 1
        end
    end
end
function Movement:uTurn(side)
    side = side or "left"
    if side == "right" then
        self:right()
        self:forward()
        self:right()
    else
        self:left()
        self:forward()
        self:left()
    end
end

function Movement:readData()
    if not fs.exists("data/position") then
        self:createData();
    else
        local h = fs.open("data/position", "r")
        self.pos.x = tonumber(h.readLine())
        self.pos.y = tonumber(h.readLine())
        self.pos.z = tonumber(h.readLine())
        self.dir = h.readLine()
        h.close()
        return true
    end
end
function Movement:saveData()
    if not fs.exists("data/position") then
        self:createData()
    else
        local h = fs.open("data/position", "w")
        h.writeLine(self.pos.x)
        h.writeLine(self.pos.y)
        h.writeLine(self.pos.z)
        h.writeLine(self.dir)
        h.close()
        return true
    end
end
function Movement:createData()
    fs.write("(Save) Couldn't find the data/position file, make one? Y/N")
    answer = io.read()
    if answer:lower() == "y" then
        print("creating data/position file")
        local h = fs.open("data/position", "w")
        h.writeLine(self.pos.x)
        h.writeLine(self.pos.y)
        h.writeLine(self.pos.z)
        h.writeLine(self.dir)
        h.close()
    elseif answer:lower() == "n" then
        error("Couldn't find the data/position and didn't want to make one")
    end
end