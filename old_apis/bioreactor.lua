-- Edit
local fuelTypes = 6
local sleepTime = 20 -- 20 minimum for the interface to restock.
local interfaceDeactivationWait = 1

local reactorSide = 'front'
local invertedToggleBusSide = 'bottom'

-- Don't edit
local interface = peripheral.wrap('bottom')

function foo()
	return peripheral.call(reactorSide, 'getAllStacks')
end

function getReactorEmpty()
	local success, reactorAllStacks = pcall(foo)
	if success then
		for _, _ in pairs(reactorAllStacks) do
			return false
		end
	else

	end
	return true
end

function getInterfaceFull(stacks)
	local stacks = stacks or 8
	local filledStacks = 8
	for i = 1, 8 do
		local data = interface.getStackInSlot(i)
		if data == nil then
			filledStacks = filledStacks - 1
		elseif data.qty < 64 then
			return false
		end
	end
	if filledStacks >= stacks then
		return true
	else
		return false
	end
end

function inventoryEmpty()
	for i = 1, 16 do
		if turtle.getItemCount(i) ~= 0 then
			return false
		end
	end
	return true
end

function suckInterface()
	print('Sucking items out of the interface...')
	rs.setOutput(invertedToggleBusSide, true)
	sleep(interfaceDeactivationWait)
	for _ = 1, fuelTypes do
		turtle.suckDown()
	end
	rs.setOutput(invertedToggleBusSide, false)
end

function dropReactor()
	print('Dropping items in a reactor...')
	for i = 1, fuelTypes do
		turtle.select(i)
		turtle.drop()
	end
	turtle.select(1)
end

function visitReactors()
	print('Visiting the reactors...')

	if getReactorEmpty() then
		dropReactor()
		return 0
	end

	for moved = 1, 7 do
		turtle.turnLeft()
		turtle.forward()
		turtle.turnRight()
		-- Prevents turtle crashing, because the turtle needs 0.4s to finish turning.
		sleep(0.5)
		if getReactorEmpty() then
			dropReactor()
			return moved
		end
	end
	return 7
end

function returnFromVisitReactors(moved)
	print('Returning to the interface...')
	if moved > 0 then
		turtle.turnRight()
		for i = 1, moved do
			turtle.forward()
		end
		turtle.turnLeft()
	end
end

function hibernate()
	local _, y = term.getCursorPos()
	for t = sleepTime, 1, -1 do
		term.setCursorPos(1, y)
		print('Sleeping ' .. t .. ' seconds...    ')
		sleep(1)
	end
end

while true do
	term.clear()
	term.setCursorPos(1, 1)

	local go = true
	if inventoryEmpty() then
		if getInterfaceFull(fuelTypes) then
			suckInterface()
		else
			go = false
		end
	end

	if go then
		local moved = visitReactors()
		returnFromVisitReactors(moved)
	end

	hibernate()
end