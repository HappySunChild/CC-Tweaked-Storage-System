---@param tbl table
---@return table
local function copy(tbl)
	local copied = {}

	for key, value in next, tbl do
		copied[key] = value
	end

	return copied
end

return copy
