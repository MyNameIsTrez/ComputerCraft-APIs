-- Lists options the user can choose from.

-- If keysStrings is set to 'true', the table is looped with 'pairs()'.
function listOptions(options, keysStrings)
	cf.printTable(options, false)
	print('Enter one of the program names above:')
	
	while true do
		local answer = read()
		local answerLowerCase = answer:lower()

		local validAnswer = false

		if keysStrings then -- If all keys are strings.
			for option, _ in pairs(options) do
				if option:lower() == answerLowerCase then
					validAnswer = true
				end
			end
		else
			for _, option in ipairs(options) do
				if option:lower() == answerLowerCase then
					validAnswer = true
				end
			end
		end
		
		if validAnswer then
			return answer
		else
			print('Invalid program name.')
		end
	end
end