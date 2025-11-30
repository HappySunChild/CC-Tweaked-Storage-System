---Utility function for easily blit-ing text onto the screen.
---@param text string
---@param fg_blit string
---@param bg_blit string
---@return string, string, string
local function paint(text, fg_blit, bg_blit)
	return text, string.rep(fg_blit, #text), string.rep(bg_blit, #text)
end

return paint
