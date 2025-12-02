-- This is an example program to demonstrate the usage of the library.
-- Feel free to modify this/use this library in your own projects.

local config = require("lib/config")
local storage = require("lib/storage")
local task = require("lib/task")

local format_name = storage.format_name

local filter = require("utility/filter")
local get_modem_inventories = require("utility/get_modem_inventories")
local reload_patterns = require("utility/reload_patterns")

local prompt_checkbox = require("prompt/checkbox")
local prompt_choice = require("prompt/choice")

local io_menu = require("menus/io")

local modem = peripheral.find("modem") ---@type peripheral.Modem
local this_computer = modem.getNameLocal()

config.load()

local io_inventory = turtle and this_computer or config.get(config.settings.IO_INVENTORY)
local system_inventories = settings.get(config.settings.SYSTEM_INVENTORIES)

if io_inventory == nil or modem.isPresentRemote(io_inventory) and io_inventory ~= this_computer then
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

local terminal_window = window.create(term.current(), 1, 1, width, height - 1, false)

local monitor_display = storage.StorageDisplay(
	monitor,
	{ column_count = config.get(config.settings.MONITORS_COLUMNS), index_justification = 4 }
)
local terminal_display =
	storage.StorageDisplay(terminal_window, { column_count = 2, index_justification = 3 })

task.spawn(function()
	while true do
		system:update_inventories()

		local x, y = term.getCursorPos()

		local items = system:get_system_items_sorted()

		terminal_display:draw_item_cells(items)
		monitor_display:draw_item_cells(items)

		term.setCursorPos(x, y)

		sleep(3)
	end
end)

reload_patterns(autocrafter)

parallel.waitForAny(
	io_menu(modem, io_inventory, system, autocrafter, terminal_window),
	task.start_scheduler
)
