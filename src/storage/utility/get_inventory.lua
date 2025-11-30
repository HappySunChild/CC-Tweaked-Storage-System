local UNKNOWN_PERIPHERAL = 'Unable to find peripheral "%s"'
local INVALID_INVENTORY = 'Peripheral "%s" is not a valid inventory!'

---@param inv_name string
---@return peripheral.Inventory
local function get_inventory(inv_name)
	local inventory = peripheral.wrap(inv_name)

	if inventory == nil then
		error(UNKNOWN_PERIPHERAL:format(inv_name), 2)
	end

	if inventory.list == nil then
		error(INVALID_INVENTORY:format(inv_name), 2)
	end

	return inventory
end

return get_inventory
