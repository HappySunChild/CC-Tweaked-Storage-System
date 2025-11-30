local prompt_choice = require("utility/prompt/choice")

---@param options string[]
---@param title string
---@param callback fun(index: integer, choice: string)
local function menu(options, title, callback)
	table.insert(options, "Exit")

	while true do
		local choice, index = prompt_choice(options, title)

		if index == #options then
			break
		end

		callback(index, choice)
	end
end

return menu
