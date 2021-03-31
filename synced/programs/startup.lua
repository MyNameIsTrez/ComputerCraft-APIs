local server_url = "http://h2896147.stratoserver.net"
local port_files = 1338

local server_online_url = server_url .. ":" .. port_files .. "/is-online"
local file_name_url = server_url .. ":" .. port_files .. "/file?name="

local bw_os_name = "backwards_os"
local synced_path = fs.combine(bw_os_name, "synced")

local apis_path = fs.combine(synced_path, "apis")
local programs_path = fs.combine(synced_path, "programs")

local json_api_path = fs.combine(apis_path, "json")

local apis_program_path = fs.combine(programs_path, "apis")
local bw_os_program_path = fs.combine(programs_path, "backwards_os")


function main()
	remove_craftos_watermark()
	
	-- TODO: Support offline usage.
	if not is_server_online() then error("Server offline.") end
	
	create_dirs()
	download_and_load_required_apis()
	shell.run(bw_os_program_path)
end


function remove_craftos_watermark()
	term.setCursorPos(1, 1)
	write("           ")
	term.setCursorPos(1, 1)
end


function is_server_online()
	return http.get(server_online_url) ~= nil
end


function create_dirs()
	if not fs.exists(bw_os_name) then fs.makeDir(bw_os_name) end
	if not fs.exists(synced_path) then fs.makeDir(synced_path) end

	if not fs.exists(apis_path) then fs.makeDir(apis_path) end
	if not fs.exists(programs_path) then fs.makeDir(programs_path) end
end


function download_and_load_required_apis()
	-- The apis API requires json, but I assume the json API won't ever be updated.
	if not fs.exists(json_api_path) then download_file("json", "apis") end
	os.loadAPI(json_api_path)
	
	-- Need to redownload the apis API every time, in case any of the server's API download paths change.
	download_file("apis", "programs")
	os.loadAPI(apis_program_path)
	
	apis.get_latest(true)
end


function download_file(name, dir)
	local file_path = fs.combine(dir, name)

	local file_handle = http.get(file_name_url .. file_path)
	if file_handle == false then error("Error: The API '" .. file_path .. "' doesn't exist on the online server!") end

	local h = io.open(fs.combine(synced_path, file_path), "w")
	h:write(file_handle.readAll())
	h:close()
end


main()
