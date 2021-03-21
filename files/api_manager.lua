-- ComputerCraft and server code written and hosted by MyNameIsTrez#1585 on Discord. Feel free to contact me!

function get_latest()
	fs.makeDir("apis")
	
	if not json then download_json() end
	local serialized_api_metadata = "data=" .. json.encode(get_local_api_versions())
	
	local url = "http://h2896147.stratoserver.net:1338/apis-get-latest"
	local h = http.post(url, serialized_api_metadata)
	local diff_msg = h.readAll()
	
	local diff_apis = json.decode(diff_msg)
	
	if next(diff_apis) then -- If not empty.
		for k, v in pairs(diff_apis) do
			h = io.open(fs.combine("apis", k), "w")
			h:write(diff_apis[k].lua)
			h:close()
			
			diff_apis[k].lua = nil -- So Lua code doesn't end up in the metadata file.
			
			print("Downloaded " .. k .. ": " .. diff_apis[k].age)
		end
	
		h = io.open("apis/api_metadata.json", "w")
		h:write(textutils.serialize(diff_apis))
		h:close()
	end
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
