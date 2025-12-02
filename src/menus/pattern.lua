local menu = require("menus/menu")

local prompt_checkbox = require("prompt/checkbox")

local pattern_formatter = require("utility/pattern_formatter")
local reload_patterns = require("utility/reload_patterns")

---@param autocrafter AutoCrafter
---@return string[]
local function prompt_patterns(autocrafter)
	return prompt_checkbox(
		autocrafter:get_registered_patterns(),
		"Choose Patterns",
		pattern_formatter(autocrafter)
	)
end

---@param processors string[]
---@param autocrafter AutoCrafter
local function add_patterns(processors, autocrafter)
	local patterns = prompt_patterns(autocrafter)

	for _, proc_name in ipairs(processors) do
		for _, pattern in ipairs(patterns) do
			autocrafter:add_pattern_to_processor(proc_name, pattern)
		end
	end
end
---@param processors string[]
---@param autocrafter AutoCrafter
local function remove_patterns(processors, autocrafter)
	local patterns = prompt_patterns(autocrafter)

	for _, proc_name in ipairs(processors) do
		for _, pattern in ipairs(patterns) do
			autocrafter:remove_pattern_from_processor(proc_name, pattern)
		end
	end
end

---@param processors string[]
---@param autocrafter AutoCrafter
return function(processors, autocrafter)
	local MENU_CHOICES = { "Add patterns", "Remove patterns", "Reload patterns" }

	menu(
		MENU_CHOICES,
		string.format("Processor Patterns | %d Selected", #processors),
		function(index)
			if index == 1 then
				add_patterns(processors, autocrafter)
			elseif index == 2 then
				remove_patterns(processors, autocrafter)
			elseif index == 3 then
				reload_patterns(autocrafter)
			end
		end
	)
end
