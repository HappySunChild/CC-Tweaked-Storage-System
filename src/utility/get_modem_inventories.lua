---@param modem peripheral.Modem
---@return string[]
local function get_modem_inventories(modem)
	local inventories = {}

	for _, name in ipairs(modem.getNamesRemote()) do
		if peripheral.hasType(name, "inventory") then
			table.insert(inventories, name)
		end
	end

	table.sort(inventories)

	return inventories
end

return get_modem_inventories
