local UNKNOWN_PERIPHERAL = 'Unable to find peripheral "%s"'
local UNKNOWN_INVENTORY = 'Unable to find inventory "%s", is it being tracked?'
local MISSING_INVENTORY_ITEMS = 'Unable to find items for inventory "%s", did you update the cache?'

---@param a peripheral.InventoryItem
---@param b peripheral.InventoryItem
---@return boolean
local function sort_items_descending(a, b)
	if a.count > b.count then
		return true
	end

	return a.count == b.count and a.name < b.name
end

---@class StorageSystem.ItemOccurance
---@field inventory string
---@field slot integer
---@field item peripheral.InventoryItem

---@class StorageSystem
---@field tracked_inventories table<string, peripheral.Inventory>
---@field cached_inventory_items table<string, peripheral.InventoryItem[]>
local CLASS = {
	---@param self StorageSystem
	---@param inv_name string The name of the peripheral to track (i.e. `"left"` or `"minecraft:chest_0"`)
	track_inventory = function(self, inv_name)
		if not peripheral.isPresent(inv_name) then
			error(UNKNOWN_PERIPHERAL:format(inv_name), 2)
		end

		self.tracked_inventories[inv_name] = peripheral.wrap(inv_name)
	end,
	---@param self StorageSystem
	---@param inv_name string The name of the peripheral to stop tracking (i.e. `"left"` or `"minecraft:chest_0"`)
	untrack_inventory = function(self, inv_name)
		self.tracked_inventories[inv_name] = nil
	end,
	---Updates the internal item cache by reading the contents of all the tracked inventories.
	---@param self StorageSystem
	update_cached_items = function(self)
		for inv_name, inventory in next, self.tracked_inventories do
			self.cached_inventory_items[inv_name] = inventory.list()
		end
	end,

	---Calculates the total size (slots) of the system.
	---@param self StorageSystem
	---@return number
	get_system_size = function(self)
		local size = 0

		for _, inventory in next, self.tracked_inventories do
			size = size + inventory.size()
		end

		return size
	end,
	---Returns an array of all the items inside the system, sorted by count highest to least by default.
	---
	---You can optionally specify a sorting function as well.
	---@param self StorageSystem
	---@param sorter? fun(a: peripheral.InventoryItem, b: peripheral.InventoryItem): boolean
	---@return peripheral.InventoryItem[]
	get_system_items = function(self, sorter)
		local total_items = {}

		for _, inv_items in next, self.cached_inventory_items do
			for _, item in next, inv_items do
				local name = item.name
				local count = item.count

				total_items[name] = (total_items[name] or 0) + count
			end
		end

		local output = {}

		for name, total_count in next, total_items do
			table.insert(output, {
				name = name,
				count = total_count,
			})
		end

		table.sort(output, sorter or sort_items_descending)

		return output
	end,

	---Returns the size (slot count) of the specified inventory, if it is connected to the system.
	---@param self StorageSystem
	---@param inv_name string The name of the inventory.
	---@return integer
	get_inventory_size = function(self, inv_name)
		local inventory = self.tracked_inventories[inv_name]

		if inventory == nil then
			error(UNKNOWN_INVENTORY:format(inv_name), 2)
		end

		return inventory.size()
	end,
	---Returns an array of all items inside the specified inventory, if it is connected to the system, sorted by count highest to least by default.
	---
	---You can optionally specify a sorting function as well.
	---@param self StorageSystem
	---@param inv_name string The name of the inventory.
	---@param sorter? fun(a: peripheral.InventoryItem, b: peripheral.InventoryItem): boolean
	---@return peripheral.InventoryItem[]
	get_inventory_items = function(self, inv_name, sorter)
		local inv_items = self.cached_inventory_items[inv_name]

		if inv_items == nil then
			error(MISSING_INVENTORY_ITEMS:format(inv_name), 2)
		end

		local counts = {}

		for _, item in next, inv_items do
			local name = item.name
			local count = item.count

			counts[name] = (counts[name] or 0) + count
		end

		local output = {}

		for name, total_count in next, counts do
			table.insert(output, {
				name = name,
				count = total_count,
			})
		end

		table.sort(output, sorter or sort_items_descending)

		return output
	end,

	---Returns an array of all the occurances where the item appears in the system.
	---@param self StorageSystem
	---@param item_name string
	---@return StorageSystem.ItemOccurance[]
	find_item = function(self, item_name)
		local occurances = {}

		for inv_name, items in next, self.cached_inventory_items do
			for slot, item in next, items do
				if item.name == item_name then
					table.insert(occurances, {
						inventory = inv_name,
						slot = slot,
						item = item,
					})
				end
			end
		end

		return occurances
	end,

	---Pulls items from one inventory into another.
	---@param self StorageSystem
	---@param inv_from string
	---@param slot_from number
	---@param inv_to string
	---@param slot_to? number
	---@param count? number
	---@return number transferred
	pull_items = function(self, inv_from, slot_from, inv_to, slot_to, count)
		local to_inventory = self.tracked_inventories[inv_to] ---@type peripheral.Inventory?

		if to_inventory == nil then
			error(UNKNOWN_INVENTORY:format(inv_to), 2)
		end

		return to_inventory.pullItems(inv_from, slot_from, count, slot_to)
	end,
	---Pushes items from one inventory into another.
	---@param self StorageSystem
	---@param inv_from string
	---@param slot_from number
	---@param inv_to string
	---@param slot_to? number
	---@param count? number
	---@return number transferred
	push_items = function(self, inv_from, slot_from, inv_to, slot_to, count)
		local from_inventory = self.tracked_inventories[inv_from] ---@type peripheral.Inventory?

		if from_inventory == nil then
			error(UNKNOWN_INVENTORY:format(inv_from), 2)
		end

		return from_inventory.pushItems(inv_to, slot_from, count, slot_to)
	end,
}
local METATABLE = { __index = CLASS }

---@param initial_inventories string[]
---@return StorageSystem
local function StorageSystem(initial_inventories)
	local new_storagesystem = setmetatable({
		tracked_inventories = {},
		cached_inventory_items = {},
	}, METATABLE)

	for _, inventory in next, initial_inventories do
		new_storagesystem:track_inventory(inventory)
	end

	return new_storagesystem
end

return StorageSystem
