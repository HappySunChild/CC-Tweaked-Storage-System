local find = require("storage/utility/find")

local UNKNOWN_PERIPHERAL = 'Unable to find peripheral "%s"'
local UNKNOWN_PROCESSOR = 'Unable to find processor "%s", did you add it?'
local UNKNOWN_PATTERN = 'Unable to find pattern "%s", did you register it?'
local PATTERN_NOT_SUPPORED = 'Processor "%s" does not support this pattern!'
local PROCESSOR_BUSY = 'Processor "%s" is busy!'

---Returns a list of patterns that can produce the specified item.
---@param processor AutoProcessing.Processor
---@param item_name string
---@return AutoProcessing.PatternInfo[]
local function get_patterns_with_result(processor, item_name)
	local patterns = {}

	for _, pattern in next, processor.patterns do
		if pattern.results[item_name] ~= nil then
			table.insert(patterns, pattern)
		end
	end

	return patterns
end

---Returns a dictionary of ingredients needed to produce a pattern.
---@param pattern AutoProcessing.PatternInfo
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
---@param pattern AutoProcessing.PatternInfo
---@return integer count
local function get_pattern_output_count(pattern)
	local total_count = 0

	for _, count in next, pattern.results do
		total_count = total_count + count
	end

	return total_count
end

---@class AutoProcessing.PatternItem
---@field [1] integer
---@field [2] string

---@class AutoProcessing.PatternInfo
---@field results table<string, integer>
---@field input_slots AutoProcessing.PatternItem[] Slots to input items into.
---@field output_slots number[] Slots to constantly pull into the system.
---@field poll_rate number How frequently the processor checks the output per second.
---@field label string

---@class AutoProcessing.Processor
---@field patterns string[]
---@field in_use boolean

---@class AutoProcessing
---@field processors table<string, AutoProcessing.Processor>
---@field package _patterns table<string, AutoProcessing.PatternInfo>
---@field package _system StorageSystem
local CLASS = {
	---Adds a processor to the AutoProcessing manager.
	---@param self AutoProcessing
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
	---@param self AutoProcessing
	---@param proc_name string The name of the inventory the processor uses.
	remove_processor = function(self, proc_name)
		self.processors[proc_name] = nil
	end,
	---Returns an array of all the processors in the AutoProcessing manager.
	---@param self AutoProcessing
	---@return string[]
	get_processors = function(self)
		local processors = {}

		for proc_name in next, self.processors do
			table.insert(processors, proc_name)
		end

		return processors
	end,

	---Registers a pattern.
	---@param self AutoProcessing
	---@param pattern string
	---@param info AutoProcessing.PatternInfo
	register_pattern = function(self, pattern, info)
		self._patterns[pattern] = info
	end,
	---Deregisters a pattern.
	---@param self AutoProcessing
	---@param pattern string
	deregister_pattern = function(self, pattern)
		self._patterns[pattern] = nil
	end,
	---Returns an array of all registers patterns.
	---@param self AutoProcessing
	---@return string[]
	get_registered_patterns = function(self)
		local list = {}

		for name in next, self._patterns do
			table.insert(list, name)
		end

		return list
	end,
	---Returns the info of the pattern if it has been registered, otherwise it returns nil.
	---@param self AutoProcessing
	---@param pattern string
	---@return AutoProcessing.PatternInfo?
	get_pattern_info = function(self, pattern)
		return self._patterns[pattern]
	end,

	---Adds a pattern to a processor.
	---@param self AutoProcessing
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
	---@param self AutoProcessing
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
	---@param self AutoProcessing
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
	---@param self AutoProcessing
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

	---Returns an array of all the missing ingredients in the system for the specified pattern.
	---@param self AutoProcessing
	---@param pattern_info AutoProcessing.PatternInfo
	---@param count integer
	---@return string[] missing
	get_missing_ingredients = function(self, pattern_info, count)
		local system_items = self._system:get_system_items()

		local missing = {}

		for ingr_name, ingr_count in next, get_pattern_ingredients(pattern_info, count) do
			local system_count = system_items[ingr_name]

			if system_count == nil or system_count < ingr_count then
				table.insert(missing, ingr_name)
			end
		end

		return missing
	end,

	---@param self AutoProcessing
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
			error(PATTERN_NOT_SUPPORED:format(proc_name), 2)
		end

		local pattern_info = self._patterns[pattern]

		local system = self._system

		local poll_duration = 1 / pattern_info.poll_rate
		local output_per_pattern = get_pattern_output_count(pattern_info)

		local low_items = self:get_missing_ingredients(pattern_info, count)

		if #low_items > 0 then
			error(table.concat(low_items, ", ")) -- change this
		end

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
---@param initial_processors table<string, string[]>
---@return AutoProcessing
local function AutoProcessing(system, initial_processors)
	local new_autoprocessing = setmetatable({
		_system = system,
		_patterns = {},
		processors = {},
	}, METATABLE)

	for inv_name, patterns in next, initial_processors do
		new_autoprocessing:add_processor(inv_name, patterns)
	end

	return new_autoprocessing
end

return AutoProcessing
