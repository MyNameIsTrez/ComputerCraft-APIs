-- README --------------------------------------------------------
-- Collection of LUA functions I commonly use.


 
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

function round(number, decimals)
	if (decimals == nil or decimals > 0) then
		if (decimals) then
			local p = math.pow(10, decimals)
			return math.floor(number * p) / p
		else
			return math.floor(number + 0.5)
		end
	else
		print("can't give round() a decimal number smaller than 1")
	end
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

function map(value, minVar, maxVar, minResult, maxResult)
	local a = (value - minVar) / (maxVar - minVar)
	return (1 - a) * minResult + a * maxResult;
end