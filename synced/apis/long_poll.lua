function listen()
	local h = http.get_lossy("http://h2896147.stratoserver.net:1338/long_poll?fn_name=file_change")
	if h == nil then error("Server offline.") end
	local response = h.readAll()
	h.close()
	return response
end
