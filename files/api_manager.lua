-- ComputerCraft and server code written and hosted by MyNameIsTrez#1585 on Discord. Feel free to contact me!


local api_metadata_path = "apis/api_metadata.json"


function get_latest()
	local diff_metadata = get_diff_metadata()
	
	if next(diff_metadata) then -- If not empty.
		-- Write diff APIs.
		for k, v in pairs(diff_metadata) do
			h = io.open(fs.combine("apis", k), "w")
			h:write(diff_metadata[k].lua)
			h:close()
			
			diff_metadata[k].lua = nil -- So Lua code doesn't end up in the metadata file.
			
			print("Downloaded " .. k .. ": " .. diff_metadata[k].age)
		end

		-- Combine local and diff API metadata.
		local combined_metadata = diff_metadata
	
		-- Write combined API metadata.
		h = io.open(api_metadata_path, "w")
		h:write(textutils.serialize(combined_metadata))
		h:close()
	end
end


function get_local_metadata()
	if fs.exists(api_metadata_path) then
		local h = io.open(api_metadata_path, "r")
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


function get_diff_metadata()
	-- TODO: Move to BackwardsOS bootloader.
	fs.makeDir("apis")
	if not json then download_json() end


	local serialized_local_metadata = "data=" .. json.encode(get_local_metadata())
	
	local url = "http://h2896147.stratoserver.net:1338/apis-get-latest"
	local h = http.post(url, serialized_local_metadata)
	local diff_msg = h.readAll()
	return json.decode(diff_msg)
end
