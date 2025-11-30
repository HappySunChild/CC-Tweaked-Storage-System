---Truncates text.
---@param text string
---@param max_length integer
---@return string
local function truncate(text, max_length)
	if #text <= max_length then
		return text
	end

	return (text:sub(1, math.max(max_length - 3, 1)):gsub("%s*$", "") .. "..."):sub(1, max_length)
end

return truncate
