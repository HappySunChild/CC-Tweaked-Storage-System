---@param choices string[]
---@param title string
---@param hint string
---@param format_callback fun(choice: string, index: integer, cursor: integer): string
---@param cursor_index? integer
---@return integer
local function list(choices, title, hint, format_callback, cursor_index)
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
		term.write(string.format("Page %d/%d %s", curr_page, page_count, hint))

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

return list
