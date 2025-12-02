local list = require("prompt/list")

---@param tbl table
---@return table
local function copy(tbl)
	local copied = {}

	for key, value in next, tbl do
		copied[key] = value
	end

	return copied
end

---@param tbl table
---@return integer
local function numkeys(tbl)
	local count = 0

	for _ in next, tbl do
		count = count + 1
	end

	return count
end

---Prompts the user with multiple choices that they can individually check.
---@param choices string[]
---@param title string
---@param formatter? fun(choice: string): string
---@return string[]
local function checkbox(choices, title, formatter)
	local chosen = {}
	local last_cursor = nil

	local new_choices = copy(choices)

	table.insert(new_choices, "")

	local finish_index = #new_choices

	while true do
		local selected = list(
			new_choices,
			title,
			string.format("- %d selected", numkeys(chosen)),
			function(choice, index, cursor)
				local is_selected = index == cursor

				if index == finish_index then
					term.setTextColor(colors.red)

					return string.format("%s Done", is_selected and ">" or " ")
				end

				local is_chosen = chosen[index] ~= nil
				local text = formatter and formatter(choice) or choice

				if is_chosen then
					term.setTextColor(colors.green)
				end

				return string.format(
					"%s [%s] %s",
					is_selected and ">" or " ",
					is_chosen and "x" or " ",
					text
				)
			end,
			last_cursor
		)

		if selected == finish_index then
			break
		end

		last_cursor = selected

		chosen[selected] = not chosen[selected] and true or nil
	end

	local output = {}

	for index in next, chosen do
		table.insert(output, choices[index])
	end

	return output
end

return checkbox
