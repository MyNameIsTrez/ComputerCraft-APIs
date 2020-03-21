-- Lists options the user can choose from.

function listOptions(options)
	cf.printTable(options)
	print('Enter one of the program names above.')
	
	while true do
		local answer = read()
		
		local answerLowerCase = answer:lower()
		local validAnswer = false
		for _, option in ipairs(options) do
			if option:lower() == answerLowerCase then
				validAnswer = true
			end
		end
		
		if validAnswer then
			return answer
		else
			print('Invalid program name.')
		end
	end
end