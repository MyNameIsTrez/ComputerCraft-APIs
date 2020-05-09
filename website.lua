-- Enter 'pastebin run Ch4aSVAJ' into a computer to download all the dependencies!


Website = {
	websiteURL = "https://hookb.in/wNa0ZdyDjRSLQYzYDnnW",
}


function Website:new()
	setmetatable({}, Website)
	self:wrapBridge()
	self:wrapTank()
	self:wrapEnderTank()
	return self
end


function Website:wrap(name, func)
    local sides = peripheral.getNames()
    for _, side in ipairs(sides) do
        if peripheral.getType(side) == name then
            return func(side)
        end
	end
end


function Website:wrapBridge()
	self:wrap("meBridge", function(side) self.bridge = peripheral.wrap(side) end)
end

function Website:wrapTank()
	self:wrap("openblocks_tank", function(side) self.tank = peripheral.wrap(side) end)
end

function Website:wrapEnderTank()
	self:wrap("ender_tank", function(side) self.enderTank = peripheral.wrap(side) end)
end


function Website:getTankInfo()
	if not self.tank then error("You need to wrap the Tank from OpenBlocks first!") end
	self.tankInfo = self.tank.getTankInfo()
	return self.tankInfo
end

function Website:getTankInfoStr()
	self.tankInfoStr = textutils.serialize(self:getTankInfo())
	return self.tankInfoStr
end


function Website:getEnderTankInfo()
	if not self.enderTank then error("You need to wrap the Ender Tank from EnderStorage first!") end
	self.enderTankInfo = self.enderTank.getTankInfo()
	return self.enderTankInfo
end

function Website:getEnderTankInfoStr()
	self.enderTankInfoStr = textutils.serialize(self:getEnderTankInfo())
	return self.enderTankInfoStr
end


function Website:getAvailableItems()
	if not self.bridge then error("You need to wrap the ME Bridge from Peripherals++ first!") end
	self.availableItems = self.bridge.getAvailableItems()
	return self.availableItems
end

function Website:getAvailableItemsStr()
	self.availableItemsStr = textutils.serialize(self:getAvailableItems())
	return self.availableItemsStr
end


-- Assumes every char is encoded in ASCII!
function Website:getAvailableItemsBytes()
	if not self.availableItemsStr then self:getAvailableItemsStr() end
	self.availableItemsBytes = string.len(self.availableItemsStr)
	return self.availableItemsBytes
end


function Website:privateGetCraftingCount()
	local count = 0
	for _, v in ipairs(self.bridge.getCraftingCPUs()) do
		if v.busy then
			count = count + 1
		end
	end
	return count
end

-- Useful, because it returns whether the crafting is being done
-- and how many are doing it. peripheral.craft() doesn't return anything.
function Website:craft(name, count)
	if type(name) ~= "string" then
		error("Website:craft() expected a string as the 1st arg, got " .. type(name) .. ".", 2)
	elseif type(count) ~= "number" then
		error("Website:craft() expected a number as the 2nd arg, got " .. type(count) .. ".", 2)
	end
	local countStart = self:privateGetCraftingCount()
	self.bridge.craft(name, count)
	sleep(0.05) -- ME system needs time to start crafting.
	local countEnd = self:privateGetCraftingCount()
	local count = countEnd - countStart
	return count > 0, count
end


function Website:privateHandleResponse(response)
	local jsonObj = json.parseObject(response.readAll())
	cf.printTable(jsonObj)
	return jsonObj.success == true
end

function Website:GETUserOnWebsite()
	local response = http.get(self.websiteURL)
	return self:privateHandleResponse(response)
end

function Website:POST(dataStr)
	if type(dataStr) ~= "string" then
		error("Website:POST() expected a string as the only arg, got " .. type(dataStr) .. ".", 2)
	end
	local response = http.post(self.websiteURL, dataStr)
	return self:privateHandleResponse(response)
end

function Website:POSTAvailableItems()
	local availableItems = self:getAvailableItems()
	local jsonEncoded = json.encode(availableItems)
	local compressed = lualzw.compress(jsonEncoded)
	compressed:gsub('=', string.rep('a', 10))
	compressed:gsub('?', string.rep('b', 10))
	-- print(compressed)
	local h = fs.open('data', 'w')
	h.write(compressed)
	h.close()
	local dataStr = "data=" .. compressed
	return self:POST(dataStr)
end