local all_choices_tab


function on(tab)
	all_choices_tab = tab
	
	_autocomplete_until_enter()
end


function off()
	--all_choices_tab = nil
end


function _autocomplete_until_enter()
	--events.listen("key", autocomplete_until_enter)
	events.listen("char", autocomplete_until_enter)
end


function autocomplete_until_enter()
	server.print(keyboard.typed)
	local choices_tab = autocomplete(keyboard.typed)
	server.print(choices_tab)
	--utils.print_table(choices_tab)
end


function autocomplete(user_str)
	local user_str_lowered = string.lower(user_str)
	local choices_tab = {}
	local i = 1
	for _, choice in ipairs(all_choices_tab) do
		if utils.starts_with(string.lower(choice), user_str_lowered) then
			choices_tab[i] = choice
			i = i + 1
		end
	end
	return choices_tab
end
