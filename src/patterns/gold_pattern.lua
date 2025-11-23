---@type AutoProcessing.Pattern
return {
	-- desired outcome per "process"
	results = {
		["minecraft:gold_ingot"] = 8,
	},
	-- slots to input items into
	input_slots = {
		[1] = { 8, "minecraft:gold_ore" },
		[2] = { 1, "minecraft:coal" },
	},
	-- slots to constantly pull
	output_slots = { 3 },
	poll_rate = 0.5,
}
