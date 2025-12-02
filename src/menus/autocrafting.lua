local task = require("lib/task")

local menu = require("menus/menu")

local processors_menu = require("menus/processors")

local prompt_checkbox = require("prompt/checkbox")
local prompt_choice = require("prompt/choice")
local prompt_text = require("prompt/text")

local format_name = require("lib/storage").format_name
local pattern_formatter = require("utility/pattern_formatter")
local yield_for_user = require("utility/yield_for_user")

local NOT_ENOUGH_INGREDIENTS = "Not enough ingredients for %dx '%s'\n%s"

---@param autocrafter AutoCrafter
local function prompt_craft(autocrafter)
	local format_pattern = pattern_formatter(autocrafter)

	local pattern =
		prompt_choice(autocrafter:get_registered_patterns(), "Choose Pattern", format_pattern)
	local available_processors = autocrafter:get_available_processors(pattern)

	if #available_processors == 0 then
		term.clear()
		term.setCursorPos(1, 1)
		term.write("No available processors have this pattern!")

		yield_for_user()

		return
	end

	term.clear()

	local count = tonumber(
		prompt_text(string.format("Process Iterations | %s", format_pattern(pattern)))
	) or 1

	if count == 0 then
		return
	end

	local missing = autocrafter:get_missing_ingredients(pattern, count)

	if next(missing) ~= nil then
		term.clear()
		term.setCursorPos(1, 1)

		local list = ""

		local can_subprocess = true

		for ingr_name, ingr_count in next, missing do
			local can_craft = autocrafter:can_craft(ingr_name, ingr_count)

			if not can_craft then
				can_subprocess = false
			end

			list = list
				.. string.format(
					"%s %s -> %d\n",
					can_craft and "CRAFTABLE" or "MISSING",
					ingr_name,
					ingr_count
				)
		end

		if not can_subprocess then
			printError(NOT_ENOUGH_INGREDIENTS:format(count, format_pattern(pattern), list))

			yield_for_user()

			return
		end
	end

	local chosen_processors = prompt_checkbox(
		available_processors,
		string.format("Select Processor Distribution | %dx %s", count, format_pattern(pattern)),
		format_name
	)

	if #chosen_processors == 0 then
		return
	end

	task.spawn(
		autocrafter.start_batch_process_async,
		autocrafter,
		chosen_processors,
		pattern,
		count
	)
end

---@param modem peripheral.Modem
---@param io_inventory string
---@param system ItemStorage
---@param autocrafter AutoCrafter
return function(modem, io_inventory, system, autocrafter)
	menu({ "Craft", "Processor inventories" }, "Auto Processing Menu", function(index)
		if index == 1 then
			prompt_craft(autocrafter)
		elseif index == 2 then
			processors_menu(modem, io_inventory, system, autocrafter)
		end
	end)
end
