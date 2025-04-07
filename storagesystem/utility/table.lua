---@class tableUtil: tablelib
local tableUtil = {}

---@generic K
---@generic V
---@param tab table<K, V>
---@param value V
---@return K? index
function tableUtil.find(tab, value)
	for i, v in next, tab do
		if v == value then
			return i
		end
	end
end

return setmetatable(tableUtil, { __index = table })
