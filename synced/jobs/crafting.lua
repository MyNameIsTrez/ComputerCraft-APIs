local items


function read_items()
	local h = io.open("backwards_os/synced/jobs/items", "r")
	local items_str = h:read()
	h:close()
	items = textutils.unserialize(items_str)
end


function add_recipe(item_name)
	server.post_table("add-recipe", "recipe_info", {
		crafting = "Oak Planks",
		recipe = {
			"Oak Wood", nil, nil,
			nil, nil, nil,
			nil, nil, nil
		},
		crafting_count = 4
	})
end


function remove_recipe(item_name)
	server.post("remove-recipe", "item", "Oak Planks")
end


read_items()

if items["Oak Planks"].recipe_info then
	remove_recipe("Oak Planks")
end
if not items["Oak Planks"].recipe_info then
	add_recipe("Oak Planks")
end
