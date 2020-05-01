-- Edit
local interfaceStackCount = 7
local sleepTime = 30
local interfaceDeactivationTime = 1

local reactorSide = 'front'
local invertedToggleBusSide = 'bottom'

-- Don't edit
local reactor = peripheral.wrap(reactorSide)
local interface = peripheral.wrap('bottom')

function getReactorEmpty()
	local reactorAllStacks = reactor.getAllStacks()
	for _, _ in pairs(reactorAllStacks) do
		return false
	end
	return true
end

function getInterfaceFull(stacks)
	local stacks = stacks or 8
	local data
	local filledStacks = 8
	for i = 1, 8 do
		data = interface.getStackInSlot(i)
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

function suckInterface()
	rs.setOutput(invertedToggleBusSide, true)
	sleep(interfaceDeactivationTime)
	for _ = 1, interfaceStackCount do
		turtle.suckDown()
	end
	rs.setOutput(invertedToggleBusSide, false)
end

function dropReactor()
	for i = 1, interfaceStackCount do
		turtle.select(i)
		turtle.drop()
	end
	turtle.select(1)
end

local reactorEmpty
local interfaceFull

while true do
	term.clear()
	term.setCursorPos(1, 1)

	reactorEmpty = getReactorEmpty()
	interfaceFull = getInterfaceFull(interfaceStackCount)

	print('reactorEmpty: ' .. tostring(reactorEmpty))
	print('interfaceFull: ' .. tostring(interfaceFull))

	if reactorEmpty and interfaceFull then
		print('Sucking from the interface...')
		suckInterface()
		print('Dropping in the reactor...')
		dropReactor()
	end

	local _, y = term.getCursorPos()
	for t = sleepTime, 1, -1 do
		term.setCursorPos(1, y)
		print('Sleeping ' .. t .. ' seconds...    ')
		sleep(1)
	end
end