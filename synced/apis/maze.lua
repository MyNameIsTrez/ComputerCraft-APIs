local cardinal_x = { 0, 1, 0, -1 }
local cardinal_y = { -1, 0, 1, 0 }


function get_solved_maze(width, height, start_x, start_y)
	local unsolved_maze = get_unsolved_maze(width, height)
	return solve_cell(unsolved_maze, width, height, start_x, start_y)
end


function get_unsolved_maze(width, height)
	local maze = {}
	for y = 1, height do
		maze[y] = {}
		local row = maze[y]
		for x = 1, width do
			row[x] = {
				visited = false,
				neighbors_visited = {},
			}
		end
	end
	return maze
end

--[[	
	3b. Remove the wall between the current cell and the chosen cell.
	3c. Invoke the routine recursively for a chosen cell.
]]--
-- Algorithm: https://www.wikiwand.com/en/Maze_generation_algorithm#/Recursive_implementation
function solve_cell(unsolved_maze, width, height, x, y)
	local cell = unsolved_maze[y][x] -- 1. Given a current cell as a parameter.
	cell.visited = true -- 2. Mark the current cell as visited.

	-- 3. While the current cell has any unvisited neighbour cells.
	local neighbors = { 1, 2, 3, 4 }
	utils.shuffle_table(neighbors)

	for i = 1, 4 do -- 3a. Choose one of the unvisited neighbours.
		local ri = neighbors[i]
		local x2 = x + cardinal_x[ri]
		local y2 = y + cardinal_y[ri]

		if x2 >= 1 and y2 >= 1 and x2 <= width and y2 <= height then
			local neighbor = unsolved_maze[y2][x2]
			if not neighbor.visited then
				table.insert(cell.neighbors_visited, ri)
				solve_cell(unsolved_maze, width, height, x2, y2)
			end
		end
	end

	return unsolved_maze
end