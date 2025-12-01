---@type AutoCrafter.PatternInfo
return {
	label = "8x Gold Ingots",
	-- desired outcome per "process"
	results = {
		["minecraft:gold_ingot"] = 8,
	},
	-- slots to input items into
	input_slots = {
		[1] = { 8, "minecraft:raw_gold" },
		[2] = { 1, "minecraft:charcoal" },
	},
	-- slots to constantly pull
	output_slots = { 3 },
	poll_rate = 0.5,
}
