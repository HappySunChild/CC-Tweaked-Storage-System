---@param list string[]
---@param target string
---@return string?
local function choose_nearest(list, target)
	local best = nil
	local record = math.huge

	for _, str in ipairs(list) do
		local start = string.find(str, target)

		if start and start < record then
			record = start
			best = str
		end
	end

	return best
end

return choose_nearest
