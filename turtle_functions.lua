-- Make sure to always point the front of this turtle south! (f: 0)

t = {
	name = '',
	x = 0,
	y = 0,
	z = 0,
	facing = 0,
	times_placed = 0,
	times_broken = 0,
	nicknames = {
		''
	}
}
 
function t:new(name, nicknames)
	setmetatable({}, t)
	self.name = name
	self.nicknames = nicknames
	return self
end

function t:mLongitudal(dir)
	if (self.facing == 0) then
		self.z = self.z + dir
	elseif (self.facing == 1) then
		self.x = self.x - dir
	elseif (self.facing == 2) then
		self.z = self.z - dir
	elseif (self.facing == 3) then
		self.x = self.x + dir
	end
end

function t:mForward(n)
	for i = 1, n do
		t:mLongitudal(1)
		turtle.forward()
	end
end

function t:mBack()
	for i = 1, n do
		t:mLongitudal(-1)
		turtle.back()
	end
end

function t:tLeft()
	if (self.facing == 0) then
		self.facing = 3
	else
		self.facing = self.facing - 1
	end
	turtle.turnLeft()
end

function t:tRight()
	if (self.facing == 3) then
		self.facing = 0
	else
		self.facing = self.facing + 1
	end
	turtle.turnRight()
end

function t:mLeft()
	if (self.facing == 0) then
		self.facing = 3
	else
		self.facing = self.facing - 1
	end
	turtle.turnLeft()
	t:mLongitudal(1)
	turtle.forward()
end

function t:mRight()
	if (self.facing == 3) then
		self.facing = 0
	else
		self.facing = self.facing + 1
	end
	turtle.turnRight()
	t:mLongitudal(1)
	turtle.forward()
end

function t:straightZigZag(n)
	for i = 1, n/2 do
		t:placeDown()
		t:mRight()
		t:placeDown()
		t:mLeft()
		t:placeDown()
		t:mLeft()
		t:placeDown()
		t:mRight()
	end
end

function t:diagonalZigZag(direction)
	if (direction == "right") then
		for i = 1, 12 do
			t:mForward(1)
			t:placeDown()
			t:mForward(1)
			t:placeDown()
			
			t:mRight()
			t:tLeft()
			t:placeDown()
		end
	elseif (direction == "left") then
		for i = 1, 12 do
			t:mForward(1)
			t:placeDown()
			t:mForward(1)
			t:placeDown()
			
			t:mLeft()
			t:tRight()
			t:placeDown()
		end
	else
		error("You entered a wrong direction for diagonalZigZag()")
	end
end

function t:print_own_data()
	term.clear() -- clear the terminal's text
	term.setCursorPos(1,1) -- set the terminal's cursor to the top-left
	print('x: '..self.x..', y: '..self.y..', z: '..self.z)
	print('times_placed: '..self.times_placed..', times_broken: '..self.times_broken)
end

function t:place()
	self.times_placed = self.times_placed + 1
	turtle.place()
end

function t:placeDown()
	self.times_placed = self.times_placed + 1
	turtle.placeDown()
end

function t:dig()
	self.times_broken = self.times_broken + 1
	turtle.dig()
end