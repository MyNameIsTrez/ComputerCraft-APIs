function point(p, fill)
	term.setCursorPos(p.x, p.y)
	if (fill) then
		write(fill)
	else
		error("You didn't enter a string for the 'fill' argument in the function 'point(p, fill)'.")
	end
	--term.setCursorPos(1, 1)
end
	
function circle(center, radius)
	-- Using radians. -------------------------------------------------------
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
	
function line(p1, p2, icon)
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
	
	point(p2, icon)
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
	
function main()
	local p = {
		{ -- Middle of the screen.
			x = w / 2,
			y = h / 2 + 1
		},
		{ -- Top-right.
			x = w / 4,
			y = h / 4
		},
		{ -- Bottom-left.
			x = w / 4 * 3,
			y = h / 4 * 3
		},
		{
			x = 1,
			y = 1,
		},
		{
			x = w-1,
			y = h-1
		}
	}
	
	clear()
	local max = 24 -- Fullscreen mode.
	-- local max = 23 -- Windowed mode.
	for i = max, 0, -1 do
		circle(p[1], i)
		os.queueEvent("randomEvent")
		os.pullEvent("randomEvent")
	end
end