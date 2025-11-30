---Prompts the user to enter text.
---@param title string
---@param hint? string Text to display at the bottom of the screen.
---@param completion? fun(partial: string): string[]
local function text(title, hint, completion)
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
end

return text
