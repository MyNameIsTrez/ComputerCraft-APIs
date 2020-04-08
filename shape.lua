function point(pos, char)
	term.setCursorPos(pos.x, pos.y)
	
	if (char) then
		term.write(char)
	else
		error("You didn't enter a string for the 'char' argument in the function 'shape.point(pos, char)'")
	end
end

function circle(center, radius)
	-- Using radians.
	-- Because the text size is 6x9 (multiplied by the GUI Scale), we need this multiplier to make a circular shape.
	local x_fix = 1.5
	
	for i = 0, 2 * math.pi, math.pi / 180 do
		local x = math.cos(i) * radius * x_fix
		local y = math.sin(i) * radius
		local p = {
			x = center.x + x,
			y = center.y + y
		}
		point(p, "#")
	end
end

function dist(a, b)
	return math.sqrt(math.pow(a, 2) + math.pow(b, 2))
end

function line(p1, p2, icon, exact)
	local x_diff = p2.x - p1.x
	local y_diff = p2.y - p1.y
	local distance = dist(x_diff, y_diff)
	local step_x = x_diff / distance
	local step_y = y_diff / distance
	
	for i = 0, distance do
		local x = i * step_x
		local y = i * step_y
		point(vector.new(p1.x + x, p1.y + y), icon)
	end
	
	if not exact then
		point(p2, icon)
	end
end

function rectangle(p1, p2)
	local x_diff = p2.x - p1.x
	local y_diff = p2.y - p1.y
	
	local p = {
		{ -- Top-left.
			x = p1.x,
			y = p1.y
		},
		{ -- Top-right.
			x = p1.x + x_diff,
			y = p1.y
		},
		{ -- Bottom-right.
			x = p1.x + x_diff,
			y = p1.y + y_diff
		},
		{ -- Bottom-left.
			x = p1.x,
			y = p1.y + y_diff
		}
	}
	
	line(p[1], p[2]) -- Top.
	line(p[2], p[3]) -- Right.
	line(p[3], p[4]) -- Bottom.
	line(p[4], p[1]) -- Left.
end