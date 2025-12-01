---@param autocrafter AutoCrafter
---@return fun(pattern: string): string
local function format_pattern(autocrafter)
	---@param pattern string
	---@return string
	return function(pattern)
		local info = autocrafter.patterns[pattern]

		if info == nil then
			return "UNKNOWN PATTERN"
		end

		return info.label
	end
end

return format_pattern
