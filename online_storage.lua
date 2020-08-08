function _handle_check(handle, func_name)
	if handle == nil then error(func_name .. " didn't get a response back.") end
end

-- cf.printTable(online_storage.get_metadata())
function get_metadata()
	local handle = http.get("http://localhost:3000/metadata")
	_handle_check(handle, "https.get_metadata")
	return json.parseArray(handle.readAll())
end

-- online_storage.get_ascii_subfile("ktFgVkXKqm21IF1f", 1)
function get_ascii_subfile(asciiID, subfileID)
	local handle = http.post("http://localhost:3000/get-ascii-subfile", "foo=" .. json.encode({asciiID = asciiID, subfileID = subfileID}))
	_handle_check(handle, "https.get_ascii_subfile")
	local str = handle.readAll()
	if str == "error" then error("https.get_ascii_subfile(asciiID, subfileID) requested a file that doesn't exist on the server.") end
	return str
end