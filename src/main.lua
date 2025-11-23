local AutoProcessing = require("AutoProcessing")
local StorageDisplay = require("StorageDisplay")
local StorageSystem = require("StorageSystem")

local repr = require("utility/repr")

local gold_pattern = require("patterns/gold_pattern")
local iron_pattern = require("patterns/iron_pattern")

local system = StorageSystem({
	"minecraft:chest_0",
	"minecraft:chest_1",
})

system:update_inventories()

local auto_processing = AutoProcessing(system, {
	["minecraft:blast_furnace_1"] = { gold_pattern, iron_pattern },
	["minecraft:blast_furnace_2"] = { gold_pattern, iron_pattern },
})

print("starting autoprocessing")

local function bind(inventory, pattern, count)
	return function()
		auto_processing:start_process_async(inventory, pattern, count)
	end
end

parallel.waitForAll(
	bind("minecraft:blast_furnace_1", iron_pattern, 2),
	bind("minecraft:blast_furnace_2", gold_pattern, 2)
)
