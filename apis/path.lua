-- "a", "/b", "foo.lua" returns "a//b/foo.lua"
function join(...)
	if arg.n == 0 then error("path.join() expects at least 1 arg.") end
	local str = arg[1]
	for i = 2, arg.n do
		str = str .. "/" .. arg[i]
	end
	return str
end

-- "a/b/foo.lua" returns "foo.lua"
function name(p)
	return fs.getName(p)
end

-- "a/b/foo.lua" returns "lua"
function extension(p)
	for i = #p, 1, -1 do
		if p:sub(i, i) == "." then
			return p:sub(i + 1, #p)
		end
	end
	return error("path.extension() got a path that doesn't contain a dot.")
end

-- "a/b/foo.lua" returns "foo"
function stem(p)
	local slash_index, dot_index, char
	for i = #p, 1, -1 do
		char = p:sub(i, i)
		if char == "." then dot_index = i end
		if char == "/" then slash_index = i break end
	end
	if not slash_index or not dot_index then
		error("path.stem() got a path that doesn't contain a slash or dot.")
	end
	return p:sub(slash_index + 1, dot_index - 1)
end

-- "/a/b/c/d" returns "/a/b/c"
function parent(p)
	for i = #p, 1, -1 do
		if p:sub(i, i) == "/" then return p:sub(1, i - 1) end
	end
	error("path.parent() got a path that doesn't contain a parent directory.")
end
