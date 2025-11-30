---@param text string
---@param amount integer
---@return string
local function justify(text, amount)
	local dif = math.abs(amount) - #text
	local padding = string.rep(" ", dif)

	if amount < 0 then
		return padding .. text
	end

	return text .. padding
end

return justify
