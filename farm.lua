-- Edit
local seedName	  = 'minecraft:wheat_seeds'
local length	  = 16
local width		  = 16
local maxDrops	  = 1 + 3
local maxGrowth   = 7

-- Don't edit
local dumpFreq	  = math.floor(64 / maxDrops)
local searchSeeds = true

function getSlot(name)
	if type(name) ~= 'string' then error("getSlot expects a string for 'name'! Got: " .. type(name)) end
	local slot
	for i = 1, 16 do
		slot = turtle.getItemDetail(i)
		if slot and slot.name == name then
			return i
		end
	end
	return false
end

function getFreeSlots()
	local free = 0
	for i = 1, 16 do
		if turtle.getItemCount(i) == 0 then
			free = free + 1
		end
	end
	return free
end

function dump()
	if getFreeSlots < 2 then
		turtle.select(enderChestSlot)
		turtle.place()
		for i = 1, 16 do
			if i ~= enderChestSlot and i ~= seedSlot then
				turtle.select(i)
				turtle.drop(i)
			end
		end
		turtle.select(enderChestSlot)
		turtle.dig()
	end
end

function run()
	turtle.select(seedSlot)
	for w = 1, width do
		for l = 1, length do
			if (w * l + l) % dumpFreq == 0 then
				dump()
			end
			
			-- Break fully grown crops.
			local cropBelow, crop = turtle.inspectDown()
			
			-- Try to till dirt/harvest crop.
			turtle.digDown()

			-- If harvested crop.
			if cropBelow and crop.metadata == maxGrowth then
				searchSeeds = true
			end
			
			-- When there are no seeds to place.
			if searchSeeds and not turtle.placeDown() and not cropBelow then
				if getSlot(seedName) then
					turtle.select(i)
				else
					-- Don't try finding seeds this run.
					searchSeeds = false
				end
			end
			
			if l < length then
				turtle.forward()
			end
		end
		
		-- u-turn
		if w % 2 ~= 0 then
			turtle.turnRight()
			turtle.forward()
			turtle.turnRight()
		else
			turtle.turnLeft()
			turtle.forward()
			turtle.turnLeft()
		end
	end
end

local enderChestSlot = getSlot('EnderStorage:enderChest')
local seedSlot = getSlot(seedName)

while true do
	term.clear()
	print('Running...')
	run()
	print('Sleeping 60 seconds...')
	sleep(60)
end