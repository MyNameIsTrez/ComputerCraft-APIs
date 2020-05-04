-- Configurable.
local dir = 1

-- Not configurable.

-- Common Functions
if not fs.exists("cf") then
    shell.run("pastebin", "get", "p9tSSWcB", "cf")
end
os.loadAPI("cf")

-- Movement
if not fs.exists("movementApi") then
    shell.run("pastebin", "get", "yykL6u8N", "movementApi")
end
os.loadAPI("movementApi")

local mvmt = movementApi.Movement:new(vector.new(), "e")

local dataHandle = fs.open("data", "r")
local dataStr = dataHandle.readAll()
local data = textutils.unserialize(dataStr)

function copy(obj)
    if type(obj) ~= "table" then
        return obj
    end
    local res = {}
    for k, v in pairs(obj) do
        res[copy(k)] = copy(v)
    end
    return res
end

local x_tab = copy(data.x)
local y_tab = copy(data.y)
local z_tab = copy(data.z)

local zx_tab = {}
for i = 1, #x_tab do
	local z = z_tab[i]
	if type(zx_tab[z]) ~= 'table' then
		zx_tab[z] = {}
	end
	local x = x_tab[i]
	zx_tab[z][#zx_tab[z] + 1] = x
end

local zy_tab = {}
for i = 1, #y_tab do
	local z = z_tab[i]
	if type(zy_tab[z]) ~= 'table' then
		zy_tab[z] = {}
	end
	local y = y_tab[i]
	zy_tab[z][#zy_tab[z] + 1] = y
end

if not (#x_tab == #y_tab and #y_tab == #z_tab) then
    error("The number of provided x, y and z coordinates don't match!")
end

term.clear()
term.setCursorPos(1, 2)
print("Going to:")

for z, _ in ipairs(zx_tab) do
	term.setCursorPos(1, 5)
	print("z: " .. z .. "        ")
    mvmt:goToZ(z)
    for i = 1, #zx_tab[z] do
		local x = zx_tab[z][i]
		local y = zy_tab[z][i]
        term.setCursorPos(1, 1)
		print("Blocks left: " .. 1 .. "        ")
		term.setCursorPos(1, 3)
		print("x: " .. x .. "        ")
		print("y: " .. y .. "        ")
        mvmt:goToX(x)
		mvmt:goToY(y)
		turtle.placeDown()
	end
end