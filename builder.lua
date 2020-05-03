sleep(5)

local dataHandle = fs.open('data', 'r')
local dataStr = dataHandle.readAll()
local data = textutils.unserialize(dataStr)

local cols, rows, layers = #data, #data[1], #data[1][1]
print('Cols: ' .. cols)
print('Rows: ' .. rows)
print('Layers: ' .. layers)

function uTurn(dir)
	if dir == 'left' then
		turtle.turnLeft()
		turtle.forward()
		turtle.turnLeft()
	elseif dir == 'right' then
		turtle.turnRight()
		turtle.forward()
		turtle.turnRight()
	end
end

function build(dir)
	local place

	turtle.up()

	for layer = 1, layers do
		for row = 1, rows do
			for col = 1, cols do
				if layer % 2 == 1 then
					place = data[col][row][layer].place
				else
					place = data[col][rows - row + 1][layer].place
				end

				if place then turtle.placeDown() end

				if col ~= cols then turtle.forward() end
			end

			if row ~= rows then
				if rows % 2 == 0 and layer % 2 == 0 then
					if row % 2 == dir then
						uTurn('left')
					else
						uTurn('right')
					end
				else
					if row % 2 == dir then
						uTurn('right')
					else
						uTurn('left')
					end
				end
			end
		end

		turtle.up()
		turtle.turnLeft()
		turtle.turnLeft()
	end
end

build(1)