-- ComputerCraft and server code written and hosted by MyNameIsTrez#1585 on Discord. Feel free to contact me!

function get_latest()
	local url = "http://h2896147.stratoserver.net:1338/apis-get-latest"
	
	if not json then download_json() end
	local object_string = "data=" .. json.encode(get_local_api_versions())
	print("object_string: " .. object_string)
	
	local outdated = http.post(url, object_string)
	
	return outdated
end

function get_local_api_versions()
	-- TODO: Read from api_metadata.json
	return {foo=8, bar=123}
end

-- TODO: Move to BackwardsOS bootloader.
function download_json()
	fs.makeDir("apis")
	local h = io.open("apis/json", "w")
	h:write(https.get("https://raw.githubusercontent.com/MyNameIsTrez/ComputerCraft-APIs/master/apis/json.lua").readAll())
	h:close()
	os.loadAPI("apis/json")
end
