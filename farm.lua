-- Edit
local seedName  = 'minecraft:wheat_seeds'
local length	= 96
local width	    = 13
local maxDrops  = 1 + 3
local maxGrowth = 7

-- Don't edit
local dumpFreq	  = math.floor(64 / maxDrops)
local searchSeeds = true
local enderChestSlot
local seedSlot

function getSlot(name)
	if type(name) ~= 'string' then error("getSlot expects a string for 'name'! Got: " .. type(name)) end
	local slot
	for i = 1, 16 do
		slot = turtle.getItemDetail(i)
		if slot and slot.name == name then
			return i
		end
	end
	return nil
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
	if getFreeSlots() < 2 then
		turtle.select(enderChestSlot)
		turtle.placeUp()
		for i = 1, 16 do
			if i ~= enderChestSlot and i ~= seedSlot then
				turtle.select(i)
				turtle.dropUp()
			end
		end
		turtle.select(enderChestSlot)
		turtle.digUp()
		if seedSlot then
			turtle.select(seedSlot)
		else
			-- Select a slot that isn't the ender chest slot.
			turtle.select((enderChestSlot + 1) % 16)
		end
	end
end

function run()
	for w = 1, width do
		for l = 1, length do
			if (w * l + l) % dumpFreq == 0 then
				dump()
			end
			
			-- Break fully grown crops.
			local cropBelow, crop = turtle.inspectDown()
			
			-- Till dirt.
			if not cropBelow then
				turtle.digDown()
			end

			-- If harvestable crop, harvest it.
			if cropBelow and crop.metadata == maxGrowth then
				turtle.digDown()
				searchSeeds = true
			end
			
			-- When there are no seeds to place.
			if searchSeeds and not turtle.placeDown() then
				local seedSlot = getSlot(seedName)
				if seedSlot then
					turtle.select(seedSlot)
					turtle.placeDown()
				else
					-- Don't try finding seeds this run, unless a crop will be harvested.
					searchSeeds = false
				end
			end
			
			if l < length then
				turtle.forward()
			end
		end
		
		if w ~= width then
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
		else
			-- Head back.
			if w % 2 ~= 0 then
				turtle.turnRight()
				turtle.turnRight()
				for _ = 1, length - 1 do
					turtle.forward()
				end
			end

			turtle.turnRight()
			for _ = 1, width - 1 do
				turtle.forward()
			end
			turtle.turnRight()
		end
	end
end

enderChestSlot = getSlot('EnderStorage:enderChest')

if not enderChestSlot then
	error('You need to insert an ender chest!')
end

seedSlot = getSlot(seedName)

if seedSlot then
	turtle.select(seedSlot)
end

while true do
	term.clear()
	term.setCursorPos(1, 1)
	print('Running...')
	run()
	print('Sleeping 60 seconds...')
	sleep(60)
end