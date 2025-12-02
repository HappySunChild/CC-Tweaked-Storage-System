local list = require("prompt/list")

---Prompts the user with a list that they can choose one element from.
---@param choices string[]
---@param title string
---@param formatter? fun(choice: string): string
---@return string choice
---@return integer index
local function choice(choices, title, formatter)
	local selected = list(choices, title, "", function(choice, index, cursor)
		local text = formatter and formatter(choice) or choice
		local is_selected = index == cursor

		return string.format("%s %s", is_selected and ">" or " ", text)
	end)

	return choices[selected], selected
end

return choice
