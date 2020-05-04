-- Configurable.
local dir = 1

-- Not configurable.

-- Common Functions
if not fs.exists('cf') then
	shell.run('pastebin', 'get', 'p9tSSWcB', 'cf')
end
os.loadAPI('cf')

-- Movement
if not fs.exists('movementApi') then
    shell.run('pastebin', 'get', 'yykL6u8N', 'movementApi')
end
os.loadAPI('movementApi')

local mvmt = movementApi.Movement:new(vector.new(), 'e')

local dataHandle = fs.open('data', 'r')
local dataStr = dataHandle.readAll()
local data = textutils.unserialize(dataStr)

function shallow_copy(t)
	local t2 = {}
	for k,v in pairs(t) do
		t2[k] = v
	end
	return t2
end

local x = shallow_copy(data.x)
local y = shallow_copy(data.y)
local z = shallow_copy(data.z)

if not (#x == #y and #y == #z) then
	error("The number of provided x, y and z coordinates don't match!")
end

term.clear()

for i = 1, #x do
	term.setCursorPos(1, 1)
	print('Blocks left: ' .. #x - i + 1 .. '        ')
	-- mvmt:goTo(vector.new(x[i], y[i], z[i] + 1))
	-- mvmt:goTo(vector.new(x[i], z[i], y[i] + 1))
	-- mvmt:goTo(vector.new(y[i], x[i], z[i] + 1))
	mvmt:goTo(vector.new(y[i], z[i], x[i] + 1)) -- <--
	-- mvmt:goTo(vector.new(z[i], x[i], y[i] + 1))
	-- mvmt:goTo(vector.new(z[i], y[i], x[i] + 1)) -- <--
	turtle.placeDown()
end

for i = 1, #z do
	mvmt:goToZ(z[i] + 1)
	for j = 1, #x do
		term.setCursorPos(1, 1)
		print('Blocks left: ' .. #x - j + 1 .. '        ')

		mvmt:goToX(x[j])
		mvmt:goToY(y[j])
		turtle.placeDown()
	end
end

-- local place

-- mvmt:up()

-- for layer = 1, layers do
-- 	for row = 1, rows do
-- 		for col = 1, cols do
-- 			if layer % 2 == 1 then
-- 				place = data[col][row][layer].place
-- 			else
-- 				place = data[col][rows - row + 1][layer].place
-- 			end

-- 			if place then turtle.placeDown() end

-- 			if col ~= cols then mvmt:forward() end
-- 		end

-- 		if row ~= rows then
-- 			if rows % 2 == 0 and layer % 2 == 0 then
-- 				if row % 2 == dir then
-- 					mvmt:uTurn('left')
-- 				else
-- 					mvmt:uTurn('right')
-- 				end
-- 			else
-- 				if row % 2 == dir then
-- 					mvmt:uTurn('right')
-- 				else
-- 					mvmt:uTurn('left')
-- 				end
-- 			end
-- 		end
-- 	end

-- 	mvmt:up()
-- 	mvmt:left(2)
-- end