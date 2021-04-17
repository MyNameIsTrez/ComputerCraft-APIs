-- Global.
url = "http://h2896147.stratoserver.net:1338"


local server_print_url = path.join(url, "server-print")


function post_table(server_path, query, tab)
	local p = path.join(url, server_path)
	local payload = query .. "=" .. json.encode(tab)
	
	local t = http.post(p, payload)
	
	if t == nil then
		_G.print("Server is offline!")
		return false
	end
	
	local response = t.readAll()
	return response
end


function print(msg)
	local h = http.post(server_print_url, "msg=" .. json.encode(msg))
	
	if h == nil then
		h.close()
		return false
	end
	
	local response = h.readAll()
	h.close()
	return response
end
