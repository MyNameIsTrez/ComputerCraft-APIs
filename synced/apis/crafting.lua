local items
item_names = {}


function read_items()
	local h = io.open("backwards_os/synced/data/items", "r")
	local items_str = h:read()
	h:close()
	items = textutils.unserialize(items_str)
end


function read_item_names()
	local i = 1
	for item_name, _ in pairs(items) do
		item_names[i] = item_name
		i = i + 1
	end
	utils.sort_alphabetically(item_names)
end


function add_recipe(item_name)
	server.post_table("add-recipe", "recipe_info", {
		craft = "Oak Planks",
		recipe = {
			"Oak Wood", nil, nil,
			nil, nil, nil,
			nil, nil, nil
		},
		craft_count = 4
	})
end


function remove_recipe(item_name)
	server.post("remove-recipe", "item", "Oak Planks")
end



--read_items()

--if items["Oak Planks"].recipe_info then
--	remove_recipe("Oak Planks")
--end
--if not items["Oak Planks"].recipe_info then
--	add_recipe("Oak Planks")
--end
