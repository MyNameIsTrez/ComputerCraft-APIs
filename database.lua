Database = {}
function Database:new(settings)
	setmetatable({}, Database)

	self.shell = settings.shell
	self.name = settings.name
	
	self:_init_path()

	return self
end

function Database:_init_path()
	self.path = cf.pathJoin(self.shell.dir(), self.name .. ".db")
end

function Database:insert(document)
	-- Check if the _id isn't present yet.
	local handle = fs.open(self.path, fs.exists(self.path) and "a" or "w")
	handle.write(textutils.serialize(document) .. "\n")
	handle.close()
end

-- Have this take a table of tags as argument in the future.
function Database:find()
	local handle = fs.open(self.path, "r")
	if handle == nil then return nil end
	local documents = {}
	for line in handle.readLine do
		local document = textutils.unserialize(line)
		table.insert(documents, document)
	end
	handle.close()
	return documents
end