movement = {
    pos = vector.new(0, 0, 0),
    dir = "N"
}

function movement:new(pos, dir)
    setmetatable({}, movement)
    self.pos = pos
    self.dir = dir
    return self
end

function movement:forward()
    if turtle.forward() == true then
        if self.dir == "N" then
            self.pos.y = self.pos.y - 1
        elseif self.dir == "S" then
            self.pos.y = self.pos.y + 1
        elseif self.dir == "E" then
            self.pos.x = self.pos.x + 1
        elseif self.dir == "W" then
            self.pos.x = self.pos.x - 1
        end
        return true
    else
        return false
    end
end
function movement:goForward()
    while turtle.forward() == false do
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
    return true
end
function movement:digForward()
    while turtle.forward() == false do
        turtle.dig()
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
    return true
end

function movement:back()
    if turtle.back() == true then
        if self.dir == "N" then
            self.pos.y = self.pos.y + 1
        elseif self.dir == "S" then
            self.pos.y = self.pos.y - 1
        elseif self.dir == "E" then
            self.pos.x = self.pos.x - 1
        elseif self.dir == "W" then
            self.pos.x = self.pos.x + 1
        end
        return true
    else
        return false
    end
end
function movement:goBack()
    while turtle.back() == false do
        turtle.turnLeft()
        turtle.turnLeft()
        turtle.attack()
        turtle.attack()
        turtle.turnLeft()
        turtle.turnLeft()
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
    return true
end

function movement:up()
    if turtle.up() == true then
        self.pos.z = self.pos.z + 1
        return true
    else
        return false
    end
end
function movement:goUp()
    while turtle.up() == false do
        sleep(1)
    end
    self.pos.z = self.pos.z + 1
    return true
end
function movement:digUp()
    while turtle.up() == false do
        turtle.digUp()
    end
    self.pos.z = self.pos + 1
    return true
end

function movement:down()
    if turtle.down() == true then
        self.pos.z = self.pos.z - 1
        return true
    else
        return false
    end
end
function movement:down()
    while turtle.down() == false do
        sleep(1)
    end
    self.pos.z = self.pos.z - 1
    return true
end
function movement:digDown()
    while turtle.down() == false do
        turtle.digDown()
    end
    self.pos.z = self.pos.z - 1
    return true
end

function movement:left(times)
    for i = 1,times do 
        if self.turnLeft() == false then
            i = i - 1
        end
    end
end
function movement:turnLeft()
    turtle.turnLeft()
    if self.dir == "N" then
        self.dir = "W"
    elseif self.dir == "W" then
        self.dir = "S"
    elseif self.dir == "S" then
        self.dir = "E"
    elseif self.dir == "E" then
        self.dir = "N"
    end
    return true
end

function movement:right(times)
    for i = 1,times do
        if self.turnRight() == false then
            i = i - 1
        end
    end
end
function movement:turnRight()
    turtle.turnRight()
    if self.dir == "N" then
        self.dir = "E"
    elseif self.dir == "E" then
        self.dir = "S"
    elseif self.dir == "S" then
        self.dir = "W"
    elseif self.dir == "W" then
        self.dir = "N"
    end
    return true
end

function movement:readPos()
    if not fs.exists("data/position") then
        self.createData();
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
function movement:savePos()
    if not fs.exists("data/position") then
        self.createData()
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
function movement:createData()
    io.write("(Save) Couldn't find the data/position file, make one? Y/N")
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