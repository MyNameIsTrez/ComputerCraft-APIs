local listen_url = "http://h2896147.stratoserver.net:1338/long_poll?fn_name="

function listen(listen_path)
	local h = http.get(listen_url .. listen_path)
	if h == nil then error("Server offline.") end
	local response = h.readAll()
	h.close()
	return response
end
