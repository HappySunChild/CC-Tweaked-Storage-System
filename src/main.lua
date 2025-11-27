-- This is an example program to demonstrate the usage of the library.
-- Feel free to modify this/use this library in your own projects.

local completion = require("cc/completion")

local get_display_name = require("storage/utility/get_display_name")
local storage = require("storage/lib")

local filter = require("utility/filter")
local prompting = require("utility/prompting")

local modem = peripheral.find("modem") ---@type peripheral.Modem

---@return string[]
local function get_modem_inventories()
	local inventories = {}

	for _, name in ipairs(modem.getNamesRemote()) do
		if peripheral.hasType(name, "inventory") then
			table.insert(inventories, name)
		end
	end

	table.sort(inventories)

	return inventories
end

local io_inventory = nil

if io_inventory == nil or not modem.isPresentRemote(io_inventory) then
	io_inventory =
		prompting.choice_list(get_modem_inventories(), "Choose IO Inventory", get_display_name)
end

local system_inventories = prompting.checkbox_list(
	filter(get_modem_inventories(), function(_, value)
		return value ~= io_inventory
	end),
	"Select System Inventories",
	get_display_name
)

local system = storage.StorageSystem(system_inventories)
local autoprocessing = storage.AutoProcessing(system, {})

local width, height = term.getSize()

local terminal_window =
	window.create(term.current(), width * 2 / 3, 2, math.ceil(width / 3), height - 2, false)
local monitor = peripheral.find("monitor") ---@type peripheral.Monitor
monitor.setTextScale(0.5)

local monitor_display = storage.StorageDisplay(monitor, {
	column_count = 2,

	count_justification = 6,
	index_justification = 4,
})
local terminal_display = storage.StorageDisplay(terminal_window, {
	column_count = 1,

	count_justification = 4,
	index_justification = 3,
})

local loaded_patterns = {}

local function reload_patterns()
	local cur_dir = fs.getDir(shell.getRunningProgram())
	local pattern_dir = fs.combine(cur_dir, "patterns")

	for _, file in ipairs(fs.list(pattern_dir)) do
		local no_extension = file:gsub("%..*", "")

		loaded_patterns[no_extension] = require("patterns/" .. no_extension)
	end
end

---@param list string[]
---@param target string
---@return string?
local function choose_nearest(list, target)
	local best = nil
	local record = math.huge

	for _, str in ipairs(list) do
		local start = string.find(str, target)

		if start and start < record then
			record = start
			best = str
		end
	end

	return best
end

---@param partial string
---@return string[]
local function system_autocomplete(partial)
	local found = {}

	for item_name in next, system:get_system_items() do
		local _, finish = string.find(item_name, partial)

		if finish ~= nil then
			table.insert(found, { name = item_name, index = finish })
		end
	end

	table.sort(found, function(a, b)
		return a.index < b.index
	end)

	local choices = {}

	for _, occurance in ipairs(found) do
		table.insert(choices, occurance.name:sub(occurance.index, -1))
	end

	table.insert(choices, "exit")

	return completion.choice(partial, choices, false)
end

---@return string[]
local function get_free_inventories()
	return filter(get_modem_inventories(), function(_, inventory)
		return not (
			inventory == io_inventory
			or system.inventories[inventory] ~= nil
			or autoprocessing.processors[inventory] ~= nil
		)
	end)
end

---@param options string[]
---@param title string
---@param callback fun(index: integer, choice: string)
local function menu(options, title, callback)
	table.insert(options, "Exit")

	while true do
		local choice, index = prompting.choice_list(options, title)

		if index == #options then
			break
		end

		callback(index, choice)
	end
end

----------------------------------------------------------------------------------------------------

local function output_prompt()
	terminal_display:draw_item_cells(system:get_system_items_sorted())
	terminal_window.setVisible(true)

	local function loop()
		term.clear()

		terminal_window.redraw()

		local item_input = prompting.text_page(
			"Storage System Output",
			"'exit' to return to menu",
			system_autocomplete
		)

		if item_input == "exit" then
			return true
		end

		local system_items = system:get_system_items()
		local item_list = {}

		for name in next, system_items do
			table.insert(item_list, name)
		end

		local target_item = choose_nearest(item_list, item_input)

		if target_item == nil then
			printError(string.format("Unable to find '%s'", item_input))

			os.pullEvent("key")
			os.pullEvent("key_up")

			return false
		end

		term.clear()

		terminal_window.redraw()

		local count_input = prompting.text_page(
			string.format(
				"Item Count - %s | %d in system",
				get_display_name(target_item),
				system_items[target_item]
			),
			"'cancel' to restart"
		)

		if count_input == "cancel" then
			return false
		end

		local count = tonumber(count_input) or 64
		local transferred = system:export_item(target_item, io_inventory, nil, count)

		print(string.format("Successfully transferred %d items.", transferred))

		os.pullEvent("key")
		os.pullEvent("key_up")
	end

	while not loop() do
	end

	terminal_window.setVisible(false)
end
local function input_prompt()
	local _, index =
		prompting.choice_list({ "yesss!!!!!!", "wait nvm" }, "Storage System Input - Are you sure?")

	if index == 2 then
		return
	end

	term.clear()
	term.setCursorPos(1, 1)

	print("Importing...")

	local transferred = system:import_inventory(io_inventory)

	print(string.format("Successfully transferred %d items.", transferred))

	os.pullEvent("key")
	os.pullEvent("key_up")
end

---@return AutoProcessing.Pattern[]
local function prompt_patterns()
	local list = {}

	for name in next, loaded_patterns do
		table.insert(list, name)
	end

	local chosen = prompting.checkbox_list(list, "Choose Patterns", function(choice)
		return choice .. ".lua"
	end)

	local patterns = {}

	for _, name in next, chosen do
		table.insert(patterns, loaded_patterns[name])
	end

	return patterns
end
---@param processors string[]
local function add_patterns(processors)
	local patterns = prompt_patterns()

	for _, proc_name in ipairs(processors) do
		for _, pattern in ipairs(patterns) do
			autoprocessing:add_pattern(proc_name, pattern)
		end
	end
end
---@param processors string[]
local function remove_patterns(processors)
	local patterns = prompt_patterns()

	for _, proc_name in ipairs(processors) do
		for _, pattern in ipairs(patterns) do
			autoprocessing:remove_pattern(proc_name, pattern)
		end
	end
end
---@param processors string[]
local function pattern_menu(processors)
	local MENU_CHOICES = { "Add Patterns", "Remove Patterns" }

	menu(MENU_CHOICES, "Patterns", function(index)
		if index == 1 then
			add_patterns(processors)
		else
			remove_patterns(processors)
		end
	end)
end

local function configure_processors()
	local processors = autoprocessing:get_processors()

	if #processors <= 0 then
		term.clear()
		term.setCursorPos(1, 1)
		term.write("No processors detected.")

		os.pullEvent("key")
		os.pullEvent("key_up")

		return
	end

	local selected_processors =
		prompting.checkbox_list(processors, "Select Processors", get_display_name)

	if #selected_processors == 0 then
		return
	end

	pattern_menu(selected_processors)
end
local function add_processor()
	local choices =
		prompting.checkbox_list(get_free_inventories(), "Add Processors", get_display_name)

	for _, proc_name in ipairs(choices) do
		autoprocessing:add_processor(proc_name, {})
	end
end
local function remove_processor()
	local choices = prompting.checkbox_list(
		autoprocessing:get_processors(),
		"Remove Processors",
		get_display_name
	)

	for _, proc_name in ipairs(choices) do
		autoprocessing:remove_processor(proc_name)
	end
end
local function processors_menu()
	menu(
		{ "Configure Processor", "Add Processor", "Remove Processor" },
		"Processors",
		function(index)
			if index == 1 then
				configure_processors()
			elseif index == 2 then
				add_processor()
			elseif index == 3 then
				remove_processor()
			end
		end
	)
end

local function auto_processing_menu()
	menu({ "Craft", "Processors" }, "Auto Processing Menu", function(index)
		if index == 1 then
		elseif index == 2 then
			processors_menu()
		end
	end)
end

-- Parallel functions

local function io_menu()
	menu(
		{ "Output from Storage", "Input to Storage", "Auto Processing" },
		"Storage IO Menu",
		function(index, choice)
			if index == 1 then
				output_prompt()
			elseif index == 2 then
				input_prompt()
			elseif index == 3 then
				auto_processing_menu()
			end
		end
	)

	term.clear()
	term.setCursorPos(1, 1)
end

local function auto_processing_manager()
	while true do
		local _, info = os.pullEvent("processing_job")

		print(info)
	end
end

local function periodic_update()
	while true do
		system:update_inventories()

		monitor_display:draw_item_cells(system:get_system_items_sorted())

		sleep(5)
	end
end

reload_patterns()

parallel.waitForAny(io_menu, auto_processing_manager, periodic_update)
