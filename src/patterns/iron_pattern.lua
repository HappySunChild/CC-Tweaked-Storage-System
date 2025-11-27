---@type AutoProcessing.Pattern
return {
	label = "8x Iron Ingots",
	-- desired outcome per "process"
	results = {
		["minecraft:iron_ingot"] = 8,
	},
	-- slots to input items into
	input_slots = {
		[1] = { 8, "minecraft:iron_ore" },
		[2] = { 1, "minecraft:coal" },
	},
	-- slots to constantly pull
	output_slots = { 3 },
	poll_rate = 0.5,
}
