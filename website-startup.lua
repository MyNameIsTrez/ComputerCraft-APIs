-- Enter 'pastebin run Ch4aSVAJ' into a computer to download all the dependencies!


local APIs = {
	"cf",
	"lualzw",
	"json",
	"website",
	-- "",
}

for _, API in ipairs(APIs) do os.loadAPI(API) end


local website = website.Website:new()


print("POST AVAILABLE ITEMS AS JSON:")
print(website:POSTAvailableItems())

-- local success, count = website:craft("minecraft:planks" .. " " .. "2", 50)
-- print("Crafting: " .. tostring(success) .. ", " .. count)

-- print("AVAILABLE ITEMS STR:")
-- print(website:getAvailableItemsStr())

-- print("GET:")
-- print(website:GETUserOnWebsite())

-- local bytes =  website:getAvailableItemsBytes()
-- local data = "bytes=" .. bytes .. "&test=123"

-- local availableItems = website:getAvailableItems()
-- print("#availableItems: " .. tostring(#availableItems))
-- local json = json.encode(availableItems)
-- print("#json: " .. tostring(#json))
-- local data = "data=" .. json
-- print("#data: " .. tostring(#data))

-- print("POST:")
-- print(website:POST(data))

-- print("FLUID:")
-- print(website:getTankInfoStr())