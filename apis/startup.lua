local server_url = "http://h2896147.stratoserver.net"
local port_https = 1337
local port_apis = 1338

local bw_os_name = "backwards_os"
local apis_path = fs.combine(bw_os_name, "apis")
local bw_os_api_path = fs.combine(apis_path, "backwards_os")

local required_apis = { "api_manager", "json", "backwards_os_cfg" }


function main()
	-- TODO: Support offline usage of BackwardsOS.
	if not is_server_online() then error("Server's not online!") end
	
	if not fs.exists(bw_os_name) then fs.makeDir(bw_os_name) end
	if not fs.exists(apis_path) then fs.makeDir(apis_path) end
	
	download_and_load_required_apis()
	
	if not fs.exists(bw_os_api_path) then download_api(bw_os_name) end
	shell.run(bw_os_api_path)
end


function is_server_online()
	return http.get(server_url .. ":" .. port_apis .. "/is-online") ~= nil
end


function download_and_load_required_apis()
	for _, api_name in ipairs(required_apis) do
		local api_path = fs.combine(apis_path, api_name)
		if not fs.exists(api_path) then download_api(api_name) end
		os.loadAPI(api_path)
	end
end


function download_api(name)
	local api_table = http.get(server_url .. ":" .. port_apis .. "/get-api" .. "?name=" .. tostring(name))
	if api_table == false then error("Error: The API '" .. tostring(name) .. "' doesn't exist on the online server!") end

	local h = io.open(fs.combine(apis_path, tostring(name)), "w")
	h:write(api_table.readAll())
	h:close()
end


main()
