-- This is an example program to demonstrate the usage of the library.
-- Feel free to modify this/use this library in your own projects.

local storage = require("storage/lib")

local format_name = require("storage/format/format_name")

local config = require("utility/config")
local filter = require("utility/filter")
local get_modem_inventories = require("utility/get_modem_inventories")
local reload_patterns = require("utility/reload_patterns")

local prompt_checkbox = require("utility/prompt/checkbox")
local prompt_choice = require("utility/prompt/choice")

local io_menu = require("utility/menus/io")

local modem = peripheral.find("modem") ---@type peripheral.Modem

config.load()

local io_inventory = config.get(config.settings.IO_INVENTORY)
local system_inventories = settings.get(config.settings.SYSTEM_INVENTORIES)

if io_inventory == nil or not modem.isPresentRemote(io_inventory) then
	io_inventory = prompt_choice(get_modem_inventories(modem), "Choose IO Inventory", format_name)

	config.set(config.settings.IO_INVENTORY, io_inventory)
end

if system_inventories == nil then
	system_inventories = prompt_checkbox(
		filter(get_modem_inventories(modem), function(_, value)
			return value ~= io_inventory
		end),
		"Select System Inventories",
		format_name
	)

	config.set(config.settings.SYSTEM_INVENTORIES, system_inventories)
end

config.save()

local system = storage.ItemStorage(system_inventories)
local autocrafter = storage.AutoCrafter(system, config.get(config.settings.PROCESSORS))

local monitor = peripheral.find("monitor") ---@type peripheral.Monitor
monitor.setTextScale(0.5)

local width, height = term.getSize()

local output_window =
	window.create(term.current(), width * 2 / 3, 2, math.ceil(width / 3), height - 2, false)
local terminal_window = window.create(term.current(), 1, 1, width, height - 1, false)

local monitor_display = storage.StorageDisplay(
	monitor,
	{ column_count = config.get(config.settings.MONITORS_COLUMNS), index_justification = 4 }
)
local output_display =
	storage.StorageDisplay(output_window, { column_count = 1, index_justification = 3 })
local terminal_display =
	storage.StorageDisplay(terminal_window, { column_count = 2, index_justification = 3 })

-- Parallel functions

local function autocrafting_manager()
	local _, processors, pattern, count, id = os.pullEvent("start_crafting") ---@type string, string[], string, integer, any

	local function run_all()
		autocrafter:start_batch_process_async(processors, pattern, count)

		os.queueEvent("crafting_finished", id)
	end

	parallel.waitForAll(run_all, autocrafting_manager)
end

local function periodic_update()
	while true do
		system:update_inventories()

		local x, y = term.getCursorPos()

		local items = system:get_system_items_sorted()

		output_display:draw_item_cells(items)
		terminal_display:draw_item_cells(items)
		monitor_display:draw_item_cells(items)

		term.setCursorPos(x, y)

		sleep(5)
	end
end

reload_patterns(autocrafter)

parallel.waitForAny(
	io_menu(modem, io_inventory, system, autocrafter, output_window, terminal_window),
	autocrafting_manager,
	periodic_update
)
