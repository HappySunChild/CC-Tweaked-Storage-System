---@param name string
---@return string
local function format_name(name)
	local filtered = name:gsub("^[^:]*:", ""):gsub("_", " ")
	local formatted = filtered:gsub("%s%l", string.upper):gsub("^%l", string.upper)

	return formatted
end

return format_name
