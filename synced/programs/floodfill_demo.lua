-- local width = 10
-- local height = 10

local w, h = term.getSize()
local width = math.ceil(w / 2)
local height = math.ceil(h / 2)

local start_x = 1
local start_y = 1

-- local start_x = math.random(width)
-- local start_y = math.random(height)

local cardinal_x = { 0, 1, 0, -1 }
local cardinal_y = { -1, 0, 1, 0 }

local maze = maze.get_solved_maze(width, height, start_x, start_y)


function draw_maze()
	utils.fill_screen("#")

	for yi = 1, height do
		for xi = 1, width do
			local x = xi * 2 - 1
			local y = yi * 2 - 1
			term.setCursorPos(x, y)
			term.write(" ")

			for _, side_visited in ipairs(maze[yi][xi].neighbors_visited) do
				term.setCursorPos(x + cardinal_x[side_visited], y + cardinal_y[side_visited])
				term.write(side_visited)
			end
		end
	end
end


function floodfill(cell_xi, cell_yi)
	local cell_x = cell_xi * 2 - 1
	local cell_y = cell_yi * 2 - 1

	term.setCursorPos(cell_x, cell_y)
	term.write("@")

	for _, side_visited in ipairs(maze[cell_yi][cell_xi].neighbors_visited) do
		sleep(0.05)

		local neighbor_xi = cell_xi + cardinal_x[side_visited]
		local neighbor_yi = cell_yi + cardinal_y[side_visited]
		local neighbor_x = cell_x + cardinal_x[side_visited]
		local neighbor_y = cell_y + cardinal_y[side_visited]
		
		term.setCursorPos(neighbor_x, neighbor_y)
		term.write("@")

		floodfill(neighbor_xi, neighbor_yi)
	end
end


term.setCursorBlink(false)

-- draw_maze()

floodfill(start_x, start_y)

term.setCursorPos(w - 2, h)