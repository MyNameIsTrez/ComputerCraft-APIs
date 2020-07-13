-- Enter 'pastebin run Ch4aSVAJ' into a computer to download all the dependencies!


local APIs = {
	"cf",
	"lualzw",
	"json",
	"website",
	-- "",
}

for _, API in ipairs(APIs) do os.loadAPI(API) end


local web = website.Website:new()

-- print("AVG POWER INJECTION:")
-- print(web:avgPowerInjection())

-- print("AVG POWER USAGE:")
-- print(web:avgPowerUsage())

print("POST AVAILABLE ITEMS AS JSON:")
print(web:POSTAvailableItems())

-- local success, count = web:craft("minecraft:planks" .. " " .. "2", 50)
-- print("Crafting: " .. tostring(success) .. ", " .. count)

-- print("AVAILABLE ITEMS STR:")
-- print(web:availableItemsStr())

-- print("USER ON WEBSITE:")
-- print(web:userOnWebsite())

-- local bytes =  web:availableItemsBytes()
-- local data = "bytes=" .. bytes .. "&test=123"

-- local availableItems = web:availableItems()
-- print("#availableItems: " .. tostring(#availableItems))
-- local json = json.encode(availableItems)
-- print("#json: " .. tostring(#json))
-- local data = "data=" .. json
-- print("#data: " .. tostring(#data))

-- print("POST:")
-- print(web:POST(data))

-- print("FLUID:")
-- print(web:tankInfoStr())