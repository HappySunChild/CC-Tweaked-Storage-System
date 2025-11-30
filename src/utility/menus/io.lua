local menu = require("utility/menus/menu")

local autocrafting_menu = require("utility/menus/autocrafting")

local prompt_choice = require("utility/prompt/choice")
local prompt_text = require("utility/prompt/text")

local choose_nearest = require("utility/choose_nearest")
local format_name = require("storage/format/format_name")
local yield_for_user = require("utility/yield_for_user")

local EXPORTING_ITEM = "Exporting %d items..."
local IMPORING_ITEM = "Importing items..."
local ITEMS_TRANSFERRED = "Transferred %d items."

---@param io_inventory string
---@param system StorageSystem
---@param output_window window.Window
local function output_prompt(io_inventory, system, output_window)
	output_window.setVisible(true)

	---@param partial string
	---@return string[]
	local function system_autocomplete(partial)
		local choices = {}

		for item_name in next, system:get_system_items() do
			local _, finish = string.find(item_name, partial)

			if finish ~= nil then
				table.insert(choices, item_name:sub(finish + 1, -1))
			end
		end

		return choices
	end

	local function loop()
		term.clear()

		output_window.redraw()

		local item_input =
			prompt_text("Storage System Output", "'exit' to return to menu", system_autocomplete)

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

		local count_input = prompt_text(
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
---@param io_inventory string
---@param system StorageSystem
local function input_prompt(io_inventory, system)
	local _, index =
		prompt_choice({ "yesss!!!!!!", "wait nvm" }, "Storage System Input - Are you sure?")

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
---@param terminal_window window.Window
local function show_display(terminal_window)
	local _, height = term.getSize()

	term.clear()
	term.setCursorPos(1, height)
	term.write("Press any key to return")

	terminal_window.setVisible(true)

	yield_for_user()

	terminal_window.setVisible(false)
end

---@param modem peripheral.Modem
---@param io_inventory string
---@param system StorageSystem
---@param autocrafter AutoCrafter
---@param output_window window.Window
---@param terminal_window window.Window
return function(modem, io_inventory, system, autocrafter, output_window, terminal_window)
	return function()
		menu(
			{ "Storage output", "Storage input", "Processing", "View chart" },
			"Storage IO Menu",
			function(index)
				if index == 1 then
					output_prompt(io_inventory, system, output_window)
				elseif index == 2 then
					input_prompt(io_inventory, system)
				elseif index == 3 then
					autocrafting_menu(modem, io_inventory, system, autocrafter)
				elseif index == 4 then
					show_display(terminal_window)
				end
			end
		)

		term.clear()
		term.setCursorPos(1, 1)
	end
end
