local items


function read_items()
	local h = io.open("backwards_os/synced/jobs/items", "r")
	local items_str = h:read()
	h:close()
	items = textutils.unserialize(items_str)
end


function add_recipe(item_name)
	server.post_table("add-recipe", "recipe", { ["Oak Planks"] = {
		"Oak Wood", nil, nil,
		nil, nil, nil,
		nil, nil, nil
	}})
end


read_items()
if not items["Oak Planks"].recipe then
	add_recipe("Oak Planks")
end
