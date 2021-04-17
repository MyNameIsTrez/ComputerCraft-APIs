-- Global.
url = "http://h2896147.stratoserver.net:1338"


local server_print_url = path.join(url, "server-print")

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
