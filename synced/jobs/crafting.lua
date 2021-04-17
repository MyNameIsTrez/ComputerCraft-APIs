local items


function read_items()
	local h = io.open("backwards_os/synced/jobs/items", "r")
	local items_str = h:read()
	h:close()
	items = textutils.unserialize(items_str)
end


read_items()
print(items["Oak Wood"].emc)
