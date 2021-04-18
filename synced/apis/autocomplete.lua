function autocomplete(user_str, all_choices_tab)
	local choices_tab = {}
	local i = 1
	for _, choice in ipairs(all_choices_tab) do
		if utils.starts_with(choice, user_str) then
			choices_tab[i] = choice
			i = i + 1
		end
	end
	return choices_tab
end
