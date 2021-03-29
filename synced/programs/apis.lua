local bw_os_name = "backwards_os"
local synced_path = fs.combine(bw_os_name, "synced")
local synced_metadata_path = fs.combine(bw_os_name, "synced_metadata")
local apis_path = fs.combine(synced_path, "apis")

local get_latest_synced_files_url = "http://h2896147.stratoserver.net:1338/get-latest-files"

-- TODO: Once there's a "programs" folder, place startup in there. Copy startup from there to . path.
-- startup downloads itself to . instead of backwards_os/apis, as that's where CC looks for the startup file.
--local not_downloaded = { "startup" }


function get_latest(printing)
	local local_metadata = get_local_metadata()
	local diff_metadata = get_diff_metadata(local_metadata)
	if diff_metadata == false then print("Server offline!") return false end

	if printing then print_diff_stats(diff_metadata) end

	add_files(diff_metadata)
	remove_files(diff_metadata)

	write_combined_metadata(local_metadata, diff_metadata)

	load_apis()

	return true
end


function add_files(diff_metadata)
	for name, file_data in pairs(diff_metadata.add) do
		local file_path = fs.combine(synced_path, fs.combine(file_data.dir, name))
		local h = io.open(file_path, "w")
		h:write(file_data.lua)
		h:close()
		file_data.lua = nil -- So Lua code doesn't end up in the metadata file.

		if name == "startup" then
			fs.delete("startup")
			fs.copy(file_path, "startup")
		end
	end
end


function remove_files(diff_metadata)
	for _, file_path in ipairs(diff_metadata.remove) do
		fs.delete(file_path)
	end
end


function get_local_metadata()
	if fs.exists(synced_metadata_path) then
		local h = io.open(synced_metadata_path, "r")
		local data = h:read()
		h:close()
		return textutils.unserialize(data)
	else
		return {}
	end
end


function get_diff_metadata(local_metadata)
	local serialized_local_metadata = "data=" .. json.encode(local_metadata)
	
	local h = http.post(get_latest_synced_files_url, serialized_local_metadata)
	
	if h == nil then return false end -- If the server is offline.
	
	local diff_msg = h.readAll()
	return json.decode(diff_msg)
end


function print_diff_stats(diff_metadata)
	local added_names = tableKeys(diff_metadata.add)
	local any_added = #added_names > 0
	if any_added then
		print("\nAdded: ", #added_names)
		print_array(added_names)
	end
	
	local removed_names = diff_metadata.remove
	local any_removed = #removed_names > 0
	if any_removed then
		print("\nRemoved: ", #removed_names)
		print_array(removed_names)
	end

	if any_added or any_removed then
		print("\nBytes received: ", #textutils.serialize(diff_metadata))
	end
end


-- TODO: Move to BackwardsOS bootloader.
function tableKeys(tab)
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

	h = io.open(synced_metadata_path, "w")
	h:write(textutils.serialize(combined_metadata))
	h:close()
end


function load_apis()
	for _, name in ipairs(fs.list(apis_path)) do
		os.loadAPI(fs.combine(apis_path, name))
	end
end
