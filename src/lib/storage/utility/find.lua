---Find the index of a value in the passed table.
---@generic K
---@param haystack table<K, any>
---@param needle? any
---@return K?
local function find(haystack, needle)
	for key, value in next, haystack do
		if value == needle then
			return key
		end
	end

	return nil
end

return find
