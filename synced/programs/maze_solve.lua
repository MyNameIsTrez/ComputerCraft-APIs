local w, h = term.getSize()

local width = math.ceil(w / 2)
local height = math.ceil(h / 2)

-- local width = 10
-- local height = 10


local cardinal_x = { 0, 1, 0, -1 }
local cardinal_y = { -1, 0, 1, 0 }


local maze = maze.get_solved_maze(width, height)

utils.fill_screen("@")

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




term.setCursorPos(w - 2, h)