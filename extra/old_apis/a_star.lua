-- CLASSES --------------------------------------------------------

Simulation = {

	new = function(self, settings)
		local self = {
			-- Passed settings.
			entityCount = settings.entityCount,                               -- Default is 2.
			diagonalMoving = settings.diagonalMoving,                         -- Default is true.
			movingThroughDiagonalWalls = settings.movingThroughDiagonalWalls, -- Default is false.
			noOccupyingTargetNode = settings.noOccupyingTargetNode,           -- Default is true.
			showPath = settings.showPath,                                     -- Default is true.
			showWalls = settings.showWalls,                                   -- Default is true.
			wallChance = settings.wallChance,                                 -- Where 0 is 0% and 1 is 100%. Default is 0.25.
			showClosedSet = settings.showClosedSet,                           -- Shows the nodes that have been explored by the pathing algorithm that aren't part of the final path. Default is true.

			turboSpeed = settings.turboSpeed,                                 -- If turboSpeed is true, sleepTime is ignored. Default is false.
			sleepTime = settings.sleepTime,                                   -- 0 is the same as 0.05, which is the minimum. Default is 0.15.

			setupSleep = settings.setupSleep,                                 -- After generating the map, wait setupSleepTime seconds before starting to move the entity so you can see the path clearly. Default is false.
			setupSleepTime = settings.setupSleepTime,                         -- Default is 5.

			entityIcon = settings.entityIcon,                                 -- Default is "e".
			entityPathIcon = settings.entityPathIcon,                         -- Default is ".".
			wallIcon = settings.wallIcon,                                     -- Default is "O".
			closedSetIcon = settings.closedSetIcon,                           -- Default is "|".

			-- Extra.
			entities = {},
			nodes = {},
			
			width,
			height,
		}
		
		setmetatable(self, {__index = Simulation})

		local width, height = term.getSize()
		width = width - 1 -- Not sure if necessary.
		self.width = width
		self.height = height

		return self
	end,

	createNodes = function(self)
		for x = 1, self.width do
			self.nodes[x] = {}
			for y = 1, self.height do
				local wall = math.random() < self.wallChance
				if not wall then
					self.nodes[x][y] = Node:new(x, y, self.diagonalMoving, self.movingThroughDiagonalWalls)
				elseif self.showWalls then
					shape.point(vector.new(x, y), self.wallIcon)
				end
			end
			cf.tryYield()
		end

		for x, _ in pairs(self.nodes) do
			for _, node in pairs(self.nodes[x]) do
				node:setNeighborNodes(self.nodes, self.width, self.height)
			end
		end
	end,

	createEntities = function(self)
		for id = 1, self.entityCount do
			local x = math.random(self.width)
			local y = math.random(self.height)

			-- Makes sure the entity doesn't spawn inside a wall.
			while self.nodes[x][y] == nil do
				x = math.random(self.width)
				y = math.random(self.height)
			end
			
			-- !!! This code should also check if the entity doesn't spawn inside another entity !!!
			self.entities[id] = Entity:new(id, x, y, self.entityIcon, self.entityPathIcon, self.noOccupyingTargetNode, self.showClosedSet, self.closedSetIcon)
		end
	end,

	debugShowNodesNeighbors = function(self)
		for x, _ in pairs(self.nodes) do
			for y, node in pairs(self.nodes[x]) do
				if node then
					shape.point(vector.new(x, y), #node.neighborNodes)
				end
			end
		end
		term.setCursorPos(1, 1)
	end,

	reachedTarget = function(self, entity)
		if self.noOccupyingTargetNode then
			if entity.pathStep == #entity.path then
				entity:die(self.entities)
			end
		end
	end,

	setup = function(self, settings)
		-- shell.run("apis/aStar") -- No clue why this would need to be here when os.loadAPI() has already been called.

		-- term.clear()

		self:createNodes()

		self:createEntities()
		self.entities[1].targetEntityId = 2

		-- self:debugShowNodesNeighbors()

		for _, entity in pairs(self.entities) do
			entity:show()
		end

		-- Prevents the enemy:pathfind() from being one move behind entity.move() in main().
		for _, entity in pairs(self.entities) do
			if entity.targetEntityId then
				entity:pathfind(self.entities, self.nodes)
				entity:setPath(self.entities, self.nodes)
				if self.showPath then
					entity:showPath()
				end
			end
		end
	end,

	main = function(self, settings)
		if self.setupSleep then
			sleep(self.setupSleepTime)
		end

		while true do
			if not rs.getInput(cfg.disableSide) then
				for _, entity in pairs(self.entities) do
					if entity.targetEntityId then
						self:reachedTarget(entity)
						entity:move()
					end
					entity:show()
				end
				
				if self.turboSpeed then
					cf.tryYield()
				else
					sleep(self.sleepTime)
				end
			else
				sleep(1)
			end
		end
	end,

}

Entity = {

	new = function(self, id, x, y, icon, pathIcon, noOccupyingTargetNode, showClosedSet, closedSetIcon)
		local startingValues = {
			id = id,
			pos = vector.new(x, y),
			icon = icon,
			pathIcon = pathIcon,
			noOccupyingTargetNode = noOccupyingTargetNode,
			showClosedSet = showClosedSet,
			closedSetIcon = closedSetIcon,

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

	pathfind = function(self, entities, nodes)
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
				if self.showClosedSet then
					-- if not (furthestNode.pos == self.pos) then -- I can't get this to work.
					if not (furthestNode.pos.x == self.pos.x and furthestNode.pos.y == self.pos.y) then
						shape.point(vector.new(furthestNode.pos.x, furthestNode.pos.y), self.closedSetIcon)
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
    	return (dx + dy) + (math.sqrt(2) - 2) * math.min(dx, dy)
	end,

	setPath = function(self, entities, nodes)
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

		if self.noOccupyingTargetNode then
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

	die = function(self, entities)
		for _, pathNode in pairs(self.path) do
			pathNode.parentNode[self.id] = nil
		end
		self:unshow()
		table.remove(entities, self.id)
	end,

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

	setNeighborNodes = function(self, nodes, width, height)
		local notTopBorder = self.pos.y > 1
		local notLeftBorder = self.pos.x > 1
		local notBottomBorder = self.pos.y < height
		local notRightBorder = self.pos.x < width

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
	end,

}