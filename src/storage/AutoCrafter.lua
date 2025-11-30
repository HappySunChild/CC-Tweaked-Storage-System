local find = require("storage/utility/find")

local UNKNOWN_PERIPHERAL = 'Unable to find peripheral "%s"'
local UNKNOWN_PROCESSOR = 'Unable to find processor "%s", did you add it?'
local PATTERN_NOT_SUPPORTED = 'Processor "%s" does not support this pattern!'
local PROCESSOR_BUSY = 'Processor "%s" is busy!'
local NOT_ENOUGH_INGREDIENTS = "Not enough ingredients!"

---Returns a dictionary of ingredients needed to produce a pattern.
---@param pattern AutoCrafter.PatternInfo
---@param iterations integer
---@return table<string, integer>
local function get_pattern_ingredients(pattern, iterations)
	local requirements = {}

	for _, ingredient in next, pattern.input_slots do
		local ingr_count, ingr_name = ingredient[1], ingredient[2]

		requirements[ingr_name] = (requirements[ingr_name] or 0) + (ingr_count * iterations)
	end

	return requirements
end

---comment
---@param pattern AutoCrafter.PatternInfo
---@return integer count
local function get_pattern_output_count(pattern)
	local total_count = 0

	for _, count in next, pattern.results do
		total_count = total_count + count
	end

	return total_count
end

---@class AutoCrafter.PatternItem
---@field [1] integer
---@field [2] string

---@class AutoCrafter.PatternInfo
---@field results table<string, integer>
---@field input_slots AutoCrafter.PatternItem[] Slots to input items into.
---@field output_slots number[] Slots to constantly pull into the system.
---@field poll_rate number How frequently the processor checks the output per second.
---@field label string

---@class AutoCrafter.Processor
---@field patterns string[]
---@field in_use boolean

---@class AutoCrafter
---@field processors table<string, AutoCrafter.Processor>
---@field package _patterns table<string, AutoCrafter.PatternInfo>
---@field package _system StorageSystem
local CLASS = {
	---Registers a pattern.
	---@param self AutoCrafter
	---@param pattern string
	---@param info AutoCrafter.PatternInfo
	register_pattern = function(self, pattern, info)
		self._patterns[pattern] = info
	end,
	---Deregisters a pattern.
	---@param self AutoCrafter
	---@param pattern string
	deregister_pattern = function(self, pattern)
		self._patterns[pattern] = nil
	end,
	---Returns an array of all registers patterns.
	---@param self AutoCrafter
	---@return string[]
	get_registered_patterns = function(self)
		local list = {}

		for name in next, self._patterns do
			table.insert(list, name)
		end

		return list
	end,
	---Returns the info of the pattern if it has been registered, otherwise it returns nil.
	---@param self AutoCrafter
	---@param pattern string
	---@return AutoCrafter.PatternInfo?
	get_pattern_info = function(self, pattern)
		return self._patterns[pattern]
	end,

	---Adds a processor to the AutoProcessing manager.
	---@param self AutoCrafter
	---@param proc_name string The name of the inventory the processor uses.
	---@param patterns string[] All of the patterns this processor supports.
	add_processor = function(self, proc_name, patterns)
		if not peripheral.isPresent(proc_name) then
			error(UNKNOWN_PERIPHERAL:format(proc_name), 2)
		end

		self.processors[proc_name] = {
			patterns = patterns,
			in_use = false,
		}
	end,
	---Removes a processor from the AutoProcessing manager
	---@param self AutoCrafter
	---@param proc_name string The name of the inventory the processor uses.
	remove_processor = function(self, proc_name)
		self.processors[proc_name] = nil
	end,
	---Returns an array of all the processors in the AutoProcessing manager.
	---@param self AutoCrafter
	---@return string[]
	get_processors = function(self)
		local processors = {}

		for proc_name in next, self.processors do
			table.insert(processors, proc_name)
		end

		return processors
	end,

	---Adds a pattern to a processor.
	---@param self AutoCrafter
	---@param proc_name string
	---@param pattern string
	add_pattern_to_processor = function(self, proc_name, pattern)
		local processor = self.processors[proc_name]

		if processor == nil then
			error(UNKNOWN_PROCESSOR:format(proc_name), 2)
		end

		if find(processor.patterns, pattern) then
			return
		end

		table.insert(processor.patterns, pattern)
	end,
	---Removes a pattern from a processor.
	---@param self AutoCrafter
	---@param proc_name string
	---@param pattern string
	remove_pattern_from_processor = function(self, proc_name, pattern)
		local processor = self.processors[proc_name]

		if processor == nil then
			error(UNKNOWN_PROCESSOR:format(proc_name), 2)
		end

		local index = find(processor.patterns, pattern)

		if index then
			table.remove(processor.patterns, index)
		end
	end,

	---Returns whether the specified processor is available.
	---@param self AutoCrafter
	---@param proc_name string The name of the inventory the processor uses.
	---@return boolean available Where the processor is available.
	is_processor_available = function(self, proc_name)
		local processor = self.processors[proc_name]

		if processor == nil then
			error(UNKNOWN_PROCESSOR:format(proc_name))
		end

		return not processor.in_use
	end,
	---Returns all available processors that are able to produce the specified item.
	---@param self AutoCrafter
	---@param pattern string The name of the item to search with.
	---@return string[] processors A list of names for available processors.
	get_available_processors = function(self, pattern)
		local processors = {}

		for proc_name, processor in next, self.processors do
			if self:is_processor_available(proc_name) and find(processor.patterns, pattern) then
				table.insert(processors, proc_name)
			end
		end

		return processors
	end,

	---Returns a dictionary of all the missing ingredients for the specified pattern.
	---@param self AutoCrafter
	---@param pattern string The pattern to check the ingredients of.
	---@param count integer The number of times the ingredients are used (ie. crafting a pattern multiple times).
	---@return table<string, integer>
	get_missing_ingredients = function(self, pattern, count)
		local system_items = self._system:get_system_items()

		local missing = {}
		local ingredients = get_pattern_ingredients(self._patterns[pattern], count)

		for ingr_name, ingr_count in next, ingredients do
			local system_count = system_items[ingr_name] or 0

			if system_count < ingr_count then
				missing[ingr_name] = ingr_count - system_count
			end
		end

		return missing
	end,

	---@param self AutoCrafter
	---@param proc_name string The name of the processor to use.
	---@param pattern string The pattern to use with the processor.
	---@param count integer The number of times to process this pattern on this processor.
	start_process_async = function(self, proc_name, pattern, count)
		local processor = self.processors[proc_name]

		if processor == nil then
			error(UNKNOWN_PROCESSOR:format(proc_name), 2)
		end

		if processor.in_use then
			error(PROCESSOR_BUSY:format(proc_name), 2)
		end

		if find(processor.patterns, pattern) == nil then
			error(PATTERN_NOT_SUPPORTED:format(proc_name), 2)
		end

		local missing = self:get_missing_ingredients(pattern, count)

		if next(missing) ~= nil then
			error(NOT_ENOUGH_INGREDIENTS, 2) -- TODO: change this
		end

		local pattern_info = self._patterns[pattern]

		local system = self._system

		local poll_duration = 1 / pattern_info.poll_rate
		local output_per_pattern = get_pattern_output_count(pattern_info)

		local input_slots = pattern_info.input_slots
		local output_slots = pattern_info.output_slots

		processor.in_use = true

		for _ = 1, count do
			-- input ingredients into slots
			for input_slot, ingredient in next, input_slots do
				local ingr_count, ingr_name = ingredient[1], ingredient[2]

				system:export_item(ingr_name, proc_name, input_slot, ingr_count)
			end

			system:update_inventories()

			-- wait for result items back
			-- should this instead check for items being added into the system?
			local remaining = output_per_pattern

			while remaining > 0 do
				sleep(poll_duration)

				for _, output_slot in next, output_slots do
					local transferred = system:import_from_slot(proc_name, output_slot)

					remaining = remaining - transferred
				end
			end
		end

		processor.in_use = false
	end,
}
local METATABLE = { __index = CLASS }

---@param system StorageSystem
---@param initial_processors? table<string, string[]>
---@return AutoCrafter
local function AutoCrafter(system, initial_processors)
	local new_autocrafting = setmetatable({
		_system = system,
		_patterns = {},
		processors = {},
	}, METATABLE)

	if initial_processors ~= nil then
		for inv_name, patterns in next, initial_processors do
			new_autocrafting:add_processor(inv_name, patterns)
		end
	end

	return new_autocrafting
end

return AutoCrafter
