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


function init()
	crafting.read_items()
	crafting.read_item_names()
end



--read_items()

--if items["Oak Planks"].recipe_info then
--	remove_recipe("Oak Planks")
--end
--if not items["Oak Planks"].recipe_info then
--	add_recipe("Oak Planks")
--end


function craft(item_name, count)
	local item = items[item_name] -- item_name will always be in items.
	local recipe_info = item.recipe_info
	
	if recipe_info == false then -- If it is gotten from a Condenser/Chest.
		grab(item_name, count)
	else -- If it needs to be crafted.
		local recipe = recipe_info.recipe
	
		local subitem_counts = get_subitem_counts(recipe)

		for subitem_name, subcount in ipairs(subitem_counts) do
			craft(subitem_name, subcount) -- Craft the subitems needed for the recipe.
		end
	end
end


-- For example, returns { ["Oak Planks"] = 3, ["Cobblestone"] = 4 }
function get_subitem_counts(recipe)
	local subitem_counts = {}
	for _, subitem_name in ipairs(recipe) do
		local subitem_count = subitem_counts[subitem_name]
		subitem_counts[subitem_name] = subitem_count == nil and 1 or subitem_counts[subitem_name]
	end
	return subitem_counts
end


function grab()

end