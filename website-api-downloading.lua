local APIs = {
	{ ID = "p9tSSWcB", name = "cf"},       -- Common Functions (Debugging)
	{ ID = "DhrVLESZ", name = "lualzw"}, -- string compression
	{ ID = "GSRpTU2e", name = "json"},
	{ ID = "Yxn2x5Nt", name = "website"},
	{ ID = "BNB3wjQQ", name = "startup"},
	-- { ID = "", name = ""},
}

for _, API in ipairs(APIs) do
	if not fs.exists(API.name) then
		shell.run("pastebin", "get", API.ID, API.name)
	end
end