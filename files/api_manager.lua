-- ComputerCraft and server code written and hosted by MyNameIsTrez#1585 on Discord. Feel free to contact me!

function get_latest()
	fs.makeDir("apis")
	
	if not json then download_json() end
	local serialized_api_metadata = "data=" .. json.encode(get_local_api_versions())
	print("serialized_api_metadata: " .. serialized_api_metadata)
	
	local url = "http://h2896147.stratoserver.net:1338/apis-get-latest"
	local h = http.post(url, serialized_api_metadata)
	local diff_msg = h.readAll()
	
	h = io.open("diff_msg.json", "w") h:write(diff_msg) h:close()
	local diff_apis = json.decode(diff_msg)
	
	local key_count = 0
	for _, _ in pairs(diff_apis) do key_count = key_count + 1 end
	print("key count diff_apis:", ", ", key_count)

	for k, v in pairs(diff_apis) do
		h = io.open(fs.combine("apis", k), "w")
		h:write(diff_apis[k].lua)
		h:close()
		
		--cf.printTable(diff_apis[k].lua)

		diff_apis[k].lua = nil -- So code doesn't end up in metadata file.
		
		print("Downloaded " .. k .. ": " .. diff_apis[k].age)
	end

	h = io.open("apis/api_metadata.json", "w")
	h:write(textutils.serialize(diff_apis))
	h:close()
end

function get_local_api_versions()
	if fs.exists("apis/api_metadata.json") then
		local h = io.open("apis/api_metadata.json", "r")
		local data = h:read()
		h:close()
		return textutils.unserialize(data)
	else
		return {}
	end
end

-- TODO: Move to BackwardsOS bootloader.
function download_json()
	local h = io.open("apis/json", "w")
	h:write(https.get("https://raw.githubusercontent.com/MyNameIsTrez/ComputerCraft-APIs/master/apis/json.lua").readAll())
	h:close()
	os.loadAPI("apis/json")
end
