---@generic K, V
---@param in_tbl table<K, V>
---@param count integer
---@return fun(tbl: table<K, V>, index: K?): K?, V?, integer?
---@return K, nil
local function distribute(in_tbl, count)
	local count_per_item = math.floor(count / #in_tbl)
	local extra_items = count % #in_tbl

	---@generic K, V
	---@param tbl table<K, V>
	---@param index K?
	return function(tbl, index)
		local current_index = next(in_tbl, index)

		if current_index == nil then
			return nil
		end

		local iterations = count_per_item + (extra_items > 0 and 1 or 0)

		extra_items = extra_items - 1

		if iterations == 0 then
			return nil
		end

		return current_index, tbl[current_index], iterations
	end,
		in_tbl,
		nil
end

return distribute
