-- README --------------------------------------------------------

-- Collection of LUA functions I commonly use.

-- pastebin get p9tSSWcB cf

-- NOT EDITABLE VARIABLES --------------------------------------------------------

local previousClock = 0
 
-- FUNCTIONS --------------------------------------------------------

-- Constrains value between min and max.
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

-- Pythagorean theorem.
function pythagoras(a, b)
	return math.sqrt(a^2 + b^2)
end

-- Rounds a number to a specified number of decimals.
-- If the number of decimals isn't provided, it'll round to 0 decimals.
-- Written with help from Brutal_McLegend.
function round(input, decimals)
	decimals = decimals or 0
	if decimals < 0 then error("cf.round(n, d) doesn't take a negative decimal count") end
	local mult = math.pow(10, decimals)
    return math.floor(input * mult + 0.5) / mult
end

function clearTerm()
	term.clear()
	term.setCursorPos(1, 1)
end

-- Get the squared magnitude of a vector.
function magSq(vector)
	return vector.x * vector.x + vector.y * vector.y
end

-- Get the distance between two vectors.
function dist(a, b)
  local dx = b.pos.x - a.pos.x
  local dy = b.pos.y - a.pos.y
  return math.sqrt(dx^2 + dy^2)
end

-- Reverses the order of the elements in a table.
function reverseTable(tab)
	reversedTable = {}
	for i = #tab, 1, -1 do
		reversedTable[#reversedTable + 1] = tab[i]
	end
	return reversedTable
end

-- Removes an element from a table.
function tableRemove(t, e)
	for i = 1, #t do
		if t[i] == e then
			table.remove(t, i)
			break -- Breaking is necessary, because the loop's #t max iterations has changed, because t changed.
		end
	end
	return t
end

-- Prevents the program from crashing after 5 seconds.
-- Executes faster than 'sleep(0.05)'.
function yield()
	os.queueEvent('yield')
	os.pullEvent('yield')
end

-- Yields when more than t seconds have passed since the last yield. t is 4 by default.
function tryYield(t)
    t = t or 4
    local currentClock = os.clock()
    if currentClock - previousClock > t then
        previousClock = currentClock
        yield()
    end
end

-- Re-maps a number from one range to another.
function map(value, minVar, maxVar, minResult, maxResult)
	local a = (value - minVar) / (maxVar - minVar)
	return (1 - a) * minResult + a * maxResult;
end

-- Gets the number of files inside of a folder.
function getFileCount(folder)
	return #fs.list(folder)
end

-- Puts a string in a file inside of a folder.
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

-- Returns the data of a file as a string.
function loadData(folder, name)
	local file = fs.open(folder.."/"..name, "r")
	local string = file.readAll()
	file.close()
	return string
end

-- Moves the cursor's vector when WASD/the arrow keys have been pressed.
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

-- Prints the contents of a table much like 'textutils.serialize(tab)',
-- but the output is much more readable and it has the option to toggle recursion.
function printTable(tab, recursive, depth)
	recursive = not (recursive == false) -- True by default.
	depth = depth or 0 -- The depth starts at 0.
	
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

-- Calculates a number between two numbers at a specific increment.
function lerp(start, end_, amt)
  local difference = end_ - start
  local extra = amt * difference
  return start + extra
end

-- Written by Brutal_McLegend.
-- Writes a frame's string to the screen.
function frameWrite(string, offsetX, offsetY, sleepTime)
	local offsetX = offsetX or 1
	local offsetY = offsetY or 1

	local nWidth, _ = term.getSize();
    local sWriteArray = {};
	
    for i in string.gmatch(string, "[^\n]+") do
        local maxlen = (nWidth - offsetX);
        if string.len(i) > maxlen then
            local newstr = string.sub(i, 1, maxlen);
            table.insert(sWriteArray, newstr);
        else
            table.insert(sWriteArray, i);
        end
	end
	
    for i = 1, #sWriteArray do
        term.setCursorPos(offsetX, offsetY);
        local x, _ = term.getCursorPos();
        if not (x >= nWidth) then
            term.write(sWriteArray[i]);
            offsetY = offsetY + 1;
        end
	end
	
	-- term.setCursorPos(1, offsetY);

	if tonumber(sleepTime) == 'number' then
		sleep(sleepTime)
	elseif sleepTime == 'yield' then
		os.queueEvent('yield')
		os.pullEvent('yield')
	end
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

-- Return if an element is inside of a table.
function valueInTable(tab, search)
	for _, val in pairs(tab) do
		if type(val) == 'table' and val ~= tab then	return valueInTable(val, search) end
		if val == search then return true end
	end
	return false
end

-- Get the side of where a peripheral is located.
function getPeripheralSide(type)
	for _, side in ipairs(rs.getSides()) do
		if type then
    		if peripheral.getType(side) == type then
				return side
			end
		else
			if peripheral.isPresent(side) then
				return side
			end
		end
	end
	error('Peripheral not found.')
end

-- Get the wrapped peripheral of a monitor.
function getMonitor()
	local monitorSide = getPeripheralSide()
	return peripheral.wrap(monitorSide)
end

function openModem()
	rednet.open(getPeripheralSide('modem'))
end

-- Split a string with a string that separates its parts.
function split(str, splitter)
	local tab = {}
	for word in str:gmatch('%s*([^' .. splitter .. ']+)') do
    	tab[#tab + 1] = word
	end
	return tab
end