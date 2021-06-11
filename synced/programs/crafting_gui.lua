crafting.read_items()
crafting.read_item_names()


autocomplete.on(crafting.item_names)

local choices_remaining = autocomplete.autocomplete("Oak")

autocomplete.off()

utils.print_table(choices_remaining)