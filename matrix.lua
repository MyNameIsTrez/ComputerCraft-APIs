function matMul(a, b)
	local rowsA, colsA = #a, #a[1]
	local rowsB, colsB = #b, #b[1]
	
	if colsA ~= rowsB then
		error('Columns of A must match rows of B. matMul(a, b)', 2)
	end
	
	-- rowsA x colsB
	local result = {}
	for i = 1, rowsA do
		result[i] = {}
		for j = 1, colsB do
			local sum = 0
			for k = 1, colsA do -- colsA or rowsB
				sum = sum + a[i][k] * b[k][j]
			end
			result[i][j] = sum
		end
	end
	
	return result
end

function matPrint(m)
	local rows, cols = #m, #m[1]
	print(tostring(rows) .. 'x' .. tostring(cols))
	print('----------------')
	
	for i = 1, rows do
		for j = 1, cols do
			write(tostring(m[i][j]) .. ' ')
		end
		print()
	end
	print()
end

function vecToMat(v)
	local m = {}
	for i = 1, 3 do
		m[i] = {}
	end
	m[1][1] = v.x
	m[2][1] = v.y
	m[3][1] = v.z
	return m
end

function matToVec(m)
	if #m > 2 then
		return vector.new(m[1][1], m[2][1], m[3][1])
	else
		return vector.new(m[1][1], m[2][1])
	end
end