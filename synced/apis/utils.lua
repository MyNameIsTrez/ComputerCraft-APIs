local w, h = term.getSize()


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
function pythagoras(x1, y1, x2, y2)
	return math.sqrt((x1 - x2)^2 + (y1 - y2)^2)
end

-- Rounds a number to a specified number of decimals.
-- If the number of decimals isn't provided, it'll round to 0 decimals.
-- Written with help from Brutal_McLegend.
function round(input, decimals)
	decimals = decimals or 0
	if decimals < 0 then error("utils.round(n, d) doesn't take a negative decimal count") end
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

-- Yields when more than t seconds have passed since the last yield.
-- t is 4 by default.
local previous_time = 0
function try_yield(t)
	t = t or 4
	local current_time = os.clock()
	if current_time - previous_time > t then
		previous_time = current_time
		yield()
	end
end

-- Prevents the program from crashing after 5 seconds.
-- Executes faster than 'sleep(0.05)'
function yield()
	os.queueEvent('yield')
	os.pullEvent('yield')
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
function print_table(tab, recursive, depth)
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
		try_yield() -- Need to yield, as the next bit of code can be recursive.
		
		local spacingCount = longestKey - #tostring(key) -- How many spaces are added between the key and value.
		print(
			string.rep('    ', depth).. -- Shift tables that are deep inside the original table.
			string.rep(' ', spacingCount)..
			tostring(key)..
			' | '..
			tostring(type(value) == 'table' and 'table' or value)
		)
		
		local isTable = type(value) == 'table'
		local valueIsTable = (tab == value)
		if recursive and isTable and not valueIsTable then
			print_table(value, recursive, depth + 1) -- Go into the table.
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
	-- If no offsetX or offsetY has been specified,
	-- use the current cursor position as the top-left corner of the frame.
	local curX, curY = term.getCursorPos()
	local offsetX = offsetX or curX
	local offsetY = offsetY or curY

	-- Saves the top-left corner of the frame.
	local offsetStartX = offsetX
	local offsetStartY = offsetY

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

	-- Reset the cursor position to the top-left corner of the frame.
	term.setCursorPos(offsetStartX, offsetStartY) -- Not sure if necessary.

	if type(sleepTime) == 'number' then
		sleep(sleepTime)
	elseif sleepTime == 'tryYield' then
		try_yield()
	end
end

--[[
Arithmetic right shift (>>)
The arithmetic right shift is exactly like the logical right shift, except instead of padding with zero,
it pads with the most significant bit. This is because the most significant bit is the sign bit,
or the bit that distinguishes positive and negative numbers. By padding with the most significant bit,
the arithmetic right shift is sign-preserving.
]]--
function barshift(n, bits)
	if n < 0 then
		n = n and bit.brshift(-1, 1)
		-- print_table(bit.tobits(n))
		n = bit.brshift(n, bits)
		-- print_table(bit.tobits(n))
		n = n or bit.blshift(1, 31)
		-- print_table(bit.tobits(n))
	else
		n = bit.brshift(n, bits)
		-- print_table(bit.tobits(n))
	end
	return n
end

-- Return if an element is inside of a table.
function table_contains(tab, element)
	for _, val in pairs(tab) do
		if type(val) == 'table' and val ~= tab then
			return valueInTable(val, element)
		end
		if val == element then
			return true
		end
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

function vectorRandom2D()
	return vector.new(math.random() * 2 - 1, math.random() * 2 - 1)
end

function getKeys(tab)
	local keys = {}
	for k, _ in pairs(tab) do table.insert(keys, k) end
	return keys
end

function pathJoin(...)
	local path
	for _, string in ipairs(arg) do
		if path == nil then
			path = string
		else
			path = path .. "/" .. string
		end
	end
	return path
end

function matchBetween(str, startStr, endStr)
	local tab = {}
	local i = 1
	for capture in str:gmatch(startStr .. "(.-)" .. endStr) do
		tab[i] = capture
		i = i + 1
	end
	return tab
end

function starts_with(str, start)
	return str:sub(1, #start) == start
end


function ends_with(str, ending)
	return ending == "" or str:sub(-#ending) == ending
end


function sort_alphabetically(tab)
	table.sort(tab, function(a, b) return string.lower(a) < string.lower(b) end)
end


function debug_write_random()
	local w, h = term.getSize()
	debug_write(math.random(), h)
end


-- arg can be a string or table and will be printed at (1, debug_y)
function debug_write(arg, debug_y)
	local str
	if type(arg) == "table" then
		str = textutils.serialize(arg)
	else
		str = arg
	end
	
	local x, y = term.getCursorPos()
	
	term.setCursorPos(1, debug_y)
	write(str)
	
	term.setCursorPos(x, y)
end


function save_file(path, str)
	local h = fs.open(path, "w")
	h.write(str)
	h.close()
end


function shuffle_table(tab, n)
	local length = #tab
	local n = n or length
	for i = 1, n do
		local ri = math.random(length)
		local temp = tab[i]
		tab[i] = tab[ri]
		tab[ri] = temp
	end
end


function shallow_copy_table(t)
	local t2 = {}
	for k, v in pairs(t) do
		t2[k] = v
	end
	return t2
end


function fill_screen(char)
	local line = string.rep(char, w)
	for y = 1, h do
		term.setCursorPos(1, y)
		term.write(line)
	end
end


cursor_prompt = "> " -- TODO: More accurate variable name that makes it clear that this isn't the blinking part of the cursor.
typing_start_x = #cursor_prompt + 1 -- First typed char is at x=3.

function draw_cursor_prompt()
	write(cursor_prompt)
end


function open_and_create_missing_directories(filepath, mode)
	local parent_path = get_parent_path(filepath)
	fs.makeDir(parent_path)
	local handle = io.open(filepath, mode)
	return handle
end


function get_parent_path(filepath)
    return filepath:match("(.*[/\\])")
end