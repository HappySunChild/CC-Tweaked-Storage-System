local menu = require("utility/menus/menu")

local processors_menu = require("utility/menus/processors")

local prompt_checkbox = require("utility/prompt/checkbox")
local prompt_choice = require("utility/prompt/choice")
local prompt_text = require("utility/prompt/text")

local format_name = require("storage/format/format_name")
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

	local iterations = tonumber(
		prompt_text(string.format("Process Iterations | %s", format_pattern(pattern)))
	) or 1

	if iterations == 0 then
		return
	end

	local missing = autocrafter:get_missing_ingredients(pattern, iterations)

	if next(missing) ~= nil then
		term.clear()
		term.setCursorPos(1, 1)

		local list = ""

		for name, count in next, missing do
			list = list .. string.format("MISSING %s -> %d\n", name, count)
		end

		printError(NOT_ENOUGH_INGREDIENTS:format(iterations, format_pattern(pattern), list))

		yield_for_user()

		return
	end

	local chosen_processors = prompt_checkbox(
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

	os.queueEvent("start_crafting", jobs)
end

---@param modem peripheral.Modem
---@param io_inventory string
---@param system StorageSystem
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
