local config = require("lib/config")

local menu = require("menus/menu")

local pattern_menu = require("menus/pattern")

local prompt_checkbox = require("prompt/checkbox")

local filter = require("utility/filter")
local format_name = require("lib/storage").format_name
local get_modem_inventories = require("utility/get_modem_inventories")
local yield_for_user = require("utility/yield_for_user")

local function update_autocrafting_setting(autocrafting)
	local processors = {}

	for proc_name, info in next, autocrafting.processors do
		processors[proc_name] = info.patterns
	end

	config.set(config.settings.PROCESSORS, processors)
	config.save()
end

local function configure_processors(autocrafter)
	local processors = autocrafter:get_processors()

	if #processors <= 0 then
		term.clear()
		term.setCursorPos(1, 1)
		term.write("No processors have been registered!")

		yield_for_user()

		return
	end

	local selected_processors =
		prompt_checkbox(processors, "Select processors to configure", format_name)

	if #selected_processors == 0 then
		return
	end

	pattern_menu(selected_processors, autocrafter)

	update_autocrafting_setting(autocrafter)
end
local function register_processor(modem, io_inventory, system, autocrafter)
	---@return string[]
	local function get_free_inventories()
		return filter(get_modem_inventories(modem), function(_, inventory)
			return not (
				inventory == io_inventory
				or system.inventories[inventory] ~= nil
				or autocrafter.processors[inventory] ~= nil
			)
		end)
	end

	local choices = prompt_checkbox(get_free_inventories(), "Register Processors", format_name)

	for _, proc_name in ipairs(choices) do
		autocrafter:add_processor(proc_name, {})
	end

	update_autocrafting_setting(autocrafter)
end
local function deregister_processor(autocrafter)
	local choices =
		prompt_checkbox(autocrafter:get_processors(), "Deregister Processors", format_name)

	for _, proc_name in ipairs(choices) do
		autocrafter:remove_processor(proc_name)
	end

	update_autocrafting_setting(autocrafter)
end

---@param modem peripheral.Modem
---@param io_inventory string
---@param system ItemStorage
---@param autocrafter AutoCrafter
return function(modem, io_inventory, system, autocrafter)
	menu(
		{ "Configure patterns", "Register", "Deregister" },
		"Processor Inventories",
		function(index)
			if index == 1 then
				configure_processors(autocrafter)
			elseif index == 2 then
				register_processor(modem, io_inventory, system, autocrafter)
			elseif index == 3 then
				deregister_processor(autocrafter)
			end
		end
	)
end
