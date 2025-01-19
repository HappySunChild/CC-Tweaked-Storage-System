local cache =  require("utility.cache")
local config = require("config")

local system = {}
system.BufferInventory = nil ---@type peripheral.Inventory

system.SlotCount = 0
system.Items = {} ---@type table<peripheral.Inventory, peripheral.inventoryItem[]>
system.Inventories = {} ---@type peripheral.Inventory[]

local function filterName(rawName)
	local name = rawName:match("[^:]*$")
	local filtered = name:gsub("_", " ")

	return filtered
end

local inventoryNameCache = cache.new(peripheral.getName)
local nbtItemNameCache = cache.new()


function system:InitiatePeripherals()
	local bufferInventory = config:Get("BufferInventory")

	self.BufferInventory = peripheral.wrap(bufferInventory)

	---@type peripheral.Inventory[]
	local inventories =
		{ peripheral.find("inventory", function(name)
			return name ~= "right" and name ~= bufferInventory
		end) }

	local list = {}

	for _, inventory in ipairs(inventories) do
		list[inventory] = {}
	end

	self.Items = list
	self.Inventories = inventories

	self:Update()
end

function system:Update()
	for inventory, _ in pairs(self.Items) do
		self.Items[inventory] = inventory.list()
	end

	self.SlotCount = self:GetSystemSize()

	os.queueEvent("system_updated")
end




function system:IsValidInventory(inventory)
	if not inventory then
		return false
	end

	return self.Items[inventory] ~= nil
end

function system:GetInventory(index)
	return self.Inventories[index]
end

function system:GetInventoryName(index)
	local inv = self:GetInventory(index)

	if not inv then
		return
	end

	return inventoryNameCache:get(inv)
end



function system:GetInventoryItems(inventory)
	local list = {}
	local counts = self:GetInventoryItemCounts(inventory)

	for name, count in pairs(counts) do
		---@type peripheral.inventoryItem
		local itemData = {
			name = name,
			count = count,
		}

		table.insert(list, itemData)
	end

	return list
end

function system:GetSystemItems()
	local list = {}
	local counts = self:GetSystemItemCounts()

	for name, count in pairs(counts) do
		---@type peripheral.inventoryItem
		local itemData = {
			name = name,
			count = count,
		}

		table.insert(list, itemData)
	end

	return list
end

function system:GetSystemSize()
	local slotCount, itemCount = 0, 0

	for inv, invItems in pairs(self.Items) do
		slotCount = slotCount + inv.size()

		for _, item in pairs(invItems) do
			itemCount = itemCount + item.count
		end
	end

	return slotCount, itemCount
end



function system:GetInventoryItemCounts(inventory)
	local counts = {}

	for _, item in pairs(self.Items[inventory]) do
		local name = self:GetItemName(item)
		local current = counts[name] or 0

		counts[name] = current + item.count
	end

	return counts
end

function system:GetSystemItemCounts()
	local counts = {}

	for _, invItems in pairs(self.Items) do
		for _, item in pairs(invItems) do
			local name = self:GetItemName(item)
			local current = counts[name] or 0

			counts[name] = current + item.count
		end
	end

	return counts
end

function system:GetSystemCount(name)
	local counts = self:GetSystemItemCounts()

	return counts[name] or 0
end



function system:FindSystemItem(name, nbt)
	for inv, invItems in pairs(self.Items) do
		for slot, item in pairs(invItems) do
			local nbtOk = item.nbt == nbt and item.name == name and nbt ~= nil

			if nbtOk or filterName(self:GetItemName(item)) == filterName(name) then
				return inv, slot, item
			end
		end
	end
end

---@param item peripheral.inventoryItem
function system:GetItemName(item)
	if item.nbt then
		local index = string.format("%s:%s", item.name, item.nbt)

		return nbtItemNameCache:get(index, function()
			local inv, slot = self:FindSystemItem(item.name, item.nbt)
			local detail = inv.getItemDetail(slot)

			return detail.displayName:lower()
		end)
	end

	return item.name:lower()
end



function system:PushItems(name, count)
	local inv, slot, item = self:FindSystemItem(name)

	if not (inv and slot and item) then
		return false
	end

	local outputName = peripheral.getName(self.BufferInventory)

	local totalTransfered = 0

	repeat
		local remaining = count - totalTransfered
		local transfered = inv.pushItems(outputName, slot, remaining)

		totalTransfered = totalTransfered + transfered

		if transfered == 0 then
			if remaining >= item.count then
				self:Update()

				inv, slot, item = self:FindSystemItem(item.name)

				if not (item and slot and item) then
					return false
				end
			end
		end
	until totalTransfered >= count

	self:Update()

	return true
end

function system:PullItems()
	local outputName = peripheral.getName(self.BufferInventory)

	for slot, item in pairs(self.BufferInventory.list()) do
		local inv = self:FindSystemItem(item.name, item.nbt)

		if not inv then
			inv = self.Inventories[1]
		end

		inv.pullItems(outputName, slot, item.count)
	end

	self:Update()
end

return system
