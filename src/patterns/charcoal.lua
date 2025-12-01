---@type AutoCrafter.PatternInfo
return {
	label = "3x Charcoal",
	-- desired outcome per "process"
	results = {
		["minecraft:charcoal"] = 3,
	},
	-- slots to input items into
	input_slots = {
		[1] = { 3, "minecraft:oak_log" },
		[2] = { 2, "minecraft:oak_log" },
	},
	-- slots to constantly pull
	output_slots = { 3 },
	poll_rate = 1,
}
