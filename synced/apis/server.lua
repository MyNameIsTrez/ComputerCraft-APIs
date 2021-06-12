-- Global.
url = "http://h2896147.stratoserver.net:1338"


local server_print_url = path.join(url, "server-print")


function post_table(server_path, query, tab)
	local p = path.join(url, server_path)
	local payload = query .. "=" .. json.encode(tab)
	
	local t = http.post_lossless(p, payload)
	
	if t == nil then
		_G.print("Server is offline!")
		return false
	end
	
	local response = t.readAll()
	return response
end


function post(server_path, query, str)
	local p = path.join(url, server_path)
	local payload = query .. "=" .. str
	
	local t = http.post_lossless(p, payload)
	
	if t == nil then
		_G.print("Server is offline!")
		return false
	end
	
	local response = t.readAll()
	return response
end


function print(...)
	-- Prevents + getting converted to a space character in JS.
	local msg = textutils.urlEncode(json.encode({...}))
	
	local h = http.post_lossless(server_print_url, "msg=" .. msg)
	
	if h == nil then
		h.close()
		return false
	end
	
	local response = h.readAll()
	h.close()
	return response
end
