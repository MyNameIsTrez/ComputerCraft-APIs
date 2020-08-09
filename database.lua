Database = {}
function Database:new(settings)
	setmetatable({}, Database)

	self.path = settings.path
	self.name = settings.name
	
	self:_init_path()

	return self
end

function Database:_init_path()
	self.path = cf.pathJoin(self.path, self.name .. ".db")
end

function Database:insert(document)
	if not self:id_present(document._id) then
		local handle = fs.open(self.path, fs.exists(self.path) and "a" or "w")
		handle.write(textutils.serialize(document) .. "\n")
		handle.close()
	end
end

function Database:id_present(_id)
	local documents = self:find()
	for _, document in ipairs(documents) do
		if document._id == _id then return true end
	end
	return false
end

-- Have this take a table of tags as argument in the future.
function Database:find()
	local handle = fs.open(self.path, "r")
	if handle == nil then return {} end
	local documents = {}
	for line in handle.readLine do
		local document = textutils.unserialize(line)
		table.insert(documents, document)
	end
	handle.close()
	return documents
end