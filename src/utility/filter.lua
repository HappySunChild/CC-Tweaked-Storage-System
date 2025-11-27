---@param tbl table
---@param predicate fun(key: any, value: any): boolean
local function filter(tbl, predicate)
	local filtered = {}

	for key, value in next, tbl do
		if predicate(key, value) then
			if type(key) == "number" then
				table.insert(filtered, value)
			else
				filtered[key] = value
			end
		end
	end

	return filtered
end

return filter
