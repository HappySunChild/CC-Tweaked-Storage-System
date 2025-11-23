local UNKNOWN_PERIPHERAL = 'Unable to find peripheral "%s"'
local INVALID_INVENTORY = 'Peripheral "%s" is not a valid inventory!'
local UNKNOWN_INVENTORY = 'Unable to find inventory "%s", is it being tracked?'
local MISSING_INVENTORY_ITEMS = 'Unable to find items for inventory "%s", did you update the cache?'

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

---@class StorageSystem.ItemOccurance
---@field inventory string
---@field slot integer
---@field item peripheral.InventoryItem

---@class StorageSystem
---@field inventories table<string, peripheral.Inventory>
---@field package _item_cache table<string, peripheral.InventoryItem[]>
local CLASS = {
	---@param self StorageSystem
	---@param inv_name string The name of the peripheral to track (i.e. `"left"` or `"minecraft:chest_0"`)
	track_inventory = function(self, inv_name)
		self.inventories[inv_name] = get_inventory(inv_name)
	end,
	---@param self StorageSystem
	---@param inv_name string The name of the peripheral to stop tracking (i.e. `"left"` or `"minecraft:chest_0"`)
	untrack_inventory = function(self, inv_name)
		self.inventories[inv_name] = nil
	end,
	---Updates the internal item cache by reading the contents of all the tracked inventories.
	---@param self StorageSystem
	update_inventories = function(self)
		for inv_name, inventory in next, self.inventories do
			self._item_cache[inv_name] = inventory.list()
		end
	end,

	---Calculates the total size (slots) of the system.
	---@param self StorageSystem
	---@return integer
	get_system_size = function(self)
		local size = 0

		for _, inventory in next, self.inventories do
			size = size + inventory.size()
		end

		return size
	end,
	---Returns a dictionary of all the items, and their counts, inside the system.
	---@param self StorageSystem
	---@return table<string, integer>
	get_system_items = function(self)
		local output = {}

		for _, inv_items in next, self._item_cache do
			for _, item in next, inv_items do
				local name = item.name
				local count = item.count

				output[name] = (output[name] or 0) + count
			end
		end

		return output
	end,

	---Returns the size (slot count) of the specified inventory, if it is connected to the system.
	---@param self StorageSystem
	---@param inv_name string The name of the inventory.
	---@return integer
	get_inventory_size = function(self, inv_name)
		local inventory = self.inventories[inv_name]

		if inventory == nil then
			error(UNKNOWN_INVENTORY:format(inv_name), 2)
		end

		return inventory.size()
	end,
	---Returns a dictionary of all the items, and their counts, inside the specified inventory.
	---@param self StorageSystem
	---@param inv_name string The name of the inventory.
	---@return table<string, integer>
	get_inventory_items = function(self, inv_name)
		local inv_items = self._item_cache[inv_name]

		if inv_items == nil then
			error(MISSING_INVENTORY_ITEMS:format(inv_name), 2)
		end

		local output = {}

		for _, item in next, inv_items do
			local name = item.name
			local count = item.count

			output[name] = (output[name] or 0) + count
		end

		return output
	end,

	---Returns an iterator that returns each occurance of an item in the system.
	---
	---Example usage:
	---```lua
	---for inv, slot, item in system:find_iter("minecraft_torch") do
	---	...
	---end
	---```
	---@param self StorageSystem
	---@param item_name string
	---@return fun(): string?, integer?, peripheral.InventoryItem?
	find_iter = function(self, item_name)
		local cur_inv = nil
		local cur_slot = nil

		return function()
			for inv_name, items in next, self._item_cache, cur_inv do
				for slot, item in next, items, cur_slot do
					cur_slot = slot

					if item.name == item_name then
						return inv_name, slot, item
					end
				end

				-- advancing to next inventory
				cur_inv = inv_name
				cur_slot = nil -- reset slot to nil
			end

			return nil, nil, nil
		end
	end,
	---Returns an array of all the occurances where the item appears in the system.
	---@param self StorageSystem
	---@param item_name string
	---@return StorageSystem.ItemOccurance[]
	find_system_item = function(self, item_name)
		local occurances = {}

		for inv, slot, item in self:find_iter(item_name) do
			table.insert(occurances, {
				inventory = inv,
				slot = slot,
				item = item,
			})
		end

		return occurances
	end,

	---Pulls items from one inventory into another.
	---@param self StorageSystem
	---@param inv_from string
	---@param slot_from integer
	---@param inv_to string
	---@param slot_to? integer
	---@param count? integer
	---@return integer transferred
	pull_items = function(self, inv_from, slot_from, inv_to, slot_to, count)
		local to_inventory = self.inventories[inv_to] ---@type peripheral.Inventory?

		if to_inventory == nil then
			error(UNKNOWN_INVENTORY:format(inv_to), 2)
		end

		return to_inventory.pullItems(inv_from, slot_from, count, slot_to)
	end,
	---Pushes items from one inventory into another.
	---@param self StorageSystem
	---@param inv_from string
	---@param slot_from integer
	---@param inv_to string
	---@param slot_to? integer
	---@param count? integer
	---@return integer transferred
	push_items = function(self, inv_from, slot_from, inv_to, slot_to, count)
		local from_inventory = self.inventories[inv_from] ---@type peripheral.Inventory?

		if from_inventory == nil then
			error(UNKNOWN_INVENTORY:format(inv_from), 2)
		end

		return from_inventory.pushItems(inv_to, slot_from, count, slot_to)
	end,

	---@param self StorageSystem
	---@param inv_from string
	---@param slot_from integer
	---@param count? integer
	---@return integer transferred
	import_from_slot = function(self, inv_from, slot_from, count)
		local current_inv = next(self.inventories)

		if current_inv == nil then
			return 0
		end

		local total_transferred = 0

		while true do
			local remaining = count and count - total_transferred or nil
			local transferred = self:pull_items(inv_from, slot_from, current_inv, nil, remaining)

			total_transferred = total_transferred + transferred

			if count == nil or total_transferred >= count then
				break
			end

			if transferred == 0 then -- cycle to next inventory, current inventory might be full
				current_inv = next(self.inventories, current_inv)

				if current_inv == nil then -- system is entirely full, break out of loop
					break
				end
			end
		end

		return total_transferred
	end,
	---Imports the specified item into the system from an external inventory.
	---@see StorageSystem.pull_items
	---@param self StorageSystem
	---@param item_name string
	---@param inv_from string
	---@param count? integer
	---@return integer total_transferred
	import_item = function(self, item_name, inv_from, count)
		local total_transferred = 0

		local inventory = get_inventory(inv_from)

		for slot, item in next, inventory.list() do
			if item.name ~= item_name then
				goto continue
			end

			local remaining = count and count - total_transferred or item.count
			local transferred = self:import_from_slot(inv_from, slot, math.min(remaining, item.count))

			total_transferred = total_transferred + transferred

			if count == nil or total_transferred >= count or transferred == 0 then
				break
			end

			::continue::
		end

		return total_transferred
	end,
	---Exports the specified item from the system into an external inventory.
	---@see StorageSystem.push_items
	---@param self StorageSystem
	---@param item_name string
	---@param inv_to string
	---@param slot_to? integer
	---@param count? integer
	---@return integer total_transferred
	export_item = function(self, item_name, inv_to, slot_to, count)
		local total_transferred = 0

		for inv, slot in self:find_iter(item_name) do
			local remaining = count ~= nil and count - total_transferred or nil
			local transferred = self:push_items(inv, slot, inv_to, slot_to, remaining)

			total_transferred = total_transferred + transferred

			if count == nil or total_transferred >= count then
				break
			end
		end

		return total_transferred
	end,
}
local METATABLE = { __index = CLASS }

---@param initial_inventories string[]
---@return StorageSystem
local function StorageSystem(initial_inventories)
	local new_storagesystem = setmetatable({
		inventories = {},
		_item_cache = {},
	}, METATABLE)

	for _, inventory in next, initial_inventories do
		new_storagesystem:track_inventory(inventory)
	end

	return new_storagesystem
end

return StorageSystem
