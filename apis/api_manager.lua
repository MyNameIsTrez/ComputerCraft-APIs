-- ComputerCraft and server code written and hosted by MyNameIsTrez#1585 on Discord. Feel free to contact me!


local metadata_path = "apis/api_metadata.json"


function get_latest(printing)
	local local_metadata = get_local_metadata()
	local diff_metadata = get_diff_metadata(local_metadata)
	if diff_metadata == false then print("Server offline!") return false end

	add_apis(diff_metadata)
	remove_apis(diff_metadata)

	write_combined_metadata(local_metadata, diff_metadata)

	if printing then print_diff_stats(diff_metadata) end

	return true
end


function add_apis(diff_metadata)
	for k, v in pairs(diff_metadata.add) do
		h = io.open(fs.combine("apis", k), "w")
		h:write(v.lua)
		h:close()
		v.lua = nil -- So Lua code doesn't end up in the metadata file.
	end
end


function remove_apis(diff_metadata)
	for k, v in ipairs(diff_metadata.remove) do fs.delete(fs.combine("apis", v)) end
end


function get_local_metadata()
	if fs.exists(metadata_path) then
		local h = io.open(metadata_path, "r")
		local data = h:read()
		h:close()
		return textutils.unserialize(data)
	else
		return {}
	end
end


-- TODO: Move to BackwardsOS bootloader.
function download_json()
	os.loadAPI("https")

	local h = io.open("apis/json", "w")
	h:write(https.get("https://raw.githubusercontent.com/MyNameIsTrez/ComputerCraft-APIs/master/apis/json.lua").readAll())
	h:close()
	os.loadAPI("apis/json")
end


function get_diff_metadata(local_metadata)
	-- TODO: Move to BackwardsOS bootloader.
	fs.makeDir("apis")
	if not json then download_json() end


	local serialized_local_metadata = "data=" .. json.encode(local_metadata)
	
	local url = "http://h2896147.stratoserver.net:1338/apis-get-latest"
	local h = http.post(url, serialized_local_metadata)
	
	if h == nil then return false end -- If the server is offline.
	
	local diff_msg = h.readAll()
	return json.decode(diff_msg)
end


function print_diff_stats(diff_metadata)
	print("Bytes received: ", #textutils.serialize(diff_metadata))

	local added_names = keys(diff_metadata.add)
	print("\nAdded: ", #added_names)
	print_array(added_names)
	
	local removed_names = diff_metadata.remove
	print("\nRemoved: ", #removed_names)
	print_array(removed_names)
end


-- TODO: Move to BackwardsOS bootloader.
function keys(tab)
	local key_set = {}
	local i = 1
	
	for k, v in pairs(tab) do
		key_set[i] = k
		i = i + 1
	end
	
	return key_set
end


-- TODO: Move to BackwardsOS bootloader.
function print_array(arr) print("{ " .. table.concat(arr, ", ") .. " }") end


function write_combined_metadata(local_metadata, diff_metadata)
	-- Add diff_metadata.add APIs to combined_metadata.
	local combined_metadata = local_metadata -- Doesn't copy; passes by reference.
	for k, v in pairs(diff_metadata.add) do combined_metadata[k] = v end

	-- Remove diff_metadata.remove APIs from combined_metadata.
	for k, v in ipairs(diff_metadata.remove) do combined_metadata[v] = nil end

	h = io.open(metadata_path, "w")
	h:write(textutils.serialize(combined_metadata))
	h:close()
end
