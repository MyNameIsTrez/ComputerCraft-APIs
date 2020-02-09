-- pastebin get VxsRKpDX strbits

function strToBits(str)
	local ret = {}
	local i = 0
	for c in str:gmatch(".") do
		local d = c:byte()
		for b = 0, 7 do
			i = i + 1
			ret[i] = math.floor(d / 2 ^ b) % 2
		end
	end
	return ret
end

-- Same speed and equivalent to the function above.
--[[
function strToBits(str)
    local bitTable = {}
    for i = 1, #str do
		local charBitTable = bit.tobits(str:byte(i))
		local charBitTableLen = #charBitTable
		for j = 1, charBitTableLen do
            bitTable[(i - 1) * 8 + j] = charBitTable[j]
        end
		-- Makes sure that each char has 8 bits by adding zeros.
		for j = charBitTableLen + 1, 8 do
			bitTable[(i - 1) * 8 + j] = 0
		end
    end
    return bitTable
end
]]--

function bitsToStr(bits)
	strTab = {}
	for i = 1, #bits / 8 do
		local offset = (i - 1) * 8
		local charBits = {}
		for j = 1, 8 do
			charBits[j] = bits[(i - 1) * 8 + j]
		end
		strTab[i] = string.char(bit.tonumb(charBits))
	end
	return table.concat(strTab)
end