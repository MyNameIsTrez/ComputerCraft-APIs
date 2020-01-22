-- README --------------------------------------------------------

-- Collection of LUA functions I commonly use.

-- NOT EDITABLE VARIABLES --------------------------------------------------------

local previousClock = 0
 
-- FUNCTIONS --------------------------------------------------------

function clamp(n, min, max)
	if (n < min) then
		return min
	elseif (n > max) then
		return max
	else
		return n
	end
end

function randomFloat(min, max)
	if (max) then
		return min + math.random() * (max - min)
	else
		-- min means max when only one argument is provided
		return math.random() * min
	end
end

function pythagoras(a, b)
	return math.sqrt(a * a + b * b)
end

-- Partially written by Brutal_McLegend.
function round(_nInput, _nDecimals)
	_nDecimals = _nDecimals or 0
	if _nDecimals < 0 then error('cf.round(n, d) doesn\'t take a negative decimal count') end
	local mult = math.pow(10, _nDecimals)
    return math.floor(_nInput * mult + 0.5) / mult
end

function clearTerm()
	term.clear()
	term.setCursorPos(1, 1)
end

function magSq(vector)
	return vector.x * vector.x + vector.y * vector.y
end

function dist(a, b)
  local dx = b.pos.x - a.pos.x
  local dy = b.pos.y - a.pos.y
  return math.sqrt(dx^2 + dy^2)
end

function reverseTable(tab)
	reversedTable = {}
	for i = #tab, 1, -1 do
		reversedTable[#reversedTable + 1] = tab[i]
	end
	return reversedTable
end

function tableRemove(t, e)
	for i = 1, #t do
		if t[i] == e then
			table.remove(t, i)
			break -- Breaking is necessary, because the loop's #t max iterations has changed because t changed.
		end
	end
	return t
end

function yield()
	os.queueEvent("randomEvent")
	os.pullEvent("randomEvent")
end

-- This functions needs a global previousClock variable set to 0!
function tryYield()
    local currentClock = os.clock()
    if currentClock - previousClock > 4 then
        previousClock = currentClock
        yield()
    end
end

function map(value, minVar, maxVar, minResult, maxResult)
	local a = (value - minVar) / (maxVar - minVar)
	return (1 - a) * minResult + a * maxResult;
end

function getFileCount(folder)
	return #fs.list(folder)
end

function saveData(folder, string)	
	-- Creates a folder if it doesn't already exist.
	if not fs.exists(folder) then
		fs.makeDir(folder)
	end

	-- Creates a save file in write mode.
	local fileCount = cf.getFileCount(folder)
	local name = fileCount + 1
	local file = fs.open(folder.."/"..name, "w")

	file.write(string)
	file.close()
end

function loadData(folder, name)
	local file = fs.open(folder.."/"..name, "r")
	local string = file.readAll()
	file.close()
	return string
end

function moveCursor(cursor, key, width, height, cursorIcon)
	shape.point(vector.new(cursor.x, cursor.y), " ")
	
	if (key == "w" or key == "up") and cursor.y > 1 then
		cursor.y = cursor.y - 1
	elseif (key == "a" or key == "left") and cursor.x > 1 then
		cursor.x = cursor.x - 1
	elseif (key == "s" or key == "down") and cursor.y < height then
		cursor.y = cursor.y + 1
	elseif (key == "d" or key == "right") and cursor.x < width then
		cursor.x = cursor.x + 1
	end
	
	shape.point(vector.new(cursor.x, cursor.y), cursorIcon)
end

function printTable(tab, recursive, depth)
	recursive = not (recursive == false) -- True by default.
	depth = depth or 0 -- The depth starts at 0. Don't enter the depth when calling this function, please.
	
	-- Getting the longest key, so all printed values will line up.
	local longestKey = 1
	for key, _ in pairs(tab) do
		local keyLength = #tostring(key)
		if keyLength > longestKey then
			longestKey = keyLength
		end
	end
	
	if depth == 0 then
		print()
	end
	
	-- Print the keys and values, with extra spaces so the values line up.
	for key, value in pairs(tab) do
		yield() -- Need to yield, as the next bit of code can be recursive.
		
		local spacingCount = longestKey - #tostring(key) -- How many spaces are added between the key and value.
		print(
			string.rep('    ', depth).. -- Shift tables that are deep inside the original table.
			tostring(key)..
			string.rep(' ', spacingCount)..
			', '..
			tostring(type(value) == 'table' and 'table' or value)
		)
		
		local isTable = type(value) == 'table'
		local valueIsTable = (tab == value)
		if recursive and isTable and not valueIsTable then
			printTable(value, recursive, depth + 1) -- Go into the table.
		end
	end
	
	if depth == 0 then
		print()
	end
end

function lerp(val1, val2, val3)
  local difference = val2 - val1
  local extra = val3 * difference
  return val1 + extra
end

function find(str, searchedStr)
	local index
	for i = 1, #str do
		local char = str:sub(i, i)
		if char == searchedStr then
			return i
		end
	end
end

function frameWrite(str)
	term.setCursorPos(cfg.playArea.X, cfg.playArea.Y)
	write(str)
end

--[[
Arithmetic right shift (>>)
The arithmetic right shift is exactly like the logical right shift, except instead of padding with zero, it pads with the most significant bit. This is because the most significant bit is the sign bit, or the bit that distinguishes positive and negative numbers. By padding with the most significant bit, the arithmetic right shift is sign-preserving.
]]--
function barshift(n, bits)
	if n < 0 then
		n = n and bit.brshift(-1, 1)
		printTable(bit.tobits(n))
		n = bit.brshift(n, bits)
		printTable(bit.tobits(n))
		n = n or bit.blshift(1, 31)
		printTable(bit.tobits(n))
	else
		n = bit.brshift(n, bits)
		printTable(bit.tobits(n))
	end
	return n
end

function valueInTable(tab, search)
	for key, val in pairs(tab) do
		print(val)
		if type(val) == 'table' and val ~= tab then	return valueInTable(val, search) end
		if val == search then return true end
	end
	return false
end

function getPeripheralSide()
	for _, side in ipairs(rs.getSides()) do
		if peripheral.isPresent(side) then
			return side
		end
	end
end