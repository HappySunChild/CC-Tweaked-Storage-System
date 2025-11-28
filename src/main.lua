-- This is an example program to demonstrate the usage of the library.
-- Feel free to modify this/use this library in your own projects.

local completion = require("cc/completion")

local format_name = require("storage/utility/format_name")
local storage = require("storage/lib")

local filter = require("utility/filter")
local prompting = require("utility/prompting")
local yield_for_user = require("utility/yield_for_user")

local SETTING_IO_INVENTORY = "storage.io_inv"
local SETTING_SYSTEM_INVENTORIES = "storage.system_invs"
local SETTING_PROCESSORS = "storage.processors"

local EXPORTING_ITEM = "Exporting %d items..."
local IMPORING_ITEM = "Importing items..."
local ITEMS_TRANSFERRED = "Transferred %d items."

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

settings.load()

local io_inventory = settings.get(SETTING_IO_INVENTORY)
local system_inventories = settings.get(SETTING_SYSTEM_INVENTORIES)

if io_inventory == nil or not modem.isPresentRemote(io_inventory) then
	io_inventory =
		prompting.choice_list(get_modem_inventories(), "Choose IO Inventory", format_name)

	settings.set(SETTING_IO_INVENTORY, io_inventory)
	settings.save()
end

if system_inventories == nil then
	system_inventories = prompting.checkbox_list(
		filter(get_modem_inventories(), function(_, value)
			return value ~= io_inventory
		end),
		"Select System Inventories",
		format_name
	)

	settings.set(SETTING_SYSTEM_INVENTORIES, system_inventories)
	settings.save()
end

local system = storage.StorageSystem(system_inventories)
local autoprocessing = storage.AutoProcessing(system, settings.get(SETTING_PROCESSORS, {}))

local width, height = term.getSize()

local monitor = peripheral.find("monitor") ---@type peripheral.Monitor
monitor.setTextScale(0.5)

local output_window =
	window.create(term.current(), width * 2 / 3, 2, math.ceil(width / 3), height - 2, false)
local terminal_window = window.create(term.current(), 1, 1, width, height - 1, false)

local monitor_display =
	storage.StorageDisplay(monitor, { column_count = 2, index_justification = 4 })
local output_display =
	storage.StorageDisplay(output_window, { column_count = 1, index_justification = 3 })
local terminal_display =
	storage.StorageDisplay(terminal_window, { column_count = 2, index_justification = 3 })

local function reload_patterns()
	local cur_dir = fs.getDir(shell.getRunningProgram())
	local pattern_dir = fs.combine(cur_dir, "patterns")

	for _, file in ipairs(fs.list(pattern_dir)) do
		local no_extension = file:gsub("%..*", "")

		autoprocessing:register_pattern(no_extension, require("patterns/" .. no_extension))
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
	local choices = {}

	for item_name in next, system:get_system_items() do
		local start, _ = string.find(item_name, partial)

		if start ~= nil then
			table.insert(choices, item_name:sub(start, -1))
		end
	end

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

---@param pattern string
---@return string
local function format_pattern(pattern)
	local info = autoprocessing:get_pattern_info(pattern)

	if info == nil then
		return "UNKNOWN PATTERN"
	end

	return info.label
end
---@return string[]
local function prompt_patterns()
	return prompting.checkbox_list(
		autoprocessing:get_registered_patterns(),
		"Choose Patterns",
		format_pattern
	)
end

local function update_autoprocessing_setting()
	local processors = {}

	for proc_name, info in next, autoprocessing.processors do
		processors[proc_name] = info.patterns
	end

	settings.set(SETTING_PROCESSORS, processors)
	settings.save()
end

----------------------------------------------------------------------------------------------------

local function output_prompt()
	output_window.setVisible(true)

	local function loop()
		term.clear()

		output_window.redraw()

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

			yield_for_user()

			return false
		end

		term.clear()

		output_window.redraw()

		local count_input = prompting.text_page(
			string.format(
				"Item Count - %s | %d in system",
				format_name(target_item),
				system_items[target_item]
			),
			"'cancel' to restart"
		)

		if count_input == "cancel" then
			return false
		end

		local count = tonumber(count_input) or 64

		print(EXPORTING_ITEM:format(count))

		local transferred = system:export_item(target_item, io_inventory, nil, count)

		print(ITEMS_TRANSFERRED:format(transferred))

		yield_for_user()
	end

	while true do
		if loop() then
			break
		end
	end

	output_window.setVisible(false)
end
local function input_prompt()
	local _, index =
		prompting.choice_list({ "yesss!!!!!!", "wait nvm" }, "Storage System Input - Are you sure?")

	if index == 2 then
		return
	end

	term.clear()
	term.setCursorPos(1, 1)

	print(IMPORING_ITEM)

	local transferred = system:import_inventory(io_inventory)

	print(ITEMS_TRANSFERRED:format(transferred))

	yield_for_user()
end
local function show_display()
	term.clear()
	term.setCursorPos(1, height)
	term.write("Press any key to return")

	terminal_window.setVisible(true)

	yield_for_user()

	terminal_window.setVisible(false)
end

---@param processors string[]
local function add_patterns(processors)
	local patterns = prompt_patterns()

	for _, proc_name in ipairs(processors) do
		for _, pattern in ipairs(patterns) do
			autoprocessing:add_pattern_to_processor(proc_name, pattern)
		end
	end
end
---@param processors string[]
local function remove_patterns(processors)
	local patterns = prompt_patterns()

	for _, proc_name in ipairs(processors) do
		for _, pattern in ipairs(patterns) do
			autoprocessing:remove_pattern_from_processor(proc_name, pattern)
		end
	end
end
---@param processors string[]
local function pattern_menu(processors)
	local MENU_CHOICES = { "Add patterns", "Remove patterns" }

	menu(
		MENU_CHOICES,
		string.format("Processor Patterns | %d Selected", #processors),
		function(index)
			if index == 1 then
				add_patterns(processors)
			else
				remove_patterns(processors)
			end
		end
	)
end

local function configure_processors()
	local processors = autoprocessing:get_processors()

	if #processors <= 0 then
		term.clear()
		term.setCursorPos(1, 1)
		term.write("No processors have been registered!")

		yield_for_user()

		return
	end

	local selected_processors =
		prompting.checkbox_list(processors, "Select processors to configure", format_name)

	if #selected_processors == 0 then
		return
	end

	pattern_menu(selected_processors)

	update_autoprocessing_setting()
end
local function register_processor()
	local choices =
		prompting.checkbox_list(get_free_inventories(), "Register Processors", format_name)

	for _, proc_name in ipairs(choices) do
		autoprocessing:add_processor(proc_name, {})
	end

	update_autoprocessing_setting()
end
local function deregister_processor()
	local choices = prompting.checkbox_list(
		autoprocessing:get_processors(),
		"Deregister Processors",
		format_name
	)

	for _, proc_name in ipairs(choices) do
		autoprocessing:remove_processor(proc_name)
	end

	update_autoprocessing_setting()
end
local function processors_menu()
	menu(
		{ "Configure patterns", "Register", "Deregister" },
		"Processor Inventories",
		function(index)
			if index == 1 then
				configure_processors()
			elseif index == 2 then
				register_processor()
			elseif index == 3 then
				deregister_processor()
			end
		end
	)
end

---@class ProcessingJob
---@field processor string
---@field pattern string
---@field count integer

local function craft()
	local pattern = prompting.choice_list(
		autoprocessing:get_registered_patterns(),
		"Choose Pattern",
		format_pattern
	)
	local available_processors = autoprocessing:get_available_processors(pattern)

	if #available_processors == 0 then
		term.clear()
		term.setCursorPos(1, 1)
		term.write("No available processors have this pattern!")

		yield_for_user()

		return
	end

	term.clear()

	local iterations = tonumber(
		prompting.text_page(string.format("Process Iterations | %s", format_pattern(pattern)))
	) or 1

	if iterations == 0 then
		return
	end

	local chosen_processors = prompting.checkbox_list(
		available_processors,
		string.format("Select Processor Distribution | %dx %s", iterations, format_pattern(pattern)),
		format_name
	)

	if #chosen_processors == 0 then
		return
	end

	local tasks_per_processor = math.floor(iterations / #chosen_processors)
	local extra_tasks = iterations % #chosen_processors

	local jobs = {}

	for _, proc_name in ipairs(chosen_processors) do
		local extra = 0

		if extra_tasks > 0 then
			extra_tasks = extra_tasks - 1

			extra = 1
		end

		table.insert(jobs, {
			processor = proc_name,
			pattern = pattern,
			count = tasks_per_processor + extra,
		})
	end

	os.queueEvent("start_processing", jobs)
end

local function auto_processing_menu()
	menu({ "Craft", "Processor inventories" }, "Auto Processing Menu", function(index)
		if index == 1 then
			craft()
		elseif index == 2 then
			processors_menu()
		end
	end)
end

-- Parallel functions

local function io_menu()
	menu(
		{ "Storage output", "Storage input", "Processing", "View chart" },
		"Storage IO Menu",
		function(index)
			if index == 1 then
				output_prompt()
			elseif index == 2 then
				input_prompt()
			elseif index == 3 then
				auto_processing_menu()
			elseif index == 4 then
				show_display()
			end
		end
	)

	term.clear()
	term.setCursorPos(1, 1)
end

local function auto_processing_manager()
	while true do
		local _, jobs = os.pullEvent("start_processing") ---@type string, ProcessingJob[]
		local tasks = {}

		for _, job in ipairs(jobs) do
			local runner = function()
				autoprocessing:start_process_async(job.processor, job.pattern, job.count)
			end

			table.insert(tasks, runner)
		end

		parallel.waitForAll(table.unpack(tasks))
	end
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

reload_patterns()

parallel.waitForAny(io_menu, auto_processing_manager, periodic_update)
