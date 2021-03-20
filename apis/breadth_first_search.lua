-- README --------------------------------------------------------
-- COPIED A* PATHING CODE FOR NOW; STILL NEED TO REWRITE INTO BREADTH FIRST SEARCH!



-- UNEDITABLE VARIABLES --------------------------------------------------------

entities = {}
nodes = {}



-- CLASSES --------------------------------------------------------

Entity = {

	new = function(self, id, x, y, icon, pathIcon, noOccupyingTargetNode)
		local startingValues = {
			id = id,
			pos = vector.new(x, y),
			icon = icon,
			pathIcon = pathIcon,
			noOccupyingTargetNode = noOccupyingTargetNode,

			targetEntityId,
			path,
			pathStep = 2
		}
		setmetatable(startingValues, {__index = self})
		return startingValues
	end,

	show = function(self)
		shape.point(self.pos, self.icon)
	end,

	pathfind = function(self)
		local openSet = {}
		openSet[1] = nodes[self.pos.x][self.pos.y]

		local closedSet = {}

		while true do
			if #openSet >= 1 then
				local currentIndex = 1
				for i = 1, #openSet do
					if openSet[i].f[self.id] and openSet[currentIndex].f[self.id] then
						if openSet[i].f[self.id] < openSet[currentIndex].f[self.id] then
							currentIndex = i
						end
					end
				end
				local furthestNode = openSet[currentIndex]

				-- Found a solution.
				local targetEntity = entities[self.targetEntityId]
				local targetNode = nodes[targetEntity.pos.x][targetEntity.pos.y]
				if furthestNode == targetNode then
					return
				end

				-- Found a node that will be put into the closedSet table.
				if showClosedSet then
					-- if not (furthestNode.pos == self.pos) then -- I can't get this to work.
					if not (furthestNode.pos.x == self.pos.x and furthestNode.pos.y == self.pos.y) then
						shape.point(vector.new(furthestNode.pos.x, furthestNode.pos.y), closedSetIcon)
					end
				end
				self:removeFromTable(openSet, furthestNode)
				closedSet[#closedSet + 1] = furthestNode

				for _, neighborNode in pairs(furthestNode.neighborNodes) do
					if not self:tableContains(closedSet, neighborNode) then
						local heur = self:heuristic(neighborNode, furthestNode)
						
						-- If the 'g' property exists, add it. Keep it at 0 otherwise.
						local tempG
						if furthestNode.g[self.id] then
							tempG = furthestNode.g[self.id] + heur
						else
							tempG = heur
						end

						local newPath = false
						if self:tableContains(openSet, neighborNode) then
							if tempG < neighborNode.g[self.id] then
								neighborNode.g[self.id] = tempG
								newPath = true
							end
						else
							neighborNode.g[self.id] = tempG
							openSet[#openSet + 1] = neighborNode
							newPath = true
						end

						if newPath then
							neighborNode.h[self.id] = self:heuristic(neighborNode, targetNode)
							neighborNode.f[self.id] = neighborNode.g[self.id] + neighborNode.h[self.id]
							neighborNode.parentNode[self.id] = furthestNode
						end
					end
				end
			else
				print("ERROR: A path couldn't be found.")
				sleep(100)
				return
			end
			cf.tryYield()
		end
	end,

	removeFromTable = function(self, tab, element)
		for i = #tab, 1, -1 do
			if tab[i] == element then
				table.remove(tab, i)
			end
		end
	end,

	tableContains = function(self, table, element)
		for _, value in pairs(table) do
			if value == element then
				return true
			end
		end
		return false
	end,

	heuristic = function(self, node, target)
		-- Euclidian distance.
		-- return cf.dist(node, target)
		
		-- Octile distance.
    	dx = math.abs(node.pos.x - target.pos.x)
    	dy = math.abs(node.pos.y - target.pos.y)
    	return (dx + dy) + (sqrt2 - 2) * math.min(dx, dy)
	end,

	setPath = function(self)
		-- Sets a path from itself to the target.
		local targetEntity = entities[self.targetEntityId]
		local targetNode = nodes[targetEntity.pos.x][targetEntity.pos.y]
		local childNode = targetNode
		
		local pathFromTargetEntity = {}
		pathFromTargetEntity[#pathFromTargetEntity + 1] = childNode

		while childNode.parentNode[self.id] do
			local parentNode = childNode.parentNode[self.id]
			pathFromTargetEntity[#pathFromTargetEntity + 1] = parentNode
			childNode = parentNode
		end

		self.path = cf.reverseTable(pathFromTargetEntity)

		if noOccupyingTargetNode then
			self:removeFromTable(self.path, self.path[#self.path])
		end
	end,

	showPath = function(self)
		for _, pathNode in pairs(self.path) do
			shape.point(pathNode.pos, self.pathIcon)
		end
	end,

	move = function(self)
		-- self.pathStep starts at 2, because self.pathStep 1 is where it's already standing.
		if #self.path >= self.pathStep then
			self:unshow()

			local nextNode = self.path[self.pathStep]
			self.pos.x = nextNode.pos.x
			self.pos.y = nextNode.pos.y
			nextNode.parentNode[self.id] = nil

			self.pathStep = self.pathStep + 1
		end
	end,

	unshow = function(self)
		shape.point(self.pos, " ")
	end,

	die = function(self)
		self:unshow()
		table.remove(entities, self.id)
	end

}

Node = {
 
    new = function(self, x, y, diagonalMoving, movingThroughDiagonalWalls)
        local startingValues = {
            pos = vector.new(x, y),
            diagonalMoving = diagonalMoving,
            movingThroughDiagonalWalls = movingThroughDiagonalWalls,
 
            neighborNodes = {},
            parentNode = {},
            f = {}, -- g + h.
            g = {}, -- Cost from the start.
            h = {} -- Minimum cost to the end.
        }
        setmetatable(startingValues, {__index = self})
        return startingValues
    end,
 
    setNeighborNodes = function(self)
        local notTopBorder = self.pos.y > 1
        local notLeftBorder = self.pos.x > 1
        local notBottomBorder = self.pos.y < h
        local notRightBorder = self.pos.x < w
 
        -- Top.
        if notTopBorder then
            local neighbor = nodes[self.pos.x][self.pos.y - 1]
            if neighbor then
                self.neighborNodes[#self.neighborNodes + 1] = neighbor
            end
        end
 
        -- Left.
        if notLeftBorder then
            local neighbor = nodes[self.pos.x - 1][self.pos.y]
            if neighbor then
                self.neighborNodes[#self.neighborNodes + 1] = neighbor
            end
        end
 
        -- Bottom.
        if notBottomBorder then
            local neighbor = nodes[self.pos.x][self.pos.y + 1]
            if neighbor then
                self.neighborNodes[#self.neighborNodes + 1] = neighbor
            end
        end
 
        -- Right.
        if notRightBorder then
            local neighbor = nodes[self.pos.x + 1][self.pos.y]
            if neighbor then
                self.neighborNodes[#self.neighborNodes + 1] = neighbor
            end
        end
 
        if self.diagonalMoving then
            -- Prevents the path from going diagonally through two walls.
            local neighborTopIsWall, neighborLeftIsWall, neighborBottomIsWall, neighborRightIsWall
 
            if notTopBorder then
                neighborTopIsWall = not nodes[self.pos.x][self.pos.y - 1]
            end
 
            if notLeftBorder then
                neighborLeftIsWall = not nodes[self.pos.x - 1][self.pos.y]
            end
 
            if notBottomBorder then
                neighborBottomIsWall = not nodes[self.pos.x][self.pos.y + 1]
            end
 
            if notRightBorder then
                neighborRightIsWall = not nodes[self.pos.x + 1][self.pos.y]
            end
 
 
            -- Top-left.
            if notTopBorder and notLeftBorder then
                -- Prevents the path from going diagonally through two walls.
                if not (neighborTopIsWall and neighborLeftIsWall) or self.movingThroughDiagonalWalls then
                    self.neighborNodes[#self.neighborNodes + 1] = nodes[self.pos.x - 1][self.pos.y - 1]
                end
            end
 
            -- Bottom-left.
            if notBottomBorder and notLeftBorder then
                -- Prevents the path from going diagonally through two walls.
                if not (neighborBottomIsWall and neighborLeftIsWall) or self.movingThroughDiagonalWalls then
                    self.neighborNodes[#self.neighborNodes + 1] = nodes[self.pos.x - 1][self.pos.y + 1]
                end
            end
 
            -- Bottom-right.
            if notBottomBorder and notRightBorder then
                -- Prevents the path from going diagonally through two walls.
                if not (neighborBottomIsWall and neighborRightIsWall) or self.movingThroughDiagonalWalls then
                    self.neighborNodes[#self.neighborNodes + 1] = nodes[self.pos.x + 1][self.pos.y + 1]
                end
            end
 
            -- Top-right.
            if notTopBorder and notRightBorder then
                -- Prevents the path from going diagonally through two walls.
                if not (neighborTopIsWall and neighborRightIsWall) or self.movingThroughDiagonalWalls then
                    self.neighborNodes[#self.neighborNodes + 1] = nodes[self.pos.x + 1][self.pos.y - 1]
                end
            end
        end
    end
 
}



-- FUNCTIONS --------------------------------------------------------

function createEntities()
	for id = 1, entityCount do
		local x = math.random(w)
		local y = math.random(h)

		-- Makes sure the entity doesn't spawn inside a wall.
		while nodes[x][y] == nil do
			x = math.random(w)
			y = math.random(h)
		end
		
		-- !!! This code should also check if the entity doesn't spawn inside another entity !!!
		entities[id] = Entity:new(id, x, y, entityIcon, entityPathIcon, noOccupyingTargetNode)
	end
end