Twitter = {

	new = function(self, settings)
		local s = settings

		local self = {
			-- Assign passed settings.
			-- cols   = s.cols,

			-- Extra.
		}
		
		setmetatable(self, {__index = Twitter})
		
		return self
	end,

	-- add = function(self, number)
	-- 	table.insert(self.data, number) -- Pushes the number.
		
    -- 	-- If there's more data than there are columns, start removing old data.
	-- 	if #self.data > self.cols then
	-- 		table.remove(self.data, 1) --  Removes index 1, so it removes the oldest number.
	-- 	end
	-- end,

}