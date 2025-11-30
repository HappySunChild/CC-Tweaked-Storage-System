local copy = require("utility/copy")

---@param choices string[]
---@param title string
---@param format_callback fun(choice: string, index: integer, cursor: integer): string
---@param cursor_index? integer
---@return integer
local function list(choices, title, format_callback, cursor_index)
	if #choices == 0 then
		return 0
	end

	local cursor = cursor_index or 1

	local _, height = term.getSize()
	local choices_per_page = height - 4

	local page_count = math.ceil(#choices / choices_per_page)

	while true do
		term.clear()
		term.setCursorPos(1, 1)
		term.write(title)

		local curr_page = math.ceil(cursor / choices_per_page)

		local start_index = (curr_page - 1) * choices_per_page + 1
		local finish_index = math.min(start_index + choices_per_page - 1, #choices)

		for index = start_index, finish_index do
			local choice = choices[index]
			local text = format_callback(tostring(choice), index, cursor)

			if index == cursor then
				term.setTextColor(colors.lightBlue)
			end

			term.setCursorPos(1, (index - start_index) + 3)
			term.write(text)

			term.setTextColor(colors.white)
		end

		term.setCursorPos(1, height)
		term.write(string.format("Page %d/%d", curr_page, page_count))

		local _, pressed_key = os.pullEvent("key")

		if pressed_key == keys.up then
			cursor = math.max(cursor - 1, 1)
		elseif pressed_key == keys.left then
			cursor = math.max(cursor - choices_per_page, 1)
		elseif pressed_key == keys.down then
			cursor = math.min(cursor + 1, #choices)
		elseif pressed_key == keys.right then
			cursor = math.min(cursor + choices_per_page, #choices)
		elseif pressed_key == keys.enter then
			break
		end
	end

	return cursor
end

return {
	---Prompts the user with multiple choices that they can individually check.
	---@param choices string[]
	---@param title string
	---@param formatter? fun(choice: string): string
	---@return string[]
	checkbox_list = function(choices, title, formatter)
		local chosen = {}
		local last_cursor = nil

		local new_choices = copy(choices)

		table.insert(new_choices, "")

		local finish_index = #new_choices

		while true do
			local selected = list(new_choices, title, function(choice, index, cursor)
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
			end, last_cursor)

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
	end,
	---Prompts the user with a list that they can choose one element from.
	---@param choices string[]
	---@param title string
	---@param formatter? fun(choice: string): string
	---@return string choice
	---@return integer index
	choice_list = function(choices, title, formatter)
		local selected = list(choices, title, function(choice, index, cursor)
			local text = formatter and formatter(choice) or choice
			local is_selected = index == cursor

			return string.format("%s %s", is_selected and ">" or " ", text)
		end)

		return choices[selected], selected
	end,
	---Prompts the user to enter text.
	---@param title string
	---@param hint? string Text to display at the bottom of the screen.
	---@param completion? fun(partial: string): string[]
	text_page = function(title, hint, completion)
		local _, height = term.getSize()

		term.setCursorPos(1, 1)
		term.write(title)

		if hint ~= nil then
			term.setTextColor(colors.lightGray)

			term.setCursorPos(1, height)
			term.write(hint)

			term.setTextColor(colors.white)
		end

		term.setCursorPos(1, 3)
		term.write("$ ")

		return read(nil, nil, completion)
	end,
}
